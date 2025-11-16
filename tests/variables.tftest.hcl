# Test variable validation and type constraints
run "verify_project_id_required" {
  command = plan

  variables {
    project_id = "valid-project-id"
  }

  assert {
    condition     = var.project_id != null && var.project_id != ""
    error_message = "Project ID must be provided and non-empty"
  }
}

run "verify_region_has_default" {
  command = plan

  variables {
    project_id = "test-project"
  }

  assert {
    condition     = var.region != null
    error_message = "Region should have a default value"
  }
}

run "verify_custom_region" {
  command = plan

  variables {
    project_id = "test-project"
    region     = "europe-west1"
  }

  assert {
    condition     = var.region == "europe-west1"
    error_message = "Custom region should be applied correctly"
  }
}
