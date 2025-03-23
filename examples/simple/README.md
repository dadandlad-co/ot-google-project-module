# Simple Project Example

This example demonstrates the basic usage of the Google Project module. It creates a simple GCP project with a few APIs enabled and no default network.

## Usage

```bash
# Initialize Terraform
tofu init

# Plan the deployment
tofu plan

# Apply the configuration
tofu apply
```

## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.6.0 |
| google | >= 5.0.0 |
| google-beta | >= 5.0.0 |

## Inputs

No inputs are required for this example. All variables are set directly in the main.tf file.

## Outputs

| Name | Description |
|------|-------------|
| project_id | The ID of the created project |
| project_name | The name of the created project |
| project_number | The numeric identifier of the project |
| service_account_email | The email address of the default service account |