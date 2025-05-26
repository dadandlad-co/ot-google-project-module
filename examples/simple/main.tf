# Simple example of the Google Project module
# This creates a basic project with minimal configuration

module "simple_project" {
  source = "../../modules/project"

  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account

  # Enable basic APIs for most projects
  activate_apis = [
    "compute.googleapis.com",
    "storage.googleapis.com",
  ]

  # Basic labels
  labels = {
    environment = "development"
    purpose     = "testing"
    team        = "platform"
  }
}
