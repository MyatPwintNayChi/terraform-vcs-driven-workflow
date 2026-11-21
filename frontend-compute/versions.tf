terraform {
  required_version = ">= 1.12.0"

  cloud {
    organization = "hello-cloud"

    workspaces {
      name = "frontend-compute"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
