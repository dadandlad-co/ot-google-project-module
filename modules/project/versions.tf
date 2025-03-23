terraform {
  required_version = ">= 1.9.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.1"
    }
  }
} 