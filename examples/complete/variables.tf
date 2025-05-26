variable "billing_account" {
  description = "The billing account ID"
  type        = string
}

variable "org_id" {
  description = "The organization ID"
  type        = string
}

variable "project_id" {
  description = "The project ID"
  type        = string
  default     = "complete-example"
}

variable "project_name" {
  description = "The project display name"
  type        = string
  default     = "Complete Example Project"
}

variable "folder_id" {
  description = "Folder ID to create project in"
  type        = string
  default     = null
}

variable "random_project_id" {
  description = "Add random suffix to project ID"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "development"
}

variable "team" {
  description = "Team responsible for the project"
  type        = string
  default     = "platform"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "application" {
  description = "Application name"
  type        = string
  default     = "example-app"
}

variable "compliance_level" {
  description = "Compliance level required"
  type        = string
  default     = "standard"
}

variable "viewer_email" {
  description = "Email for viewer access"
  type        = string
}

variable "editor_group" {
  description = "Group for editor access"
  type        = string
}

variable "owner_email" {
  description = "Email for owner access"
  type        = string
}

variable "temp_admin_email" {
  description = "Email for temporary admin access"
  type        = string
}

variable "shared_vpc_host_project_id" {
  description = "Shared VPC host project ID"
  type        = string
  default     = null
}

variable "budget_amount" {
  description = "Budget amount in USD"
  type        = number
  default     = 1000
}

variable "budget_alert_emails" {
  description = "List of emails for budget alerts"
  type        = list(string)
  default     = []
}

variable "budget_pubsub_topic" {
  description = "Pub/Sub topic for budget alerts"
  type        = string
  default     = null
}
