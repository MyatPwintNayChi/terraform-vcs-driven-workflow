terraform {
  required_version = ">= 1.12.0"

  cloud {
    organization = "hello-cloud"

    workspaces {
      name = "frontend-network"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
