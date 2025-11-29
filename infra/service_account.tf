# =============================================================================
# ZenMarket Platform - Service Account & IAM
# =============================================================================
# This file creates the service account for the ZenMarket application and
# assigns the necessary IAM roles for accessing GCP services.
# =============================================================================

# Application service account
resource "google_service_account" "app" {
  project      = var.project_id
  account_id   = "${var.app_name}-app-${var.environment}"
  display_name = "${var.app_name} Application Service Account (${var.environment})"
  description  = "Service account for the ${var.app_name} application to access GCP resources"

  depends_on = [google_project_service.apis]
}

# -----------------------------------------------------------------------------
# IAM Role Bindings
# -----------------------------------------------------------------------------
# The following roles are granted to the application service account at the
# project level. Some roles (like storage.objectAdmin) are bound at the
# resource level in their respective files.

# Firestore/Datastore User - allows read/write access to Firestore
resource "google_project_iam_member" "app_datastore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.app.email}"

  depends_on = [google_service_account.app]
}

# Vertex AI User - allows access to Vertex AI services
resource "google_project_iam_member" "app_aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.app.email}"

  depends_on = [google_service_account.app]
}

# Cloud Run Invoker - allows invoking Cloud Run services (if needed for service-to-service calls)
resource "google_project_iam_member" "app_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.app.email}"

  depends_on = [google_service_account.app]
}

# =============================================================================
# Note: The following roles are granted at the resource level in other files:
# - roles/secretmanager.secretAccessor (in secrets.tf)
# - roles/storage.objectAdmin (in storage.tf)
# - roles/artifactregistry.reader (in artifact_registry.tf)
# =============================================================================

# -----------------------------------------------------------------------------
# Service Account Key (Optional - Not recommended for production)
# -----------------------------------------------------------------------------
# Uncomment the following resource if you need to create a service account key
# for local development. For production, use Workload Identity instead.
#
# WARNING: Service account keys are security-sensitive. Store them securely
# and rotate them regularly.

# resource "google_service_account_key" "app_key" {
#   service_account_id = google_service_account.app.name
#   public_key_type    = "TYPE_X509_PEM_FILE"
# }

# output "service_account_key" {
#   description = "Service account key (base64 encoded)"
#   value       = google_service_account_key.app_key.private_key
#   sensitive   = true
# }
