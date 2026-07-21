terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "mario-v2-deployment-s3"  # Make sure this S3 bucket exists or Terraform will prompt you
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mario-v2-locks"         # Make sure this DynamoDB table exists
  }
}

provider "aws" {
  region = "us-east-1"
}
