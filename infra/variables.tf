# =============================================================================
# ZenMarket Platform - Terraform Variables
# =============================================================================
# This file defines all input variables for the ZenMarket infrastructure.
# Copy terraform.tfvars.example to terraform.tfvars and fill in your values.
# =============================================================================

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "The GCP region for regional resources (e.g., Cloud Run, Storage)"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"
}

# -----------------------------------------------------------------------------
# Application Configuration
# -----------------------------------------------------------------------------

variable "app_name" {
  description = "The name of the application (used in resource naming)"
  type        = string
  default     = "zenmarket"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,38}[a-z0-9]$", var.app_name))
    error_message = "App name must be lowercase alphanumeric with hyphens allowed."
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# -----------------------------------------------------------------------------
# Firestore Configuration
# -----------------------------------------------------------------------------

variable "firestore_location" {
  description = "Location for Firestore database. See: https://cloud.google.com/firestore/docs/locations"
  type        = string
  default     = "us-central"
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "storage_class" {
  description = "Storage class for the Cloud Storage bucket (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "storage_uniform_bucket_access" {
  description = "Enable uniform bucket-level access for Cloud Storage bucket"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Labels (for resource organization and cost tracking)
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# Computed labels - merges user labels with standard labels
locals {
  common_labels = merge(
    {
      app         = var.app_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.labels
  )
}
