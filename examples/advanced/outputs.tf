output "project_id" {
  description = "The ID of the created project"
  value       = module.project.project_id
}

output "project_name" {
  description = "The name of the created project"
  value       = module.project.project_name
}

output "project_number" {
  description = "The numeric identifier of the project"
  value       = module.project.project_number
}

output "service_account_email" {
  description = "The email address of the default service account"
  value       = module.project.service_account_email
}

output "service_account_id" {
  description = "The ID of the default service account"
  value       = module.project.service_account_id
}

output "enabled_apis" {
  description = "List of APIs enabled in the project"
  value       = module.project.enabled_apis
}

output "enabled_api_services" {
  description = "Map of active services with their details"
  value       = module.project.enabled_api_services
}