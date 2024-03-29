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
  profile = "default" # ~/.aws/... use block `default`
  region  = var.region
}
