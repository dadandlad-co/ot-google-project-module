/**
 * # Google Cloud Project Module
 *
 * This module creates and manages Google Cloud Platform projects with support for optional random ID suffix,
 * consistent IAM permissions management using IAM member style, and integration with billing accounts.
 */

locals {
  random_id_enabled      = var.random_id == null ? false : true
  project_id             = local.random_id_enabled ? "${var.project_id}-${random_id.project_suffix[0].hex}" : var.project_id
  create_project_sa      = var.create_project_sa == true ? 1 : 0
  default_service_apis   = []
  service_apis           = concat(local.default_service_apis, var.activate_apis)
  labels                 = merge(var.labels, { managed_by = "opentofu" })
  svpc_host_project_required = var.shared_vpc_host_project_id != null
}

resource "random_id" "project_suffix" {
  count       = local.random_id_enabled ? 1 : 0
  byte_length = var.random_id.byte_length
  prefix      = var.random_id.prefix
}

resource "google_project" "this" {
  name                = var.name
  project_id          = local.project_id
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = var.auto_create_network
  labels              = local.labels

  # lifecycle {
  #   prevent_destroy = var.prevent_destroy != null ? var.prevent_destroy : false
  # }
}

resource "google_project_service" "service_apis" {
  for_each = toset(local.service_apis)

  project                    = google_project.this.project_id
  service                    = each.value
  disable_on_destroy         = var.disable_services_on_destroy
  disable_dependent_services = var.disable_dependent_services
}

resource "google_service_account" "project_service_account" {
  count        = local.create_project_sa
  account_id   = var.project_sa_name
  display_name = var.project_sa_name
  description  = "Project service account for ${google_project.this.project_id}"
  project      = google_project.this.project_id
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = var.create_project_sa ? toset(var.project_sa_roles) : []

  project = google_project.this.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.project_service_account[0].email}"
}

# Optional shared VPC connection
resource "google_compute_shared_vpc_service_project" "shared_vpc_attachment" {
  count           = local.svpc_host_project_required ? 1 : 0
  host_project    = var.shared_vpc_host_project_id
  service_project = google_project.this.project_id

  depends_on = [
    google_project_service.service_apis
  ]
}

# Custom IAM role assignments using iam_member style
resource "google_project_iam_member" "project_iam" {
  for_each = {
    for binding in var.iam_members : "${binding.role}/${binding.member}" => binding
  }

  project = google_project.this.project_id
  role    = each.value.role
  member  = each.value.member
}

# Budget alert configuration if budget_alert_pubsub_topic is provided
resource "google_billing_budget" "budget" {
  count            = var.budget_amount != null ? 1 : 0
  billing_account  = var.billing_account
  display_name     = var.budget_display_name != null ? var.budget_display_name : "Budget for ${google_project.this.name}"
  
  amount {
    specified_amount {
      currency_code = var.budget_currency_code
      units         = var.budget_amount
    }
  }

  budget_filter {
    projects = ["projects/${google_project.this.number}"]
  }

  dynamic "threshold_rules" {
    for_each = var.budget_alert_spend_thresholds
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }

  dynamic "all_updates_rule" {
    for_each = var.budget_alert_pubsub_topic != null ? [1] : []
    content {
      pubsub_topic = var.budget_alert_pubsub_topic
    }
  }
}