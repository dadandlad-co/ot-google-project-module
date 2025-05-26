output "notification_channels" {
  description = "Map of notification channel names to their IDs"
  value = merge(
    { for k, v in google_monitoring_notification_channel.email_channels : k => v.id },
    { for k, v in google_monitoring_notification_channel.slack_channels : k => v.id }
  )
}

output "alert_policy_ids" {
  description = "Map of alert policy names to their IDs"
  value = merge(
    { for k, v in google_monitoring_alert_policy.default_alerts : k => v.id },
    { for k, v in google_monitoring_alert_policy.custom_alerts : k => v.id }
  )
}

output "uptime_check_ids" {
  description = "Map of uptime check names to their IDs"
  value = { for k, v in google_monitoring_uptime_check_config.http_checks : k => v.id }
}

output "project_id" {
  description = "The project ID where monitoring resources were created"
  value = var.project_id
}