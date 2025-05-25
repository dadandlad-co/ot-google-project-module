# Dad and Lad Co Platform - AI-Powered Book Review Platform Configuration
# This example shows the specific configuration for the book review platform

module "book_review_platform" {
  source = "../../modules/project"

  name            = "Dad and Lad Book Review Platform"
  project_id      = "dnlc-admin-46f6"
  org_id          = var.org_id
  billing_account = var.billing_account

  # APIs specifically needed for the book review platform
  activate_apis = [
    # Core platform APIs
    "compute.googleapis.com",           # For Cloud Run, Cloud Functions
    "storage.googleapis.com",           # For EPUB storage and media assets
    "cloudfunctions.googleapis.com",    # For EPUB processing
    "run.googleapis.com",               # For containerized services
    "cloudbuild.googleapis.com",        # For CI/CD pipeline
    
    # AI and ML APIs
    "aiplatform.googleapis.com",        # For Vertex AI (Gemini)
    "texttospeech.googleapis.com",      # For voice generation
    "speech.googleapis.com",            # For voice processing
    
    # Database and messaging
    "firestore.googleapis.com",         # For book metadata storage
    "pubsub.googleapis.com",            # For async processing
    
    # Monitoring and automation
    "monitoring.googleapis.com",        # For performance monitoring
    "logging.googleapis.com",           # For application logs
    "cloudscheduler.googleapis.com",    # For scheduled tasks
    "secretmanager.googleapis.com",     # For API keys and credentials
    
    # YouTube and social media APIs (if using GCP for proxying)
    "youtube.googleapis.com",           # For YouTube uploads
  ]

  # Create service account for the platform
  create_project_sa = true
  project_sa_name   = "book-review-platform-sa"
  project_sa_roles = [
    "roles/storage.admin",              # Full access to Cloud Storage
    "roles/cloudfunctions.admin",       # Deploy and manage functions
    "roles/run.admin",                  # Deploy Cloud Run services
    "roles/firestore.user",             # Read/write Firestore
    "roles/pubsub.editor",              # Pub/Sub operations
    "roles/aiplatform.user",            # Vertex AI access
    "roles/secretmanager.secretAccessor", # Access stored credentials
    "roles/monitoring.metricWriter",     # Write monitoring metrics
    "roles/logging.logWriter",          # Write application logs
    "roles/cloudscheduler.admin",       # Manage scheduled jobs
  ]

  # IAM for platform team and automation
  iam_members = [
    {
      role   = "roles/owner"
      member = "user:${var.platform_owner_email}"
    },
    {
      role   = "roles/editor"
      member = "user:${var.developer_email}"
    },
    # CI/CD service account access
    {
      role   = "roles/cloudbuild.builds.editor"
      member = "serviceAccount:${var.cicd_service_account}"
    },
    # Monitoring access for operations team
    {
      role   = "roles/monitoring.viewer"
      member = "group:${var.ops_team_group}"
    }
  ]

  # Platform-specific labels for cost tracking and management
  labels = {
    environment = var.environment
    application = "gay-romance-book-reviews"
    team        = "dad-and-lad"
    cost_center = "platform"
    automation  = "ai-powered"
    purpose     = "content-generation"
  }

  # Don't auto-create default network - we'll manage networking separately
  auto_create_network = false
}

# Budget management for the platform
module "platform_budget" {
  source = "../../modules/billing-budget"

  billing_account = var.billing_account
  display_name    = "Dad and Lad Platform Budget"
  amount          = var.monthly_budget_amount
  currency_code   = "USD"

  # Monitor the platform project
  project_ids = [module.book_review_platform.number]

  # Conservative budget alerts for cost control
  alert_spend_thresholds = [0.6, 0.8, 0.9, 1.0]
  spend_basis           = "CURRENT_SPEND"

  # Email alerts to platform team
  alert_email_addresses = [
    var.platform_owner_email,
    var.finance_contact_email
  ]

  # Pub/Sub topic for automated budget responses
  create_pubsub_topic   = true
  pubsub_topic_name     = "platform-budget-alerts"
  pubsub_topic_project  = module.book_review_platform.project_id

  # Filter to include all credits in budget calculations
  credit_types_treatment = "INCLUDE_ALL_CREDITS"

  depends_on = [module.book_review_platform]
}

# Output important information for other infrastructure modules
locals {
  platform_config = {
    project_id     = module.book_review_platform.project_id
    project_number = module.book_review_platform.number
    service_account_email = module.book_review_platform.service_account_email
    
    # Key resources for the platform
    storage_bucket_prefix = "dnlc-book-platform"
    region               = "us-west1"  # From platform-tools.txt
    
    # APIs that are now enabled
    enabled_apis = module.book_review_platform.enabled_apis
  }
}