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
}

# Project monitoring alerts
resource "google_monitoring_alert_policy" "project_alerts" {
  for_each = var.enable_project_monitoring ? local.alert_policies : {}
  
  project      = var.project_id
  display_name = format(each.value.display_name, var.project_id)
  combiner     = each.value.combiner
  enabled      = each.value.enabled
  
  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name
      
      condition_threshold {
        filter          = format(conditions.value.condition_threshold.filter, var.project_id)
        comparison      = conditions.value.condition_threshold.comparison
        threshold_value = conditions.value.condition_threshold.threshold_value
        duration        = conditions.value.condition_threshold.duration
        
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
  
  notification_channels = var.notification_channels
  
  dynamic "alert_strategy" {
    for_each = lookup(each.value, "alert_strategy", null) != null ? [each.value.alert_strategy] : []
    content {
      auto_close = alert_strategy.value.auto_close
    }
  }
}

# Budget monitoring alerts
resource "google_monitoring_alert_policy" "budget_alerts" {
  for_each = var.enable_budget_monitoring && var.billing_account != null ? {
    budget_burn_rate = local.alert_policies["budget_burn_rate"]
  } : {}
  
  project      = var.project_id
  display_name = format(each.value.display_name, var.budget_name)
  combiner     = each.value.combiner
  
  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name
      
      condition_threshold {
        filter          = format(conditions.value.condition_threshold.filter, var.billing_account)
        comparison      = conditions.value.condition_threshold.comparison
        threshold_value = var.budget_amount / 30 * conditions.value.condition_threshold.multiplier
        duration        = conditions.value.condition_threshold.duration
      }
    }
  }
  
  notification_channels = var.notification_channels
}

# Dashboards
resource "google_monitoring_dashboard" "dashboards" {
  for_each = var.enable_dashboards ? local.dashboards : {}
  
  project      = var.project_id
  display_name = format(each.value.displayName, var.project_id)
  
  dashboard_json = jsonencode(merge(each.value, {
    displayName = format(each.value.displayName, var.project_id)
  }))
}