locals {
  # Load YAML configs
  alert_policies = {
    for file in fileset("${path.module}/alert_policies", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("${path.module}/alert_policies/${file}"))
  }

  dashboards = {
    for file in fileset("${path.module}/dashboards", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("${path.module}/dashboards/${file}"))
  }

  # Separate alert policies by type
  project_alert_policies = {
    for k, v in local.alert_policies : k => v if k != "budget_burn_rate"
  }

  budget_alert_policy = contains(keys(local.alert_policies), "budget_burn_rate") ? {
    budget_burn_rate = local.alert_policies["budget_burn_rate"]
  } : {}

  # Create notification channels from inputs
  notification_channels = concat(
    [
      for email in var.notification_emails :
      google_monitoring_notification_channel.email[email].name
    ],
    [
      for channel, _ in var.slack_channels :
      google_monitoring_notification_channel.slack[channel].name
    ],
    var.notification_channels
  )
}

# Email notification channels
resource "google_monitoring_notification_channel" "email" {
  for_each = toset(var.notification_emails)

  project      = var.project_id
  display_name = "Email Notification: ${each.key}"
  type         = "email"
  labels = {
    email_address = each.key
  }
}

# Slack notification channels
resource "google_monitoring_notification_channel" "slack" {
  for_each = var.slack_channels

  project      = var.project_id
  display_name = "Slack Notification: ${each.value.channel}"
  type         = "slack"
  labels = {
    channel_name = each.value.channel
  }
  sensitive_labels {
    auth_token = each.value.url
  }
}

# Project monitoring alerts
resource "google_monitoring_alert_policy" "project_alerts" {
  for_each = { for k, v in local.project_alert_policies : k => v if var.enable_default_alerts }

  project      = var.project_id
  display_name = format(each.value.display_name, var.project_id)
  combiner     = each.value.combiner
  enabled      = each.value.enabled

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      condition_threshold {
        filter     = format(conditions.value.condition_threshold.filter, var.project_id)
        comparison = conditions.value.condition_threshold.comparison
        threshold_value = lookup(conditions.value.condition_threshold, "threshold_value",
        lookup(conditions.value.condition_threshold, "multiplier", 1))
        duration = conditions.value.condition_threshold.duration

        dynamic "aggregations" {
          for_each = lookup(conditions.value.condition_threshold, "aggregations", [])
          content {
            alignment_period   = aggregations.value.alignment_period
            per_series_aligner = aggregations.value.per_series_aligner
          }
        }
      }
    }
  }

  notification_channels = local.notification_channels

  dynamic "alert_strategy" {
    for_each = lookup(each.value, "alert_strategy", null) != null ? [each.value.alert_strategy] : []
    content {
      auto_close = lookup(alert_strategy.value, "auto_close", var.auto_close_duration)
    }
  }
}

# Budget monitoring alerts
resource "google_monitoring_alert_policy" "budget_alerts" {
  # Only create budget alerts if the required variables are provided
  for_each = { for k, v in local.budget_alert_policy : k => v if var.enable_default_alerts && var.budget_amount != null && var.budget_name != null }

  project      = var.project_id
  display_name = try(format(each.value.display_name, var.budget_name), "Budget Alert for ${var.budget_name}")
  combiner     = try(each.value.combiner, "OR")
  enabled      = try(each.value.enabled, true)

  dynamic "conditions" {
    for_each = try(each.value.conditions, [])
    content {
      display_name = try(conditions.value.display_name, "Budget threshold exceeded")

      condition_threshold {
        filter = try(format(conditions.value.condition_threshold.filter, var.project_id),
        "metric.type=\"billing.googleapis.com/billing/total_cost\" AND resource.labels.project_id=\"${var.project_id}\"")
        comparison      = try(conditions.value.condition_threshold.comparison, "COMPARISON_GREATER_THAN")
        threshold_value = try(conditions.value.condition_threshold.threshold_value, var.budget_amount / 30)
        duration        = try(conditions.value.condition_threshold.duration, "0s")

        dynamic "aggregations" {
          for_each = try(conditions.value.condition_threshold.aggregations, [])
          content {
            alignment_period   = try(aggregations.value.alignment_period, "86400s")
            per_series_aligner = try(aggregations.value.per_series_aligner, "ALIGN_SUM")
          }
        }
      }
    }
  }

  notification_channels = local.notification_channels
}

# Dashboards
resource "google_monitoring_dashboard" "dashboards" {
  for_each = var.enable_dashboards ? local.dashboards : {}

  project = var.project_id

  dashboard_json = jsonencode(merge(each.value, {
    displayName = format(lookup(each.value, "displayName", lookup(each.value, "display_name", "Dashboard %s")), var.project_id)
  }))
}

