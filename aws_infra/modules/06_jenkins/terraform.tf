terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "aws05-terraform-state-bucket"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "aws05-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}
