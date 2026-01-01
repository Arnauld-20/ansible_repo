
terraform {
  required_version = ">= 1.5.7"

  backend "s3" {
    bucket         = "arnauld-bucket-0828"
    key            = "Arnauld-20/ansible_repo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}

