# --- AWS SNS Topic for Notifications ---
resource "aws_sns_topic" "visit_notification_topic" {
  # The name of the SNS Topic.
  name = "tech-translator-visit-notifications"

  # Optional: Add tags
  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}

# --- AWS SNS Topic Subscription ---

# Messages published to the topic will be sent to the specified email address.
resource "aws_sns_topic_subscription" "email_subscription" {
  # The ARN of the SNS Topic we want to subscribe to.
  topic_arn = aws_sns_topic.visit_notification_topic.arn # Reference the ARN of the topic we defined

  # The protocol for the subscription (email).
  protocol = "email"

  # The endpoint (the email address to send notifications to).
  endpoint = "GeorgeWallden@outlook.com" # <-- **Replace with your actual email if different**
}

# --- AWS CloudWatch Log Group for App Runner Service Logs ---
resource "aws_cloudwatch_log_group" "apprunner_logs" {
  # The name pattern App Runner uses for its default log group
  name = "/aws/apprunner/${aws_apprunner_service.backend_service.service_name}" # Reference the service name

  # Optional: Set a retention policy (e.g., 90 days)
  # retention_in_days = 90

  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Service     = "AppRunnerBackendLogs"
    Environment = "Development" # Or appropriate environment tag
  }

  # Depends on the App Runner service being created
  depends_on = [
    aws_apprunner_service.backend_service
  ]
}