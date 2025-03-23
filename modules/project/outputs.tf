output "billing_account" {
  description = "The billing account used by the project, if any."
  value       = google_project.this.billing_account
}

output "folder_id" {
  description = "The folder containing the project."
  value       = google_project.this.folder_id
}

output "id" {
  description = "The project ID."
  value       = google_project.this.id
}

output "is_random_id_enabled" {
  description = "Whether a random ID is enabled."
  value       = local.random_id_enabled
}

output "name" {
  description = "The name of the project."
  value       = google_project.this.name
}

output "number" {
  description = "The numeric identifier of the project."
  value       = google_project.this.number
}

output "org_id" {
  description = "The organization that the project belongs to."
  value       = google_project.this.org_id
}

output "project_id" {
  description = "The project ID (with random suffix if enabled)."
  value       = google_project.this.project_id
}

output "random_id" {
  description = "The random ID suffix if enabled (null otherwise)."
  value       = local.random_id_enabled ? random_id.project_suffix[0].hex : null
}

output "service_account" {
  description = "The project service account email (if created)."
  value       = var.create_project_sa ? google_service_account.project_service_account[0].email : null
}

output "service_account_id" {
  description = "The project service account ID (if created)."
  value       = var.create_project_sa ? google_service_account.project_service_account[0].id : null
}

output "service_account_name" {
  description = "The project service account name (if created)."
  value       = var.create_project_sa ? google_service_account.project_service_account[0].name : null
}

output "service_account_unique_id" {
  description = "The unique ID of the service account (if created)."
  value       = var.create_project_sa ? google_service_account.project_service_account[0].unique_id : null
}

output "shared_vpc_enabled" {
  description = "Whether shared VPC is enabled for this project."
  value       = local.svpc_host_project_required
}

output "shared_vpc_host_project_id" {
  description = "The host project ID if using shared VPC."
  value       = var.shared_vpc_host_project_id
}