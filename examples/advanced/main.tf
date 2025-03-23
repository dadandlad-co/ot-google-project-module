provider "google" {
  region = "us-central1"
}

provider "google-beta" {
  region = "us-central1"
}

module "project" {
  source = "../../"

  project_name    = "complete-project-example"
  project_id      = "complete-project-example"
  org_id          = "123456789012"
  folder_id       = "456789012345"  # Optional folder to place the project in
  billing_account = "ABCDEF-123456-GHIJKL"
  
  # Set to false to avoid creating a default network
  auto_create_network = false
  
  # Random project ID to avoid conflicts
  random_project_id        = true
  random_project_id_length = 6
  
  # APIs to enable
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
  
  # Don't disable services when they're removed from the list
  disable_dependent_services = false
  
  # Project labels
  labels = {
    environment = "production"
    team        = "platform"
    application = "shared-services"
    cost-center = "123456"
    created-by  = "opentofu"
  }
  
  # IAM members
  iam_members = {
    "roles/viewer" = [
      "user:jane@example.com",
      "group:viewers@example.com",
    ],
    "roles/editor" = [
      "user:john@example.com",
      "serviceAccount:ci-account@another-project.iam.gserviceaccount.com"
    ],
    "roles/compute.admin" = [
      "group:compute-admins@example.com",
    ]
  }
}