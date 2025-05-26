variable "billing_account" {
  description = "The billing account ID to associate with the project"
  type        = string
  default     = "ABCDEF-123456-GHIJKL" # Replace with your billing account
}

variable "org_id" {
  description = "The organization ID"
  type        = string
  default     = "123456789012" # Replace with your org ID
}

variable "project_id" {
  description = "The project ID"
  type        = string
  default     = "simple-project-example"
}

variable "project_name" {
  description = "The project display name"
  type        = string
  default     = "Simple Project Example"
}
