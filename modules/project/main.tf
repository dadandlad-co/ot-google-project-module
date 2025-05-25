/**
 * # Google Cloud Project Module
 *
 * This module creates and manages Google Cloud Platform projects with support for:
 * - Optional random ID suffix for unique project IDs
 * - Comprehensive IAM permissions management using IAM member style
 * - Service API activation with dependency management
 * - Service account creation with configurable roles
 * - Shared VPC attachment
 * - Proper validation and error handling
 *
 * ## Usage
 *
 * ```hcl
 * module "project" {
 *   source = "./modules/project"
 *
 *   name            = "My Awesome Project"
 *   project_id      = "my-awesome-project"
 *   org_id          = "123456789012"
 *   billing_account = "ABCDEF-123456-GHIJKL"
 *
 *   activate_apis = [
 *     "compute.googleapis.com",
 *     "storage.googleapis.com"
 *   ]
 *
 *   iam_members = [
 *     {
 *       role   = "roles/viewer"
 *       member = "user:jane@example.com"
 *     }
 *   ]
 * }
 * ```
 */

locals {
  # Core APIs that are almost always needed for any GCP project
  default_service_apis = [
    "cloudresourcemanager.googleapis.com", # For project management
    "cloudbilling.googleapis.com",         # For billing operations
    "iam.googleapis.com",                  # For IAM operations
    "serviceusage.googleapis.com",         # For enabling other APIs
  ]

  # Combine default and user-specified APIs, removing duplicates
  service_apis = distinct(concat(local.default_service_apis, var.activate_apis))

  # Generate project ID with optional random suffix
  project_id = var.random_project_id ? "${var.project_id}-${random_id.project_suffix[0].hex}" : var.project_id

  # Add managed_by label and merge with user labels
  labels = merge(
    var.labels,
    {
      managed_by = "opentofu"
      created_at = formatdate("YYYY-MM-DD", timestamp())
    }
  )

  # Check if shared VPC attachment is needed
  shared_vpc_enabled = var.shared_vpc_host_project_id != null

  # Service account configuration
  create_service_account = var.create_project_sa
}

# Generate random suffix for project ID if enabled
resource "random_id" "project_suffix" {
  count       = var.random_project_id ? 1 : 0
  byte_length = var.random_project_id_length

  keepers = {
    project_id = var.project_id
  }
}

# Create the main project
resource "google_project" "project" {
  name                = var.name
  project_id          = local.project_id
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = var.auto_create_network
  labels              = local.labels

  # Prevent accidental project deletion
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      labels["created_at"] # Ignore timestamp changes on subsequent applies
    ]
  }
}

# Enable required APIs and services
resource "google_project_service" "service_apis" {
  for_each = toset(local.service_apis)

  project                    = google_project.project.project_id
  service                    = each.value
  disable_on_destroy         = var.disable_services_on_destroy
  disable_dependent_services = var.disable_dependent_services

  # Ensure project is created before enabling services
  depends_on = [google_project.project]
}

# Create project service account if requested
resource "google_service_account" "project_service_account" {
  count = local.create_service_account ? 1 : 0

  project      = google_project.project.project_id
  account_id   = var.project_sa_name
  display_name = "${var.project_sa_name} for ${google_project.project.name}"
  description  = "Service account for project ${google_project.project.project_id}"

  depends_on = [google_project_service.service_apis]
}

# Assign roles to the project service account
resource "google_project_iam_member" "service_account_roles" {
  for_each = local.create_service_account ? toset(var.project_sa_roles) : []

  project = google_project.project.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.project_service_account[0].email}"

  depends_on = [google_service_account.project_service_account]
}

# Assign custom IAM roles to members
resource "google_project_iam_member" "project_iam" {
  for_each = {
    for binding in var.iam_members : "${binding.role}/${binding.member}" => binding
  }

  project = google_project.project.project_id
  role    = each.value.role
  member  = each.value.member

  depends_on = [google_project_service.service_apis]
}

# Assign conditional IAM roles if specified
resource "google_project_iam_member" "project_iam_conditional" {
  for_each = {
    for binding in var.iam_members_conditional : "${binding.role}/${binding.member}/${binding.condition.title}" => binding
  }

  project = google_project.project.project_id
  role    = each.value.role
  member  = each.value.member

  condition {
    title       = each.value.condition.title
    description = each.value.condition.description
    expression  = each.value.condition.expression
  }

  depends_on = [google_project_service.service_apis]
}

# Attach project to shared VPC if specified
resource "google_compute_shared_vpc_service_project" "shared_vpc_attachment" {
  count = local.shared_vpc_enabled ? 1 : 0

  host_project    = var.shared_vpc_host_project_id
  service_project = google_project.project.project_id

  # Ensure compute API is enabled before attaching to shared VPC
  depends_on = [google_project_service.service_apis]
}
