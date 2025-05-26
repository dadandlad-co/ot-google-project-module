# Google Cloud Monitoring Module

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/dadandlad.co)

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![OpenTofu Validate](https://github.com/dadandlad-co/ot-google-project-module/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/dadandlad-co/ot-google-project-module/actions/workflows/terraform-validate.yml)

This Terraform module configures monitoring resources for Google Cloud Platform projects, including alert
policies, notification channels, and dashboards.

## Features

- Creates default and custom alert policies for common metrics
- Configures notification channels for email and Slack
- Sets up uptime checks for HTTP endpoints
- Deploys pre-configured dashboards
- Monitors budget burn rates and quota usage

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| google | >= 6.24.0 |

## Usage

```hcl
module "monitoring" {
  source = "path/to/modules/monitoring"

  project_id         = "my-gcp-project"
  notification_emails = ["alerts@example.com"]

  slack_channels = {
    ops = {
      channel = "#ops-alerts"
      url     = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
    }
  }

  # Optional: Configure custom thresholds
  cpu_threshold    = 85
  memory_threshold = 90
  alert_duration   = 300
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID where monitoring resources will be created | `string` | n/a | yes |
| notification_emails | List of email addresses to receive alerts | `list(string)` | `[]` | no |
| slack_channels | Map of Slack channels for notifications | `map(object)` | `{}` | no |
| enable_default_alerts | Whether to create default alert policies for common metrics | `bool` | `true` | no |
| cpu_threshold | CPU usage threshold percentage for alerts | `number` | `80` | no |
| memory_threshold | Memory usage threshold percentage for alerts | `number` | `85` | no |
| alert_duration | Duration in seconds before triggering an alert | `number` | `300` | no |
| auto_close_duration | Duration in seconds to auto-close alerts | `number` | `86400` | no |
| custom_alert_policies | Map of custom alert policies to create | `map(object)` | `{}` | no |
| uptime_checks | Map of uptime checks to create | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| notification_channels | Map of notification channel names to their IDs |
| alert_policy_ids | Map of alert policy names to their IDs |
| uptime_check_ids | Map of uptime check names to their IDs |
| project_id | The project ID where monitoring resources were created |

## Alert Policies

The module includes several predefined alert policies:

- **Budget Burn Rate**: Monitors project spending rate
- **Project API Errors**: Alerts on high API error rates
- **Quota Usage**: Monitors resource quota consumption

Custom alert policies can be defined using the `custom_alert_policies` variable.

## Dashboards

The module includes a project overview dashboard that displays key metrics for the GCP project.

## License

This module is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

## Authors

Maintained by [dadandlad-co](https://github.com/dadandlad-co).

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history and changes.

## Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/dadandlad-co/ot-github-repo-module/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/dadandlad-co/ot-github-repo-module/discussions)
- ☕ **Support**: [Buy Me a Coffee](https://buymeacoffee.com/dadandlad.co)
