terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "backend_repo" {
  # The name of the ECR repository. This should match the name we used when building the Docker image.
  name = "tech-translator-backend"

  # Optional: Configuration for image tag mutability (prevents overwriting tags)
  image_tag_mutability = "IMMUTABLE"

  # Optional: Configuration for image scanning upon push
  image_scanning_configuration {
    scan_on_push = true
  }

  # Optional: Add tags for identification and cost allocation
  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development" # Or Production, Staging, etc.
  }
}