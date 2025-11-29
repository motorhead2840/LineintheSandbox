# =============================================================================
# ZenMarket Platform - Cloud Storage
# =============================================================================
# This file creates Cloud Storage buckets for the ZenMarket platform.
# The main bucket is used for storing resource/media content.
# =============================================================================

# Generate a unique suffix for bucket names (must be globally unique)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Main content bucket for resource/media storage
resource "google_storage_bucket" "content" {
  name     = "${var.app_name}-content-${var.project_id}-${random_id.bucket_suffix.hex}"
  location = var.region
  project  = var.project_id

  # Storage class configuration
  storage_class = var.storage_class

  # Enable uniform bucket-level access (recommended)
  uniform_bucket_level_access = var.storage_uniform_bucket_access

  # Prevent accidental deletion
  force_destroy = var.environment != "prod"

  # Enable versioning for data protection
  versioning {
    enabled = var.environment == "prod"
  }

  # Lifecycle rules for cost optimization (optional)
  lifecycle_rule {
    condition {
      age = 365 # Days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  # Public access prevention
  public_access_prevention = "enforced"

  # Labels for resource organization
  labels = local.common_labels

  depends_on = [google_project_service.apis]
}

# IAM binding for the service account to access the bucket
# This grants the app service account admin access to objects in the bucket
resource "google_storage_bucket_iam_member" "content_admin" {
  bucket = google_storage_bucket.content.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.app.email}"

  depends_on = [
    google_storage_bucket.content,
    google_service_account.app
  ]
}
