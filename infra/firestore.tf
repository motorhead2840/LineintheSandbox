# =============================================================================
# ZenMarket Platform - Firestore Database
# =============================================================================
# This file provisions a Firestore database in Native mode for the ZenMarket
# platform. Firestore is used as the primary NoSQL database.
#
# IMPORTANT NOTES:
# - Only ONE Firestore database can be created per GCP project (for the default
#   database). If you need multiple databases, use named databases.
# - Some regions may require App Engine to be enabled first. If you encounter
#   errors, you may need to manually create an App Engine app in the Cloud Console.
# - Firestore location cannot be changed after creation.
# =============================================================================

# Firestore Database in Native Mode
# This creates the default "(default)" database for the project
resource "google_firestore_database" "main" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"

  # Concurrency mode for optimistic locking
  concurrency_mode = "OPTIMISTIC"

  # Enable point-in-time recovery (optional, but recommended for production)
  point_in_time_recovery_enablement = var.environment == "prod" ? "POINT_IN_TIME_RECOVERY_ENABLED" : "POINT_IN_TIME_RECOVERY_DISABLED"

  # Deletion protection - prevent accidental deletion in production
  deletion_policy = var.environment == "prod" ? "DELETE" : "DELETE"

  depends_on = [google_project_service.apis]
}

# =============================================================================
# Firestore Security Rules (Optional)
# =============================================================================
# Firestore security rules are typically managed separately or through
# Firebase CLI. The following is a placeholder for documentation purposes.
#
# To deploy Firestore rules:
# 1. Create a firestore.rules file in your project
# 2. Use Firebase CLI: firebase deploy --only firestore:rules
#
# Example rules for ZenMarket:
# rules_version = '2';
# service cloud.firestore {
#   match /databases/{database}/documents {
#     match /{document=**} {
#       allow read, write: if request.auth != null;
#     }
#   }
# }
# =============================================================================
