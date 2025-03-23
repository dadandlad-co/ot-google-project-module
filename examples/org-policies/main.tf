provider "google" {
  region = "us-central1"
}

provider "google-beta" {
  region = "us-central1"
}

module "project" {
  source = "../../"

  project_name    = "org-policies-example"
  project_id      = "org-policies-example"
  org_id          = "123456789012"
  billing_account = "ABCDEF-123456-GHIJKL"
  
  # Basic APIs
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com"
  ]

  # Organization policies
  org_policies = {
    # Boolean constraints
    "constraints/compute.disableSerialPortAccess" = {
      enforce = true
    },
    "constraints/compute.disableGuestAttributesAccess" = {
      enforce = true
    },
    "constraints/compute.skipDefaultNetworkCreation" = {
      enforce = true
    },
    "constraints/compute.requireOsLogin" = {
      enforce = true
    },
    "constraints/storage.uniformBucketLevelAccess" = {
      enforce = true
    },
    
    # List constraints - allow specific values
    "constraints/iam.allowedPolicyMemberDomains" = {
      allow = {
        values = ["C0xxxxxxx", "C0yyyyyyy"]  # Customer IDs for allowed domains
      }
    },
    "constraints/compute.trustedImageProjects" = {
      allow = {
        values = ["projects/debian-cloud", "projects/cos-cloud"]
      }
    },
    
    # List constraints - deny specific values
    "constraints/compute.vmExternalIpAccess" = {
      deny = {
        all = true  # Deny all external IPs
      }
    },
    
    # Custom constraints
    "constraints/iam.disableServiceAccountKeyCreation" = {
      enforce = true
    },
    
    # Resource locations constraint
    "constraints/gcp.resourceLocations" = {
      allow = {
        values = ["in:us-locations", "in:eu-locations"]
      }
    }
  }
  
  # Project labels
  labels = {
    environment  = "secure"
    compliance   = "high"
    service-tier = "standard"
  }
}