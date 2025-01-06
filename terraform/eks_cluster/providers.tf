terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

}