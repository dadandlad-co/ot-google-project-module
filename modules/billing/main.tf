/**
 * # Google Cloud Billing Module
 *
 * This module manages Google Cloud billing account assignments, permissions, and budget configurations.
 */

resource "google_billing_account_iam_member" "billing_admin" {
  for_each = toset(var.billing_admins)

  billing_account_id = var.billing_account_id
  role               = "roles/billing.admin"
  member             = each.value
}

resource "google_billing_account_iam_member" "billing_user" {
  for_each = toset(var.billing_users)

  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member             = each.value
}

resource "google_billing_account_iam_member" "billing_viewer" {
  for_each = toset(var.billing_viewers)

  billing_account_id = var.billing_account_id
  role               = "roles/billing.viewer"
  member             = each.value
}

resource "google_billing_account_iam_member" "billing_cost_manager" {
  for_each = toset(var.billing_cost_managers)

  billing_account_id = var.billing_account_id
  role               = "roles/billing.costsManager"
  member             = each.value
}

resource "google_billing_account_iam_member" "billing_project_creator" {
  for_each = toset(var.billing_project_creators)

  billing_account_id = var.billing_account_id
  role               = "roles/billing.projectManager"
  member             = each.value
}

resource "google_billing_account_iam_member" "custom_iam_members" {
  for_each = {
    for binding in var.billing_account_iam_members : "${binding.role}/${binding.member}" => binding
  }

  billing_account_id = var.billing_account_id
  role               = each.value.role
  member             = each.value.member
}

# Billing account budget configuration
resource "google_billing_budget" "billing_account_budget" {
  count            = var.enable_billing_budget ? 1 : 0
  billing_account  = var.billing_account_id
  display_name     = var.budget_display_name
  
  amount {
    specified_amount {
      currency_code = var.budget_currency_code
      units         = var.budget_amount
    }
  }

  dynamic "threshold_rules" {
    for_each = var.budget_alert_spend_thresholds
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }

  dynamic "all_updates_rule" {
    for_each = var.budget_alert_pubsub_topic != null ? [1] : []
    content {
      pubsub_topic = var.budget_alert_pubsub_topic
      schema_version = "1.0"
    }
  }

  dynamic "all_updates_rule" {
    for_each = var.budget_alert_email_addresses != null && length(var.budget_alert_email_addresses) > 0 ? [1] : []
    content {
      monitoring_notification_channels = var.budget_monitoring_notification_channels
      disable_default_iam_recipients   = var.budget_disable_default_iam_recipients
    }
  }
}