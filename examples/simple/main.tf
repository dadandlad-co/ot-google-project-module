provider "google" {
  region = "us-central1"
}

provider "google-beta" {
  region = "us-central1"
}

module "project" {
  source = "../../"

  project_name    = "simple-project-example"
  project_id      = "simple-project-example"
  org_id          = "123456789012"
  billing_account = "ABCDEF-123456-GHIJKL"
  
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com"
  ]

  auto_create_network = false
}