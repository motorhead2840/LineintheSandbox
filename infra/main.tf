# =============================================================================
# ZenMarket Platform - Main Terraform Configuration
# =============================================================================
# This file contains the main Terraform configuration for the ZenMarket GCP
# infrastructure. It sets up the required providers and backend configuration.
# =============================================================================

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend configuration for storing Terraform state in GCS
  # Override with -backend-config flags or backend.hcl file
  backend "gcs" {
    # Example: terraform init -backend-config="bucket=your-terraform-state-bucket" -backend-config="prefix=zenmarket/state"
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Configure the Google Cloud Beta provider (required for some resources)
provider "google-beta" {
  project = var.project_id
  region  = var.region
}
