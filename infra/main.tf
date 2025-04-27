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

# --- ECR container repo for the docker container ---
resource "aws_ecr_repository" "backend_repo" {
  name = "tech-translator-backend"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development" 
  }
}

# --- IAM Role for App Runner Service ---
resource "aws_iam_role" "apprunner_service_role" {
  name = "tech-translator-apprunner-service-role" 

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com" # This specific principal allows App Runner tasks
        }
      },
    ]
  })

  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}