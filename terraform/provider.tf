terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }

  backend "gcs" {
    bucket = "bkrental-infra-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "bkrental-412103"
  region  = "us-west4"
  zone    = "us-west4-b"
}
