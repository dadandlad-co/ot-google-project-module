output "notification_channels" {
  description = "Map of notification channel names to their IDs"
  value = merge(
    { for k, v in google_monitoring_notification_channel.email : k => v.name },
    { for k, v in google_monitoring_notification_channel.slack : k => v.name }
  )
}

output "alert_policy_ids" {
  description = "Map of alert policy names to their IDs"
  value = merge(
    { for k, v in google_monitoring_alert_policy.project_alerts : k => v.name },
    { for k, v in google_monitoring_alert_policy.budget_alerts : k => v.name },
    { for k, v in google_monitoring_alert_policy.custom_alerts : k => v.name }
  )
}

output "uptime_check_ids" {
  description = "Map of uptime check names to their IDs"
  value       = { for k, v in google_monitoring_uptime_check_config.uptime_checks : k => v.name }
}

output "project_id" {
  description = "The project ID where monitoring resources were created"
  value       = var.project_id
}
