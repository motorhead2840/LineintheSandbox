# =============================================================================
# ZenMarket Platform - Terraform Outputs
# =============================================================================
# This file defines outputs that provide useful information after deployment.
# These values can be used for reference or passed to other systems.
# =============================================================================

# -----------------------------------------------------------------------------
# Project Information
# -----------------------------------------------------------------------------

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "environment" {
  description = "The deployment environment"
  value       = var.environment
}

# -----------------------------------------------------------------------------
# Service Account
# -----------------------------------------------------------------------------

output "service_account_email" {
  description = "Email address of the application service account"
  value       = google_service_account.app.email
}

output "service_account_id" {
  description = "Unique ID of the application service account"
  value       = google_service_account.app.unique_id
}

# -----------------------------------------------------------------------------
# Cloud Storage
# -----------------------------------------------------------------------------

output "content_bucket_name" {
  description = "Name of the Cloud Storage bucket for content/media"
  value       = google_storage_bucket.content.name
}

output "content_bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.content.url
}

# -----------------------------------------------------------------------------
# Firestore
# -----------------------------------------------------------------------------

output "firestore_database_name" {
  description = "Name of the Firestore database"
  value       = google_firestore_database.main.name
}

output "firestore_location" {
  description = "Location of the Firestore database"
  value       = google_firestore_database.main.location_id
}

# -----------------------------------------------------------------------------
# Artifact Registry
# -----------------------------------------------------------------------------

output "docker_repository_name" {
  description = "Name of the Artifact Registry Docker repository"
  value       = google_artifact_registry_repository.docker.name
}

output "docker_repository_url" {
  description = "URL for pushing/pulling Docker images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.name}"
}

# -----------------------------------------------------------------------------
# Secret Manager
# -----------------------------------------------------------------------------

output "secret_ids" {
  description = "Map of secret names to their Secret Manager IDs"
  value = {
    for k, v in google_secret_manager_secret.secrets : k => v.secret_id
  }
}

output "secret_resource_names" {
  description = "Map of secret names to their full resource names"
  value = {
    for k, v in google_secret_manager_secret.secrets : k => v.id
  }
}

# -----------------------------------------------------------------------------
# Deployment Information (for Cloud Run)
# -----------------------------------------------------------------------------

output "cloud_run_deploy_command" {
  description = "Example gcloud command to deploy to Cloud Run"
  value       = <<-EOT
    gcloud run deploy ${var.app_name}-${var.environment} \
      --image=${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.name}/${var.app_name}:latest \
      --platform=managed \
      --region=${var.region} \
      --service-account=${google_service_account.app.email} \
      --set-secrets=STRIPE_SECRET_KEY=${google_secret_manager_secret.secrets["STRIPE_SECRET_KEY"].secret_id}:latest,BTC_NODE_RPC_PASSWORD=${google_secret_manager_secret.secrets["BTC_NODE_RPC_PASSWORD"].secret_id}:latest,BTC_WALLET_XPRIV=${google_secret_manager_secret.secrets["BTC_WALLET_XPRIV"].secret_id}:latest
  EOT
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

output "infrastructure_summary" {
  description = "Summary of created infrastructure resources"
  value       = <<-EOT
    
    ============================================================
    ZenMarket Infrastructure Summary (${var.environment})
    ============================================================
    
    Project ID:          ${var.project_id}
    Region:              ${var.region}
    Environment:         ${var.environment}
    
    Service Account:     ${google_service_account.app.email}
    
    Storage Bucket:      ${google_storage_bucket.content.name}
    
    Firestore Database:  ${google_firestore_database.main.name}
    Firestore Location:  ${google_firestore_database.main.location_id}
    
    Docker Repository:   ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.name}
    
    Secrets Created:     ${join(", ", [for k, v in google_secret_manager_secret.secrets : v.secret_id])}
    
    ============================================================
    NEXT STEPS:
    1. Update secret values in Secret Manager
    2. Build and push your container image to Artifact Registry
    3. Deploy your application to Cloud Run
    ============================================================
  EOT
}
