variable "activate_apis" {
  description = "List of APIs to activate in addition to the default APIs. Default APIs include: cloudresourcemanager, cloudbilling, iam, and serviceusage."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for api in var.activate_apis : can(regex("^[a-z0-9-]+\\.googleapis\\.com$", api))
    ])
    error_message = "All APIs must be valid Google APIs ending with .googleapis.com"
  }
}

variable "auto_create_network" {
  description = "Whether to create the default network for the project. Set to false for production projects."
  type        = bool
  default     = false
}

variable "billing_account" {
  description = "The alphanumeric ID of the billing account this project belongs to."
  type        = string

  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account)) || can(regex("^[0-9A-F]{6}-[0-9A-F]{6}-[0-9A-F]{6}$", var.billing_account))
    error_message = "The billing_account must be in a valid format (e.g., ABCDEF-123456-GHIJKL)."
  }
}

variable "create_project_sa" {
  description = "Whether to create a dedicated service account for this project."
  type        = bool
  default     = false
}

variable "disable_dependent_services" {
  description = "Whether to disable dependent services when disabling a service. Set to false for production to avoid service disruption."
  type        = bool
  default     = true
}

variable "disable_services_on_destroy" {
  description = "Whether to disable services when the project is destroyed. Set to false for production projects."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "The ID of a folder to host this project. Can be in format 'folders/123456789' or just '123456789'. Leave null to create in organization root."
  type        = string
  default     = null

  validation {
    condition     = var.folder_id == null || can(regex("^(folders/)?\\d+$", var.folder_id))
    error_message = "The folder_id must be null, a numeric string, or in format 'folders/123456789'."
  }
}

variable "iam_members" {
  description = "List of IAM members to add to the project with their roles. Each member should be in format 'user:email@domain.com', 'group:group@domain.com', or 'serviceAccount:sa@project.iam.gserviceaccount.com'."
  type = list(object({
    role   = string
    member = string
  }))
  default = []

  validation {
    condition = alltrue([
      for binding in var.iam_members : can(regex("^roles/", binding.role))
    ])
    error_message = "All roles must start with 'roles/' (e.g., 'roles/viewer', 'roles/editor')."
  }

  validation {
    condition = alltrue([
      for binding in var.iam_members : can(regex("^(user|group|serviceAccount|domain|deleted):", binding.member))
    ])
    error_message = "All members must be in format 'type:identifier'."
  }
}

variable "iam_members_conditional" {
  description = "List of conditional IAM members to add to the project. Allows for advanced IAM policies with conditions."
  type = list(object({
    role   = string
    member = string
    condition = object({
      title       = string
      description = string
      expression  = string
    })
  }))
  default = []

  validation {
    condition = alltrue([
      for binding in var.iam_members_conditional : can(regex("^roles/", binding.role))
    ])
    error_message = "All roles must start with 'roles/'."
  }

  validation {
    condition = alltrue([
      for binding in var.iam_members_conditional : can(regex("^(user|group|serviceAccount|domain):", binding.member))
    ])
    error_message = "All members must be in format 'type:identifier'."
  }
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the project. Note: 'managed_by' and 'created_at' labels are automatically added."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.labels : can(regex("^[a-z]([a-z0-9_-]{0,61}[a-z0-9])?$", k))
    ])
    error_message = "Label keys must be 1-63 characters, start with a letter, and contain only lowercase letters, numbers, hyphens, and underscores."
  }

  validation {
    condition = alltrue([
      for k, v in var.labels : can(regex("^[a-z0-9_-]{0,63}$", v))
    ])
    error_message = "Label values must be 0-63 characters and contain only lowercase letters, numbers, hyphens, and underscores."
  }
}

variable "name" {
  description = "The display name of the project. This is what users see in the GCP Console."
  type        = string

  validation {
    condition     = length(var.name) >= 4 && length(var.name) <= 30
    error_message = "Project name must be between 4 and 30 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\s\\-_\\.]+$", var.name))
    error_message = "Project name can only contain letters, numbers, spaces, hyphens, underscores, and periods."
  }
}

variable "org_id" {
  description = "The numeric ID of the organization this project belongs to. Required unless folder_id is specified."
  type        = string
  default     = null

  validation {
    condition     = var.org_id == null || can(tonumber(var.org_id))
    error_message = "The org_id must be null or a numeric string."
  }
}

variable "project_id" {
  description = "The unique ID for the project. Must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id)) || can(regex("^[a-z][a-z0-9-]{5,29}$", var.project_id))
    error_message = "The project_id must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "project_sa_name" {
  description = "The name of the service account to create for the project. Only used if create_project_sa is true."
  type        = string
  default     = "project-service-account"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_sa_name))
    error_message = "Service account name must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "project_sa_roles" {
  description = "List of IAM roles to assign to the project service account. Only used if create_project_sa is true."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for role in var.project_sa_roles : can(regex("^roles/", role))
    ])
    error_message = "All service account roles must start with 'roles/'."
  }
}

variable "random_project_id" {
  description = "Whether to append a random suffix to the project ID. Useful for avoiding naming conflicts."
  type        = bool
  default     = false
}

variable "random_project_id_length" {
  description = "Length of the random suffix to append to project ID. Only used if random_project_id is true."
  type        = number
  default     = 4

  validation {
    condition     = var.random_project_id_length >= 2 && var.random_project_id_length <= 8
    error_message = "Random project ID length must be between 2 and 8 characters."
  }
}

variable "shared_vpc_host_project_id" {
  description = "The ID of the host project for shared VPC. Leave null if not using shared VPC."
  type        = string
  default     = null

  validation {
    condition     = var.shared_vpc_host_project_id == null || can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.shared_vpc_host_project_id))
    error_message = "Shared VPC host project ID must follow GCP project ID naming conventions."
  }
}
