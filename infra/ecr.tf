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

