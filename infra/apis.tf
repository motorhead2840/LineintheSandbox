# =============================================================================
# ZenMarket Platform - GCP API Enablement
# =============================================================================
# This file enables all required Google Cloud APIs for the ZenMarket platform.
# APIs must be enabled before resources can be created.
# =============================================================================

# List of required APIs for the ZenMarket platform
locals {
  required_apis = [
    "run.googleapis.com",                  # Cloud Run - for containerized app hosting
    "firestore.googleapis.com",            # Firestore - NoSQL database
    "aiplatform.googleapis.com",           # Vertex AI - AI/ML services
    "secretmanager.googleapis.com",        # Secret Manager - secure secret storage
    "cloudbuild.googleapis.com",           # Cloud Build - CI/CD pipeline
    "artifactregistry.googleapis.com",     # Artifact Registry - container image storage
    "storage.googleapis.com",              # Cloud Storage - object storage
    "iam.googleapis.com",                  # IAM - identity and access management
    "cloudresourcemanager.googleapis.com", # Resource Manager - project management
  ]
}

# Enable required APIs
# Note: API enablement can take a few minutes to propagate
resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  project = var.project_id
  service = each.value

  # Don't disable the API when the resource is destroyed
  # This prevents accidental deletion of user data
  disable_on_destroy = false

  # Disable dependent services check to speed up deployment
  disable_dependent_services = false
}

# Wait for APIs to be enabled before creating dependent resources
# Other resources should depend on this using: depends_on = [google_project_service.apis]
