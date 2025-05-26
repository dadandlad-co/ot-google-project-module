variable "alert_email_addresses" {
  description = "List of email addresses to receive budget alert notifications. Monitoring notification channels will be created automatically."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.alert_email_addresses : can(regex("^[^@]+@[^@]+\\.[^@]+$", email))
    ])
    error_message = "All email addresses must be valid email format."
  }
}

variable "alert_pubsub_topic" {
  description = "The Pub/Sub topic to send budget alerts to. Format: 'projects/{project}/topics/{topic}'. Leave null to disable Pub/Sub notifications."
  type        = string
  default     = null

  validation {
    condition     = var.alert_pubsub_topic == null || can(regex("^projects/[^/]+/topics/[^/]+$", var.alert_pubsub_topic))
    error_message = "Pub/Sub topic must be in format 'projects/{project}/topics/{topic}' or null."
  }
}

variable "alert_spend_thresholds" {
  description = "List of spend thresholds (as percentages from 0.0 to 1.0) that trigger budget alerts."
  type        = list(number)
  default     = [0.5, 0.8, 0.9, 1.0]

  validation {
    condition = alltrue([
      for threshold in var.alert_spend_thresholds : threshold > 0 && threshold <= 1.0
    ])
    error_message = "All thresholds must be between 0.01 and 1.0 (representing 1% to 100%)."
  }

  validation {
    condition     = length(var.alert_spend_thresholds) > 0
    error_message = "At least one alert threshold must be specified."
  }
}

variable "amount" {
  description = "The amount of the budget in the specified currency."
  type        = number

  validation {
    condition     = var.amount > 0
    error_message = "Budget amount must be greater than 0."
  }
}

variable "billing_account" {
  description = "The billing account ID to create the budget for. Format: XXXXXX-XXXXXX-XXXXXX"
  type        = string

  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account))
    error_message = "The billing_account must be in the format XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "create_pubsub_topic" {
  description = "Whether to create the Pub/Sub topic for budget alerts. Only used if alert_pubsub_topic is null and you want to create a new topic."
  type        = bool
  default     = false
}

variable "credit_types_treatment" {
  description = "How to treat credits in budget calculations. Options: INCLUDE_ALL_CREDITS, EXCLUDE_ALL_CREDITS, INCLUDE_SPECIFIED_CREDITS"
  type        = string
  default     = "INCLUDE_ALL_CREDITS"

  validation {
    condition = contains([
      "INCLUDE_ALL_CREDITS",
      "EXCLUDE_ALL_CREDITS",
      "INCLUDE_SPECIFIED_CREDITS"
    ], var.credit_types_treatment)
    error_message = "Credit types treatment must be one of: INCLUDE_ALL_CREDITS, EXCLUDE_ALL_CREDITS, INCLUDE_SPECIFIED_CREDITS."
  }
}

variable "currency_code" {
  description = "The 3-letter currency code (ISO 4217) for the budget amount."
  type        = string
  default     = "USD"

  validation {
    condition     = can(regex("^[A-Z]{3}$", var.currency_code))
    error_message = "Currency code must be a 3-letter uppercase code (e.g., USD, EUR, GBP)."
  }
}

variable "disable_default_iam_recipients" {
  description = "Whether to disable default IAM recipients for budget notifications."
  type        = bool
  default     = false
}

variable "display_name" {
  description = "The display name for the budget."
  type        = string

  validation {
    condition     = length(var.display_name) >= 1 && length(var.display_name) <= 60
    error_message = "Display name must be between 1 and 60 characters."
  }
}

variable "labels" {
  description = "Map of labels for budget filtering. Each key maps to a list of values to match."
  type        = map(list(string))
  default     = {}
}

variable "monitoring_notification_channels" {
  description = "List of monitoring notification channel IDs to send budget alerts to. Use this if you have existing channels."
  type        = list(string)
  default     = []
}

variable "monitoring_project" {
  description = "Project ID where monitoring notification channels should be created. Defaults to pubsub_topic_project if not specified."
  type        = string
  default     = null
}

variable "project_ids" {
  description = "List of project IDs or numbers to include in the budget. Can be in format 'projects/123' or just '123'. Leave empty for billing account-wide budget."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for project_id in var.project_ids : can(regex("^(projects/)?[a-z0-9-]+$", project_id)) || can(regex("^(projects/)?\\d+$", project_id))
    ])
    error_message = "Project IDs must be valid GCP project IDs or numbers, optionally prefixed with 'projects/'."
  }
}

variable "pubsub_schema_version" {
  description = "Schema version for Pub/Sub budget notifications."
  type        = string
  default     = "1.0"

  validation {
    condition     = contains(["1.0"], var.pubsub_schema_version)
    error_message = "Schema version must be '1.0'."
  }
}

variable "pubsub_topic_name" {
  description = "Name of the Pub/Sub topic to create for budget alerts. Only used if create_pubsub_topic is true."
  type        = string
  default     = "budget-alerts"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_.~+%]{2,254}$", var.pubsub_topic_name))
    error_message = "Pub/Sub topic name must be 3-255 characters, start with a letter, and contain only valid characters."
  }
}

variable "pubsub_topic_project" {
  description = "Project ID where the Pub/Sub topic should be created. Required if create_pubsub_topic is true."
  type        = string
  default     = null
}

variable "services" {
  description = "List of services to include in the budget filter. Can be service names or full service IDs."
  type        = list(string)
  default     = []
}

variable "spend_basis" {
  description = "The spend basis for threshold calculations. CURRENT_SPEND or FORECASTED_SPEND."
  type        = string
  default     = "CURRENT_SPEND"

  validation {
    condition     = contains(["CURRENT_SPEND", "FORECASTED_SPEND"], var.spend_basis)
    error_message = "Spend basis must be either 'CURRENT_SPEND' or 'FORECASTED_SPEND'."
  }
}
