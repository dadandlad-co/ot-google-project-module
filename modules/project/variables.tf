variable "activate_apis" {
  description = "The list of apis to activate within the project."
  type        = list(string)
  default     = []
}

variable "auto_create_network" {
  description = "Create the default network for the project."
  type        = bool
  default     = false
}

variable "billing_account" {
  description = "The alphanumeric ID of the billing account this project belongs to."
  type        = string
  default     = null
}

variable "budget_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of 'projects/{project_id}/topics/{topic_id}'."
  type        = string
  default     = null
}

variable "budget_alert_spend_thresholds" {
  description = "A list of numeric values representing percentages of the budget to alert on when threshold is exceeded."
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
  description = "The amount to use as the budget, in the units specified by budget_currency_code."
  type        = number
  default     = null
}

variable "budget_currency_code" {
  description = "The 3-letter currency code defined in ISO 4217 (https://cloud.google.com/billing/docs/resources/currency)."
  type        = string
  default     = "USD"
}

variable "budget_display_name" {
  description = "The display name of the budget. If not specified, defaults to 'Budget for {project_name}'."
  type        = string
  default     = null
}

variable "create_project_sa" {
  description = "Whether to create a service account for the project."
  type        = bool
  default     = false
}

variable "disable_dependent_services" {
  description = "Whether to disable dependent services when disabling a service."
  type        = bool
  default     = true
}

variable "disable_services_on_destroy" {
  description = "Whether to disable services when destroying the project."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "The ID of a folder to host this project."
  type        = string
  default     = null

  validation {
    condition     = var.folder_id == null || can(regex("^folders/\\d+$|^\\d+$", var.folder_id))
    error_message = "The folder_id must be null or match the pattern 'folders/123456789' or '123456789'."
  }
}

variable "iam_members" {
  description = "A list of IAM members to add to the project, in the form of {role = \"roles/role\", member = \"user:user@example.com\"}."
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the project."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The display name of the project."
  type        = string
}

variable "org_id" {
  description = "The numeric ID of the organization this project belongs to."
  type        = string
  default     = null

  validation {
    condition     = var.org_id == null || can(regex("^\\d+$", var.org_id))
    error_message = "The org_id must be null or a numeric string."
  }
}

variable "prevent_destroy" {
  description = "Whether to prevent destruction of the project resource."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "The ID to give the project. If not provided, the name will be used."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id must be 6 to 30 lowercase letters, digits, or hyphens. It must start with a letter and cannot end with a hyphen."
  }
}

variable "project_sa_name" {
  description = "The name of the service account to create for the project."
  type        = string
  default     = "project-service-account"
}

variable "project_sa_roles" {
  description = "The IAM roles to assign to the project service account."
  type        = list(string)
  default     = []
}

variable "random_id" {
  description = "Random ID configuration to append to project_id. Set to null to disable."
  type = object({
    byte_length = number
    prefix      = string
  })
  default = null

  validation {
    condition     = var.random_id == null || (var.random_id.byte_length > 0 && var.random_id.byte_length <= 8)
    error_message = "If random_id is provided, byte_length must be between 1 and 8."
  }
}

variable "shared_vpc_host_project_id" {
  description = "The ID of the host project which hosts the shared VPC."
  type        = string
  default     = null
}