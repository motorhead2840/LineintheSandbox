# =============================================================================
# ZenMarket Platform - Artifact Registry
# =============================================================================
# This file creates an Artifact Registry Docker repository for storing
# container images used by the ZenMarket application.
# =============================================================================

# Docker repository for container images
resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.app_name}-docker-${var.environment}"
  description   = "Docker repository for ${var.app_name} container images (${var.environment})"
  format        = "DOCKER"

  # Docker-specific configuration
  docker_config {
    immutable_tags = var.environment == "prod"
  }

  # Cleanup policies (optional - helps manage storage costs)
  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "2592000s" # 30 days
    }
  }

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  labels = local.common_labels

  depends_on = [google_project_service.apis]
}

# Grant the app service account permission to read from the repository
resource "google_artifact_registry_repository_iam_member" "app_reader" {
  project    = var.project_id
  location   = google_artifact_registry_repository.docker.location
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.app.email}"

  depends_on = [
    google_artifact_registry_repository.docker,
    google_service_account.app
  ]
}

# Grant Cloud Build service account permission to push images
# This allows Cloud Build to push container images to the repository
resource "google_artifact_registry_repository_iam_member" "cloudbuild_writer" {
  project    = var.project_id
  location   = google_artifact_registry_repository.docker.location
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.project_id}@cloudbuild.gserviceaccount.com"

  depends_on = [google_artifact_registry_repository.docker]
}
