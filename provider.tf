terraform {
  required_version = ">= 0.13"
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }
  }
}
provider "aws" {
  assume_role { 
  role_arn  = var.role_arn
} 
  region = var.region
}