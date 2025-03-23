# Template repo for OpenTofu modules

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/dadandlad.co)

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![Actions Status](https://github.com/dadandlad-co/ot-google-project-module/workflows/terraform/badge.svg)](https://github.com/dadandlad-co/ot-google-project-module/actions)

This repository contains my template for creating OpenTofu modules, yes even my
root modules. This template is based on the best practices I have learned and
the
[OpenTofu style guide](https://opentofu.org/docs/v1.8/language/syntax/style/).

# Google Project OpenTofu Module

This OpenTofu module creates and manages Google Cloud Platform (GCP) projects with associated services, APIs, IAM permissions, and organizational policies.

## Features

- Creates a new GCP project with configurable name and project ID
- Enables required Google Cloud APIs and services
- Configures project-level IAM permissions
- Sets up organization policies at the project level
- Manages project-level service accounts
- Configures project labels for resource organization
- Implements billing account association

## Usage

```hcl
module "gcp_project" {
  source = "github.com/dadandlad-co/ot-google-project-module"

  project_name    = "my-awesome-project"
  project_id      = "my-awesome-project-id"
  org_id          = "123456789"
  billing_account = "ABCDEF-123456-GHIJKL"

  # List of APIs to enable
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com"
  ]

  # IAM Bindings
  iam_members = {
    "roles/viewer" = [
      "user:jane@example.com",
    ],
    "roles/editor" = [
      "user:john@example.com",
      "serviceAccount:my-service-account@my-project.iam.gserviceaccount.com"
    ]
  }

  # Project Labels
  labels = {
    environment = "development"
    team        = "platform"
    application = "shared-infrastructure"
  }

  # Organization policies
  org_policies = {
    "constraints/compute.disableSerialPortAccess" = {
      enforce = true
    },
    "constraints/iam.allowedPolicyMemberDomains" = {
      allow = {
        values = ["C0xxxxxxx", "C0yyyyyyy"]
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.6.0 |
| google | >= 5.0.0 |
| google-beta | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 5.0.0 |
| google-beta | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate_apis | The list of APIs to activate within the project | `list(string)` | `[]` | no |
| auto_create_network | Auto-create the default network during project creation | `bool` | `false` | no |
| billing_account | The ID of the billing account to associate with this project | `string` | n/a | yes |
| disable_dependent_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed | `bool` | `true` | no |
| folder_id | The ID of a folder to host this project (optional) | `string` | `""` | no |
| iam_members | Map of role => list of members to add the IAM policy for the project | `map(list(string))` | `{}` | no |
| labels | Map of labels for project | `map(string)` | `{}` | no |
| org_id | The organization ID | `string` | n/a | yes |
| org_policies | Organization policies applied to this project | `any` | `{}` | no |
| project_id | The ID to give the project. If not provided, the `project_name` will be used | `string` | `""` | no |
| project_name | The name for the project | `string` | n/a | yes |
| random_project_id | Adds a suffix of random characters to the `project_id` | `bool` | `false` | no |
| random_project_id_length | Sets the length of random characters added to `project_id` | `number` | `4` | no |

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

## Contributing

Contributions to this module are welcome! Please see our [contributing guidelines](CONTRIBUTING.md) for more information.

## License

This module is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for full details.
