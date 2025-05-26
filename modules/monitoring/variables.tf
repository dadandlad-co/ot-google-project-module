variable "project_id" {
  description = "The GCP project ID where monitoring resources will be created"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must follow GCP naming conventions."
  }
}

variable "notification_emails" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for email in var.notification_emails : can(regex("^[^@]+@[^@]+\\.[^@]+$", email))
    ])
    error_message = "All notification emails must be valid email addresses."
  }
}

variable "slack_channels" {
  description = "Map of Slack channels for notifications"
  type = map(object({
    channel = string
    url     = string
  }))
  default = {}
}

variable "enable_default_alerts" {
  description = "Whether to create default alert policies for common metrics"
  type        = bool
  default     = true
}

variable "cpu_threshold" {
  description = "CPU usage threshold percentage for alerts"
  type        = number
  default     = 80
  
  validation {
    condition     = var.cpu_threshold > 0 && var.cpu_threshold <= 100
    error_message = "CPU threshold must be between 1 and 100."
  }
}

variable "memory_threshold" {
  description = "Memory usage threshold percentage for alerts"
  type        = number
  default     = 85
  
  validation {
    condition     = var.memory_threshold > 0 && var.memory_threshold <= 100
    error_message = "Memory threshold must be between 1 and 100."
  }
}

variable "alert_duration" {
  description = "Duration in seconds before triggering an alert"
  type        = number
  default     = 300
  
  validation {
    condition     = var.alert_duration >= 60 && var.alert_duration <= 3600
    error_message = "Alert duration must be between 60 and 3600 seconds."
  }
}

variable "auto_close_duration" {
  description = "Duration in seconds to auto-close alerts"
  type        = number
  default     = 86400
}

variable "custom_alert_policies" {
  description = "Map of custom alert policies to create"
  type = map(object({
    display_name = string
    combiner     = string
    enabled      = optional(bool, true)
    conditions = list(object({
      display_name    = string
      filter          = string
      comparison      = string
      threshold_value = number
      duration        = string
      aggregations = optional(list(object({
        alignment_period     = string
        per_series_aligner   = string
        cross_series_reducer = optional(string)
        group_by_fields      = optional(list(string), [])
      })), [])
    }))
  }))
  default = {}
}

variable "uptime_checks" {
  description = "Map of uptime checks to create"
  type = map(object({
    display_name     = string
    host             = string
    path             = string
    port             = number
    use_ssl          = bool
    validate_ssl     = bool
    timeout          = number
    period           = number
    expected_content = string
  }))
  default = {}
}