# Google Project OpenTofu Module

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/dadandlad.co)

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![OpenTofu Validate](https://github.com/dadandlad-co/ot-google-project-module/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/dadandlad-co/ot-google-project-module/actions/workflows/terraform-validate.yml)

This OpenTofu module creates and manages Google Cloud Platform (GCP) projects with comprehensive features including API management, IAM configuration, service accounts, shared VPC attachment, and optional billing budget management.

## Features

- **Project Creation**: Creates GCP projects with proper validation and lifecycle management
- **API Management**: Enables required APIs with dependency handling (includes essential APIs by default)
- **IAM Management**: Supports both standard and conditional IAM policies using the member approach
- **Service Accounts**: Optional project service account creation with configurable roles
- **Random ID Support**: Optional random suffix for unique project IDs
- **Shared VPC**: Automatic attachment to shared VPC host projects
- **Budget Management**: Separate billing budget module with comprehensive alerting
- **Comprehensive Validation**: Extensive input validation to catch errors early
- **Labels & Metadata**: Automatic labeling with custom label support

## Modules

### Project Module (`modules/project`)

Creates and manages GCP projects with all essential features.

### Billing Budget Module (`modules/billing-budget`)

Creates and manages billing budgets with alerts and notifications.

## Quick Start

### Basic Project Creation

```hcl
module "my_project" {
  source = "github.com/dadandlad-co/ot-google-project-module//modules/project"

  name            = "My Awesome Project"
  project_id      = "my-awesome-project"
  org_id          = "123456789012"
  billing_account = "ABCDEF-123456-GHIJKL"

  activate_apis = [
    "compute.googleapis.com",
    "storage.googleapis.com"
  ]

  labels = {
    environment = "development"
    team        = "platform"
  }
}
```

### Project with Budget

```hcl
module "project_with_budget" {
  source = "github.com/dadandlad-co/ot-google-project-module//modules/project"

  name            = "Production Project"
  project_id      = "prod-project"
  org_id          = "123456789012"
  billing_account = "ABCDEF-123456-GHIJKL"

  random_project_id = true  # Adds random suffix

  create_project_sa = true
  project_sa_roles = [
    "roles/storage.admin",
    "roles/monitoring.metricWriter"
  ]
}

module "project_budget" {
  source = "github.com/dadandlad-co/ot-google-project-module//modules/billing-budget"

  billing_account = "ABCDEF-123456-GHIJKL"
  display_name    = "Production Budget"
  amount          = 1000

  project_ids = [module.project_with_budget.number]

  alert_spend_thresholds = [0.6, 0.8, 0.9, 1.0]
  alert_email_addresses  = ["admin@example.com"]
}
```

## Default APIs

The project module automatically enables these essential APIs:
- `cloudresourcemanager.googleapis.com` - Project management
- `cloudbilling.googleapis.com` - Billing operations
- `iam.googleapis.com` - IAM operations
- `serviceusage.googleapis.com` - API management

## Examples

### Simple Example
Basic project creation with minimal configuration.
- **Location**: `examples/simple/`
- **Use case**: Development projects, testing

### Complete Example
Comprehensive project setup with all features enabled.
- **Location**: `examples/complete/`
- **Use case**: Production projects with full IAM, budgets, and monitoring

### Dad and Lad Platform Example
Real-world configuration for an AI-powered book review platform.
- **Location**: `examples/dad-and-lad-platform/`
- **Use case**: Platform-specific setup with AI APIs, content generation services

## Development Workflow

This module includes a comprehensive `Taskfile.yaml` for development automation:

```bash
# Set up development environment
task dev-setup

# Validate all modules and examples
task validate

# Run comprehensive tests
task test

# Format all files
task fmt

# Generate documentation
task docs

# Run security scans
task security-scan
```

## Module Inputs

### Project Module

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Project display name | `string` | n/a | yes |
| `project_id` | Unique project ID | `string` | n/a | yes |
| `org_id` | Organization ID | `string` | `null` | no |
| `billing_account` | Billing account ID | `string` | n/a | yes |
| `activate_apis` | Additional APIs to enable | `list(string)` | `[]` | no |
| `random_project_id` | Add random suffix | `bool` | `false` | no |
| `create_project_sa` | Create service account | `bool` | `false` | no |
| `iam_members` | IAM member bindings | `list(object)` | `[]` | no |
| `labels` | Project labels | `map(string)` | `{}` | no |

### Budget Module

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `billing_account` | Billing account ID | `string` | n/a | yes |
| `display_name` | Budget display name | `string` | n/a | yes |
| `amount` | Budget amount | `number` | n/a | yes |
| `project_ids` | Projects to monitor | `list(string)` | `[]` | no |
| `alert_spend_thresholds` | Alert thresholds | `list(number)` | `[0.5,0.8,0.9,1.0]` | no |
| `alert_email_addresses` | Email alerts | `list(string)` | `[]` | no |

## Module Outputs

### Project Module

| Name | Description |
|------|-------------|
| `project_id` | The project ID |
| `project_number` | The project number |
| `service_account_email` | Service account email (if created) |
| `enabled_apis` | List of enabled APIs |

### Budget Module

| Name | Description |
|------|-------------|
| `budget_id` | The budget ID |
| `budget_name` | The budget name |
| `created_pubsub_topic` | Created Pub/Sub topic |

## Validation Features

This module includes comprehensive validation:

- **Project ID format**: Validates GCP project ID naming rules
- **Billing account format**: Ensures proper billing account ID format
- **Email addresses**: Validates email format for IAM members
- **API names**: Ensures valid Google API endpoints
- **Resource limits**: Validates lengths and ranges
- **IAM roles**: Ensures roles start with `roles/`

## Security Features

- **Prevent destroy**: Projects have lifecycle protection
- **IAM member approach**: Uses `google_project_iam_member` to avoid conflicts
- **Secret scanning**: TruffleHog integration
- **Security scanning**: tfsec and Checkov integration
- **Least privilege**: Service accounts with minimal required permissions

## Best Practices

1. **Use random suffixes** for development projects to avoid naming conflicts
2. **Enable budgets** for all projects to control costs
3. **Use specific API lists** rather than enabling everything
4. **Apply consistent labeling** for cost tracking and management
5. **Use conditional IAM** for temporary access requirements
6. **Validate inputs** using the provided validation rules

## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.9.0 |
| google | >= 6.24.0 |
| random | >= 3.7.1 |

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This module is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for details.

## Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/dadandlad-co/ot-google-project-module/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/dadandlad-co/ot-google-project-module/discussions)
- ☕ **Support**: [Buy Me a Coffee](https://buymeacoffee.com/dadandlad.co)
