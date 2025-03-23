variable "billing_account_id" {
  description = "The ID of the billing account."
  type        = string

  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account_id))
    error_message = "The billing_account_id must be in the format XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "billing_account_iam_members" {
  description = "A list of IAM members to add to the billing account with custom roles."
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}

variable "billing_admins" {
  description = "List of IAM members to grant billing admin role."
  type        = list(string)
  default     = []
}

variable "billing_cost_managers" {
  description = "List of IAM members to grant billing cost manager role."
  type        = list(string)
  default     = []
}

variable "billing_project_creators" {
  description = "List of IAM members to grant billing project creator role."
  type        = list(string)
  default     = []
}

variable "billing_users" {
  description = "List of IAM members to grant billing user role."
  type        = list(string)
  default     = []
}

variable "billing_viewers" {
  description = "List of IAM members to grant billing viewer role."
  type        = list(string)
  default     = []
}

variable "budget_alert_email_addresses" {
  description = "List of email addresses to notify for budget alerts."
  type        = list(string)
  default     = []
}

variable "budget_alert_pubsub_topic" {
  description = "The name of the Pub/Sub topic where budget related messages will be published."
  type        = string
  default     = null
}

variable "budget_alert_spend_thresholds" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded."
  type        = list(number)
  default     = [0.5, 0.7, 0.9, 1.0]

  validation {
    condition = alltrue([
      for threshold in var.budget_alert_spend_thresholds :
      threshold >= 0 && threshold <= 1.0
    ])
    error_message = "Budget alert thresholds must be between 0 and 1.0 (representing 0% to 100%)."
  }
}

variable "budget_amount" {
  description = "The amount to use as the budget."
  type        = number
  default     = 1000
}

variable "budget_currency_code" {
  description = "The 3-letter currency code defined in ISO 4217."
  type        = string
  default     = "USD"
}

variable "budget_disable_default_iam_recipients" {
  description = "Whether to disable default IAM recipients for budget notifications."
  type        = bool
  default     = false
}

variable "budget_display_name" {
  description = "The display name of the budget."
  type        = string
  default     = "Billing Account Budget"
}

variable "budget_monitoring_notification_channels" {
  description = "The list of monitoring notification channels to send alerts to."
  type        = list(string)
  default     = []
}

variable "enable_billing_budget" {
  description = "Whether to enable budget monitoring."
  type        = bool
  default     = false
}
