# Organization Policies Example

This example demonstrates how to use the Google Project module with organization policies. It creates a GCP project with multiple organization policies to enforce security and governance standards.

## Organization Policies Implemented

This example implements several common organization policies:

- **Compute Engine Constraints**:
  - Disable serial port access
  - Disable guest attributes access
  - Skip default network creation
  - Require OS Login for SSH access

- **IAM Constraints**:
  - Restrict to specific domains
  - Disable service account key creation

- **Storage Constraints**:
  - Enforce uniform bucket-level access

- **Location Constraints**:
  - Restrict resource locations to specific regions

- **Network Constraints**:
  - Prevent VMs from having external IPs

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