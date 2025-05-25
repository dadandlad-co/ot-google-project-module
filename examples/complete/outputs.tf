output "project_id" {
  description = "The ID of the created project"
  value       = module.complete_project.project_id
}

output "project_number" {
  description = "The number of the created project"
  value       = module.complete_project.number
}

output "service_account_email" {
  description = "The service account email"
  value       = module.complete_project.service_account_email
}

output "enabled_apis" {
  description = "List of APIs enabled in the project"
  value       = module.complete_project.enabled_apis
}

output "budget_id" {
  description = "The budget ID"
  value       = module.project_budget.budget_id
}

output "random_suffix" {
  description = "The random suffix added to project ID"
  value       = module.complete_project.random_suffix
}

output "shared_vpc_enabled" {
  description = "Whether shared VPC is enabled"
  value       = module.complete_project.shared_vpc_enabled
}