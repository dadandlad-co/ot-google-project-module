output "platform_project_id" {
  description = "The project ID for the Dad and Lad platform"
  value       = module.book_review_platform.project_id
}

output "platform_project_number" {
  description = "The project number for the Dad and Lad platform"
  value       = module.book_review_platform.number
}

output "platform_service_account_email" {
  description = "Service account email for the platform"
  value       = module.book_review_platform.service_account_email
}

output "enabled_apis" {
  description = "List of APIs enabled for the platform"
  value       = module.book_review_platform.enabled_apis
}

output "budget_id" {
  description = "The budget ID for cost monitoring"
  value       = module.platform_budget.budget_id
}

output "budget_alert_topic" {
  description = "Pub/Sub topic for budget alerts"
  value       = module.platform_budget.created_pubsub_topic
}

output "platform_config" {
  description = "Complete platform configuration for use by other modules"
  value = {
    project_id            = module.book_review_platform.project_id
    project_number        = module.book_review_platform.number
    service_account_email = module.book_review_platform.service_account_email
    region               = "us-west1"
    storage_bucket_prefix = "dnlc-book-platform"
    enabled_apis         = module.book_review_platform.enabled_apis
    budget_topic         = module.platform_budget.created_pubsub_topic
  }
  sensitive = false
}

# Outputs for integration with n8n workflow
output "n8n_integration_config" {
  description = "Configuration values for n8n workflow integration"
  value = {
    gcp_project_id        = module.book_review_platform.project_id
    service_account_email = module.book_review_platform.service_account_email
    region               = "us-west1"
    
    # Cloud Functions endpoints (will be created by other modules)
    epub_processor_url    = "https://us-west1-${module.book_review_platform.project_id}.cloudfunctions.net/extract-epub-content"
    video_generator_url   = "https://us-west1-${module.book_review_platform.project_id}.cloudfunctions.net/generate-video"
    
    # AI service endpoints
    gemini_endpoint       = "https://us-central1-aiplatform.googleapis.com/v1/projects/${module.book_review_platform.project_id}/locations/us-central1/publishers/google/models/gemini-1.5-pro:predict"
    
    # Storage locations
    book_upload_bucket    = "${local.platform_config.storage_bucket_prefix}-uploads"
    media_assets_bucket   = "${local.platform_config.storage_bucket_prefix}-media"
    
    # Firestore database
    firestore_database    = "(default)"
  }
  sensitive = false
}