terraform {
  required_version = ">= 1.8.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # backend "gcs" {
  #   # Backend configuration will be provided via -backend-config flags or backend.hcl
  #   # bucket = "your-terraform-state-bucket"
  #   # prefix = "terraform/state"
  # }

  # Using local backend for sandbox testing
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
