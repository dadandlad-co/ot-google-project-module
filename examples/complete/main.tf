# Complete example showing all features of the Google Project module

module "complete_project" {
  source = "../../modules/project"

  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  folder_id       = var.folder_id

  # Enable random suffix for unique project ID
  random_project_id        = var.random_project_id
  random_project_id_length = 6

  # Comprehensive API list
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
    "firestore.googleapis.com",
    "speech.googleapis.com",
    "texttospeech.googleapis.com",
  ]

  # Create a project service account
  create_project_sa = true
  project_sa_name   = "complete-project-sa"
  project_sa_roles = [
    "roles/storage.admin",
    "roles/cloudsql.client",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
  ]

  # Comprehensive IAM setup
  iam_members = [
    {
      role   = "roles/viewer"
      member = "user:${var.viewer_email}"
    },
    {
      role   = "roles/editor" 
      member = "group:${var.editor_group}"
    },
    {
      role   = "roles/owner"
      member = "user:${var.owner_email}"
    }
  ]

  # Conditional IAM for time-based access
  iam_members_conditional = [
    {
      role   = "roles/compute.admin"
      member = "user:${var.temp_admin_email}"
      condition = {
        title       = "Temporary Admin Access"
        description = "Admin access during business hours"
        expression  = "request.time.getHours() >= 9 && request.time.getHours() <= 17"
      }
    }
  ]

  # Comprehensive labels
  labels = {
    environment = var.environment
    team        = var.team
    cost_center = var.cost_center
    application = var.application
    compliance  = var.compliance_level
  }

  # Shared VPC configuration
  shared_vpc_host_project_id = var.shared_vpc_host_project_id
}

# Create budget for the project using our billing budget module
module "project_budget" {
  source = "../../modules/billing-budget"

  billing_account = var.billing_account
  display_name    = "Budget for ${module.complete_project.name}"
  amount          = var.budget_amount
  currency_code   = "USD"

  # Monitor this specific project
  project_ids = [module.complete_project.number]

  # Alert at multiple thresholds
  alert_spend_thresholds = [0.5, 0.7, 0.9, 1.0, 1.1]

  # Email alerts
  alert_email_addresses = var.budget_alert_emails

  # Pub/Sub alerts for automation
  alert_pubsub_topic = var.budget_pubsub_topic

  depends_on = [module.complete_project]
}