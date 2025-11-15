# Test the main Terraform configuration
run "verify_configuration_valid" {
  command = plan

  variables {
    project_id = "test-project-123"
    region     = "us-central1"
  }

  assert {
    condition     = var.project_id == "test-project-123"
    error_message = "Project ID should be set correctly"
  }

  assert {
    condition     = var.region == "us-central1"
    error_message = "Region should be set correctly"
  }
}

run "verify_outputs" {
  command = plan

  variables {
    project_id = "test-project-456"
    region     = "us-east1"
  }

  assert {
    condition     = output.project_id == "test-project-456"
    error_message = "Output project_id should match input variable"
  }

  assert {
    condition     = output.region == "us-east1"
    error_message = "Output region should match input variable"
  }
}

run "verify_default_region" {
  command = plan

  variables {
    project_id = "test-project-789"
  }

  assert {
    condition     = output.region == "us-central1"
    error_message = "Default region should be us-central1"
  }
}
