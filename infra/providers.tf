terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.96.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region for all resources"
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}
