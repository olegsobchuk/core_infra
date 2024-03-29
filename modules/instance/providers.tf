terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }

  required_version = ">= 1.0.11"
}

provider "aws" {
  region = var.region
}
