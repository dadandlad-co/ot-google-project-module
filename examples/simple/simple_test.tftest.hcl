#----------------------------------------------------------------------------
# OpenTofu Tests for Google Project Module - Simple Example
#----------------------------------------------------------------------------

variables {
  test_suffix = "test123" # Use a simple static suffix instead of random_id
}

# Test basic project creation
run "basic_project_test" {
  command = plan

  variables {
    project_name    = "Test Basic Project"
    project_id      = "test-basic-${var.test_suffix}"
    org_id          = "123456789012"
    billing_account = "ABCDEF-123456-GHIJKL"

    labels = {
      environment = "test"
      purpose     = "validation"
    }
  }

  # Test that project is configured correctly
  assert {
    condition     = module.simple_project.project_id != null
    error_message = "Project ID should be generated"
  }

  assert {
    condition     = length(module.simple_project.enabled_apis) >= 2
    error_message = "Should enable at least 2 APIs"
  }
}

# Test project validation
run "project_validation_test" {
  command = plan

  variables {
    project_name    = "Valid Project Name"
    project_id      = "valid-project-id"
    org_id          = "123456789012"
    billing_account = "ABCDEF-123456-GHIJKL"
  }

  assert {
    condition     = module.simple_project.project_name == "Valid Project Name"
    error_message = "Project name should match input"
  }
}