# =============================================================================
# ZenMarket Platform - Secret Manager
# =============================================================================
# This file creates Secret Manager secrets for the ZenMarket platform.
# Secrets are created with placeholder values that should be updated after
# deployment via the GCP Console or gcloud CLI.
#
# IMPORTANT: Never commit actual secret values to version control!
# =============================================================================

# List of secrets required by the ZenMarket application
locals {
  secrets = {
    "STRIPE_SECRET_KEY" = {
      description = "Stripe API secret key for payment processing"
    }
    "BTC_NODE_RPC_PASSWORD" = {
      description = "Bitcoin node RPC password for cryptocurrency transactions"
    }
    "BTC_WALLET_XPRIV" = {
      description = "Bitcoin wallet extended private key (xpriv) for HD wallet derivation"
    }
  }
}

# Create secrets in Secret Manager
resource "google_secret_manager_secret" "secrets" {
  for_each = local.secrets

  project   = var.project_id
  secret_id = "${var.app_name}-${lower(replace(each.key, "_", "-"))}-${var.environment}"

  # Replication policy - automatic replication across regions
  replication {
    auto {}
  }

  labels = merge(
    local.common_labels,
    {
      secret_name = lower(replace(each.key, "_", "-"))
    }
  )

  depends_on = [google_project_service.apis]
}

# Create initial placeholder versions for each secret
# These should be updated with real values after deployment
resource "google_secret_manager_secret_version" "placeholder" {
  for_each = google_secret_manager_secret.secrets

  secret      = each.value.id
  secret_data = "PLACEHOLDER_VALUE_UPDATE_AFTER_DEPLOY"

  # Lifecycle to prevent accidental updates if managed externally
  lifecycle {
    ignore_changes = [secret_data]
  }
}

# Grant the app service account access to read secrets
resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each = google_secret_manager_secret.secrets

  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.app.email}"

  depends_on = [
    google_secret_manager_secret.secrets,
    google_service_account.app
  ]
}

# =============================================================================
# Post-Deployment Instructions
# =============================================================================
# After running terraform apply, update the secret values using gcloud:
#
# gcloud secrets versions add zenmarket-stripe-secret-key-dev \
#   --data-file=/path/to/stripe-key.txt
#
# gcloud secrets versions add zenmarket-btc-node-rpc-password-dev \
#   --data-file=/path/to/btc-password.txt
#
# gcloud secrets versions add zenmarket-btc-wallet-xpriv-dev \
#   --data-file=/path/to/btc-xpriv.txt
#
# Or use the GCP Console: Secret Manager > Select Secret > New Version
# =============================================================================
