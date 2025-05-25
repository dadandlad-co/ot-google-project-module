variable "billing_account" {
  description = "The billing account ID for Dad and Lad Co"
  type        = string
  # Set in terraform.tfvars or environment
}

variable "org_id" {
  description = "The organization ID"
  type        = string
  # Set in terraform.tfvars or environment
}

variable "environment" {
  description = "Environment for the platform"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "platform_owner_email" {
  description = "Email of platform owner (full access)"
  type        = string
  # This should be your email
}

variable "developer_email" {
  description = "Email of developer (editor access)"
  type        = string
  default     = null
}

variable "cicd_service_account" {
  description = "Service account used by CI/CD pipeline"
  type        = string
  default     = null
}

variable "ops_team_group" {
  description = "Google Group for operations team (monitoring access)"
  type        = string
  default     = null
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD for the platform"
  type        = number
  default     = 500
  
  validation {
    condition     = var.monthly_budget_amount > 0
    error_message = "Budget amount must be greater than 0."
  }
}

variable "finance_contact_email" {
  description = "Email for budget alerts and financial notifications"
  type        = string
  default     = null
}

variable "enable_advanced_monitoring" {
  description = "Enable advanced monitoring and alerting for the platform"
  type        = bool
  default     = true
}

variable "enable_audit_logs" {
  description = "Enable audit logging for compliance"
  type        = bool
  default     = true
}

variable "content_moderation_enabled" {
  description = "Enable content moderation for generated reviews"
  type        = bool
  default     = true
}