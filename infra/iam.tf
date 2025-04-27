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

# --- AWS IAM Policy for App Runner Service Role ---
resource "aws_iam_policy" "apprunner_service_policy" {
  name        = "tech-translator-apprunner-service-policy" # A descriptive name for the policy in AWS
  description = "Policy for Tech-to-Business Translator App Runner service"

  # The policy document itself, defined in JSON format.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permission to pull image from ECR (required for App Runner instance role)
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken" # Might need this for the instance role, or execution role - better safe
        ]
        Resource = "${aws_ecr_repository.backend_repo.arn}" # Reference the ARN of the ECR repo we defined
      },
      # Permission to invoke Bedrock models (required for our application logic)
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "*" # Allowing invocation of any model you have access to in the region
      },
       # Permissions to put/get items in the DynamoDB table (for session tracking, generic for now)
       {
         Effect = "Allow"
         Action = [
           "dynamodb:GetItem",
           "dynamodb:PutItem",
           "dynamodb:UpdateItem" # Might use UpdateItem for counter
         ]
         Resource = "${aws_dynamodb_table.sessions_table.arn}"
       },
       # Permission to publish messages to the SNS topic (for visit notifications, generic for now)
       {
         Effect = "Allow"
         Action = [
           "sns:Publish"
         ]
         Resource = "${aws_sns_topic.visit_notification_topic.arn}" 
       },
      # Permission to write logs to CloudWatch Logs (required for App Runner)
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        # Allow writing logs to any log stream within any log group related to App Runner
        Resource = "arn:aws:logs:*:*:log-group:/aws/apprunner/*" 
      }
    ]
  })

  # Optional: Add tags
  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}

# --- AWS IAM Role Policy Attachment ---
# Attach the policy to the App Runner service role.
# This grants the permissions defined in the policy to the role.
resource "aws_iam_role_policy_attachment" "apprunner_service_attachment" {
  role       = aws_iam_role.apprunner_service_role.name # Reference the name of the role we defined
  policy_arn = aws_iam_policy.apprunner_service_policy.arn # Reference the ARN of the policy we defined
}