# --- AWS App Runner Auto Scaling Configuration ---
resource "aws_apprunner_auto_scaling_configuration_version" "scale_config" {

  auto_scaling_configuration_name = "tech-translator-scale-config"

  # The maximum number of concurrent requests per instance before scaling up.
  max_concurrency = 100 # Default is 100

  # The maximum number of instances the service can scale up to.
  max_size = 1 

  # The minimum number of instances the service will maintain.
  min_size = 1 

  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}

resource "aws_apprunner_service" "backend_service" {
  service_name = "tech-speak-translator-backend" # A unique name for the service

  # Link to the auto-scaling configuration
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.scale_config.arn

  source_configuration {
    image_repository {
      # Reference the ECR repository created earlier
      image_identifier      = "${aws_ecr_repository.backend_repo.repository_url}:latest" # Use repo URL and image tag
      image_repository_type = "ECR" # Specify ECR type
      # The role App Runner uses to access the ECR repository (required for private ECR)

      # Authentication configuration - needs the service role ARN
      image_configuration {
         runtime_environment_variables = {
           AWS_REGION = "us-east-1"
         }
         port = "5001"
      }
    }

    # Authentication configuration for accessing the source (ECR or code repo)
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access_role.arn # Role for pulling image from ECR
    }
  }

  # Health check configuration
  health_check_configuration {
      protocol = "HTTP" # Use HTTP health check
      path     = "/"    # Use the health check endpoint you built in Flask
      interval = 10     # Check every 10 seconds
      timeout  = 5      # Timeout after 5 seconds
      healthy_threshold = 1 # Mark healthy after 1 successful check
      unhealthy_threshold = 5 # Mark unhealthy after 5 consecutive failures
    }
    
  # App Runner service needs permissions to pull the image from ECR,
  # write logs to CloudWatch, and invoke Bedrock/DynamoDB/SNS.
  # We created a role for this.
  instance_configuration {
    cpu    = "1024" # 1 vCPU (default)
    memory = "2048" # 2 GB (default)
    # Link to the IAM role defined earlier
    instance_role_arn = aws_iam_role.apprunner_service_role.arn
  }

  # Tags for organization and cost allocation
  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Service     = "AppRunnerBackend"
    Environment = "Development" # Or appropriate environment tag
  }

  # Depends_on ensures resources are created in the correct order.
  # App Runner service depends on the ECR repo, IAM role, and scaling config.
  depends_on = [
    aws_ecr_repository.backend_repo,
    aws_iam_role.apprunner_service_role,
    aws_iam_role.apprunner_ecr_access_role,
    aws_apprunner_auto_scaling_configuration_version.scale_config
  ]
}

