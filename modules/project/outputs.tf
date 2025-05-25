output "billing_account" {
  description = "The billing account ID used by the project."
  value       = google_project.project.billing_account
}

output "enabled_apis" {
  description = "List of all APIs enabled in the project, including default APIs."
  value       = local.service_apis
}

output "folder_id" {
  description = "The folder ID containing the project, if any."
  value       = google_project.project.folder_id
}

output "id" {
  description = "The project ID (same as project_id)."
  value       = google_project.project.id
}

output "labels" {
  description = "All labels applied to the project, including auto-generated ones."
  value       = google_project.project.labels
}

output "name" {
  description = "The display name of the project."
  value       = google_project.project.name
}

output "number" {
  description = "The numeric identifier of the project. Used for billing budgets and some API calls."
  value       = google_project.project.number
}

output "org_id" {
  description = "The organization ID that the project belongs to."
  value       = google_project.project.org_id
}

output "project_id" {
  description = "The project ID (with random suffix if enabled)."
  value       = google_project.project.project_id
}

output "random_suffix" {
  description = "The random suffix appended to the project ID, if enabled. Null otherwise."
  value       = var.random_project_id ? random_id.project_suffix[0].hex : null
}

output "service_account_email" {
  description = "The email address of the project service account, if created."
  value       = local.create_service_account ? google_service_account.project_service_account[0].email : null
}

output "service_account_id" {
  description = "The ID of the project service account, if created."
  value       = local.create_service_account ? google_service_account.project_service_account[0].id : null
}

output "service_account_name" {
  description = "The name of the project service account, if created."
  value       = local.create_service_account ? google_service_account.project_service_account[0].name : null
}

output "service_account_unique_id" {
  description = "The unique ID of the project service account, if created."
  value       = local.create_service_account ? google_service_account.project_service_account[0].unique_id : null
}

output "shared_vpc_enabled" {
  description = "Whether this project is attached to a shared VPC."
  value       = local.shared_vpc_enabled
}

output "shared_vpc_host_project_id" {
  description = "The host project ID for shared VPC, if enabled."
  value       = var.shared_vpc_host_project_id
}
