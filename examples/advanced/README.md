# Complete Project Example

This example demonstrates a comprehensive configuration of the Google Project module, including:

- Project creation with random ID suffix to prevent naming conflicts
- Placing the project in a specific folder
- Enabling multiple Google Cloud APIs
- Setting detailed project labels
- Configuring IAM permissions for multiple members and roles
- Disabling default network creation

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
| service_account_id | The ID of the default service account |
| enabled_apis | List of APIs enabled in the project |
| enabled_api_services | Map of active services with their details |