output "budget_id" {
  description = "The ID of the billing budget."
  value       = google_billing_budget.budget.id
}

output "budget_name" {
  description = "The name of the billing budget."
  value       = google_billing_budget.budget.name
}

output "budget_amount" {
  description = "The amount of the budget."
  value       = var.amount
}

output "budget_currency" {
  description = "The currency code of the budget."
  value       = var.currency_code
}

output "alert_thresholds" {
  description = "List of alert thresholds configured for the budget."
  value       = var.alert_spend_thresholds
}

output "billing_account" {
  description = "The billing account ID the budget is associated with."
  value       = var.billing_account
}

output "display_name" {
  description = "The display name of the budget."
  value       = var.display_name
}

output "monitored_projects" {
  description = "List of project IDs included in the budget filter."
  value       = var.project_ids
}

output "pubsub_topic" {
  description = "The Pub/Sub topic for budget notifications, if configured."
  value       = var.alert_pubsub_topic
}

output "created_pubsub_topic" {
  description = "The Pub/Sub topic created by this module, if any."
  value       = var.create_pubsub_topic ? google_pubsub_topic.budget_alerts[0].id : null
}

output "email_notification_channels" {
  description = "Map of email addresses to their monitoring notification channel IDs."
  value = {
    for email, channel in google_monitoring_notification_channel.email_channels :
    email => channel.id
  }
}

output "spend_basis" {
  description = "The spend basis used for threshold calculations."
  value       = var.spend_basis
}
