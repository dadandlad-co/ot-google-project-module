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

variable "enable_dashboards" {
  description = "Whether to create dashboards"
  type        = bool
  default     = true
}

variable "budget_amount" {
  description = "Monthly budget amount in the project's currency"
  type        = number
  default     = null
}

variable "budget_name" {
  description = "Name of the budget for alert display"
  type        = string
  default     = null
}

variable "notification_channels" {
  description = "List of notification channel IDs to be used for alerts"
  type        = list(string)
  default     = []
}

variable "auto_close_duration" {
  description = "Duration in seconds to auto-close alerts"
  type        = number
  default     = 86400
}

variable "custom_alert_policies" {
  description = "Map of custom alert policies to create"
  type = map(object({
    display_name            = string
    combiner                = string
    enabled                 = optional(bool, true)
    labels                  = optional(map(string), {})
    documentation_content   = optional(string, "Alert created by Terraform")
    documentation_mime_type = optional(string, "text/markdown")
    alert_strategy = optional(object({
      auto_close = optional(string)
      notification_rate_limit = optional(object({
        period = optional(string, "300s")
      }))
    }))
    conditions = list(object({
      display_name       = string
      condition_type     = optional(string, "threshold") # can be "threshold" or "absent"
      filter             = string
      comparison         = optional(string) # required for threshold conditions
      threshold_value    = optional(number) # required for threshold conditions
      duration           = string
      denominator_filter = optional(string)
      denominator_aggregations = optional(list(object({
        alignment_period     = optional(string, "60s")
        per_series_aligner   = optional(string, "ALIGN_MEAN")
        cross_series_reducer = optional(string)
        group_by_fields      = optional(list(string), [])
      })), [])
      aggregations = optional(list(object({
        alignment_period     = optional(string, "60s")
        per_series_aligner   = optional(string, "ALIGN_MEAN")
        cross_series_reducer = optional(string)
        group_by_fields      = optional(list(string), [])
      })), [])
      trigger = optional(object({
        count   = optional(number)
        percent = optional(number)
      }))
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
    expected_content = optional(string, "")
    request_method   = optional(string, "GET")
    matcher          = optional(string, "CONTAINS_STRING")
    headers          = optional(map(string), {})
  }))
  default = {}
}
