terraform {
  required_version = ">= 1.9.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.24.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.24.0"
    }
  }
}