# Custom alert policies
resource "google_monitoring_alert_policy" "custom_alerts" {
  for_each = var.custom_alert_policies

  project      = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner
  enabled      = lookup(each.value, "enabled", true)
  user_labels  = lookup(each.value, "labels", {})
  documentation {
    content   = lookup(each.value, "documentation_content", "Alert created by Terraform")
    mime_type = lookup(each.value, "documentation_mime_type", "text/markdown")
  }

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      # Determine condition type based on what's provided
      dynamic "condition_threshold" {
        for_each = lookup(conditions.value, "condition_type", "threshold") == "threshold" ? [1] : []
        content {
          filter          = conditions.value.filter
          comparison      = conditions.value.comparison
          threshold_value = conditions.value.threshold_value
          duration        = conditions.value.duration

          # Optional fields
          denominator_filter = lookup(conditions.value, "denominator_filter", null)

          dynamic "denominator_aggregations" {
            for_each = lookup(conditions.value, "denominator_aggregations", [])
            content {
              alignment_period     = lookup(denominator_aggregations.value, "alignment_period", "60s")
              per_series_aligner   = lookup(denominator_aggregations.value, "per_series_aligner", "ALIGN_MEAN")
              cross_series_reducer = lookup(denominator_aggregations.value, "cross_series_reducer", null)
              group_by_fields      = lookup(denominator_aggregations.value, "group_by_fields", [])
            }
          }

          dynamic "aggregations" {
            for_each = lookup(conditions.value, "aggregations", [])
            content {
              alignment_period     = lookup(aggregations.value, "alignment_period", "60s")
              per_series_aligner   = lookup(aggregations.value, "per_series_aligner", "ALIGN_MEAN")
              cross_series_reducer = lookup(aggregations.value, "cross_series_reducer", null)
              group_by_fields      = lookup(aggregations.value, "group_by_fields", [])
            }
          }

          # Optional trigger settings
          dynamic "trigger" {
            for_each = lookup(conditions.value, "trigger", null) != null ? [conditions.value.trigger] : []
            content {
              count   = lookup(trigger.value, "count", null)
              percent = lookup(trigger.value, "percent", null)
            }
          }
        }
      }

      # Support for absence condition type
      dynamic "condition_absent" {
        for_each = lookup(conditions.value, "condition_type", "threshold") == "absent" ? [1] : []
        content {
          filter   = conditions.value.filter
          duration = conditions.value.duration

          dynamic "aggregations" {
            for_each = lookup(conditions.value, "aggregations", [])
            content {
              alignment_period     = lookup(aggregations.value, "alignment_period", "60s")
              per_series_aligner   = lookup(aggregations.value, "per_series_aligner", "ALIGN_MEAN")
              cross_series_reducer = lookup(aggregations.value, "cross_series_reducer", null)
              group_by_fields      = lookup(aggregations.value, "group_by_fields", [])
            }
          }

          # Optional trigger settings
          dynamic "trigger" {
            for_each = lookup(conditions.value, "trigger", null) != null ? [conditions.value.trigger] : []
            content {
              count   = lookup(trigger.value, "count", null)
              percent = lookup(trigger.value, "percent", null)
            }
          }
        }
      }
    }
  }

  notification_channels = local.notification_channels

  dynamic "alert_strategy" {
    for_each = lookup(each.value, "alert_strategy", null) != null ? [each.value.alert_strategy] : []
    content {
      auto_close = lookup(alert_strategy.value, "auto_close", var.auto_close_duration)

      # Add notification rate limiting if specified
      dynamic "notification_rate_limit" {
        for_each = lookup(alert_strategy.value, "notification_rate_limit", null) != null ? [alert_strategy.value.notification_rate_limit] : []
        content {
          period = lookup(notification_rate_limit.value, "period", "300s")
        }
      }
    }
  }
}

# Uptime checks
resource "google_monitoring_uptime_check_config" "uptime_checks" {
  for_each = var.uptime_checks

  project      = var.project_id
  display_name = each.value.display_name
  timeout      = "${each.value.timeout}s"
  period       = "${each.value.period}s"

  http_check {
    path           = each.value.path
    port           = each.value.port
    use_ssl        = each.value.use_ssl
    validate_ssl   = each.value.validate_ssl
    request_method = lookup(each.value, "request_method", "GET")

    # Add headers if provided
    headers = lookup(each.value, "headers", {})
  }

  # Only add content matchers if expected_content is provided
  dynamic "content_matchers" {
    for_each = lookup(each.value, "expected_content", "") != "" ? [each.value.expected_content] : []
    content {
      content = content_matchers.value
      matcher = lookup(each.value, "matcher", "CONTAINS_STRING")
    }
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = each.value.host
    }
  }
}
