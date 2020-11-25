# Main file, configures the necessary providers.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "henryrocha-personal"

    workspaces {
      name = "cloud-computing-nollo"
    }
  }
}
