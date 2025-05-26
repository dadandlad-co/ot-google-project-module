/**
 * # Google Cloud Billing Budget Module
 *
 * This module creates and manages Google Cloud billing budgets for projects with support for:
 * - Project-specific or billing account-wide budgets
 * - Multiple alert thresholds with customizable spending basis
 * - Pub/Sub topic notifications for automated responses
 * - Email notifications through monitoring channels
 * - Flexible budget filtering by projects, services, or labels
 *
 * ## Usage
 *
 * ```hcl
 * module "project_budget" {
 *   source = "./modules/billing-budget"
 *
 *   billing_account = "ABCDEF-123456-GHIJKL"
 *   display_name    = "My Project Budget"
 *   amount          = 1000
 *   currency_code   = "USD"
 *
 *   project_ids = ["projects/123456789"]
 *
 *   alert_spend_thresholds = [0.5, 0.8, 0.9, 1.0]
 *   alert_pubsub_topic     = "projects/my-project/topics/budget-alerts"
 * }
 * ```
 */

locals {
  # Normalize project IDs to ensure consistent format
  normalized_project_ids = [
    for project_id in var.project_ids :
    can(regex("^\\d+$", project_id)) ? "projects/${project_id}" : project_id
  ]

  # Create budget filter based on provided parameters
  has_project_filter = length(var.project_ids) > 0
  has_service_filter = length(var.services) > 0
  has_label_filter   = length(keys(var.labels)) > 0
}

# Create the billing budget
resource "google_billing_budget" "budget" {
  billing_account = var.billing_account
  display_name    = var.display_name

  # Budget amount configuration
  amount {
    specified_amount {
      currency_code = var.currency_code
      units         = var.amount
    }
  }

  # Budget filter - only include if filters are specified
  dynamic "budget_filter" {
    for_each = local.has_project_filter || local.has_service_filter || local.has_label_filter ? [1] : []
    content {
      # Filter by specific projects
      projects = local.has_project_filter ? local.normalized_project_ids : null
      # labels   = local.has_label_filter ? var.labels : null

      # Filter by specific services
      services = local.has_service_filter ? [
        for service in var.services :
        startswith(service, "services/") ? service : "services/${service}"
      ] : null

      # Filter by credit types
      credit_types_treatment = var.credit_types_treatment
    }
  }

  # Threshold rules for spending alerts
  dynamic "threshold_rules" {
    for_each = var.alert_spend_thresholds
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = var.spend_basis
    }
  }

  # Pub/Sub notification configuration
  dynamic "all_updates_rule" {
    for_each = var.alert_pubsub_topic != null || length(var.monitoring_notification_channels) > 0 ? [1] : []
    content {
      pubsub_topic                     = var.alert_pubsub_topic
      schema_version                   = var.pubsub_schema_version
      monitoring_notification_channels = var.monitoring_notification_channels
      disable_default_iam_recipients   = var.disable_default_iam_recipients
    }
  }
}

# Create Pub/Sub topic if requested and doesn't exist
resource "google_pubsub_topic" "budget_alerts" {
  count   = var.create_pubsub_topic ? 1 : 0
  project = var.pubsub_topic_project
  name    = var.pubsub_topic_name

  labels = {
    purpose    = "budget-alerts"
    managed_by = "opentofu"
  }
}

# Create monitoring notification channels for email alerts if specified
resource "google_monitoring_notification_channel" "email_channels" {
  for_each = toset(var.alert_email_addresses)

  project      = var.monitoring_project != null ? var.monitoring_project : var.pubsub_topic_project
  display_name = "Budget Alert - ${each.value}"
  type         = "email"

  labels = {
    email_address = each.value
  }

  enabled = true
}
