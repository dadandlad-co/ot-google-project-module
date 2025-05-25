output "project_id" {
  description = "The ID of the created project"
  value       = module.simple_project.project_id
}

output "project_number" {
  description = "The number of the created project"
  value       = module.simple_project.number
}

output "enabled_apis" {
  description = "List of APIs enabled in the project"
  value       = module.simple_project.enabled_apis
}