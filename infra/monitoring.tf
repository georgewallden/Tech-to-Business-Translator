# --- AWS SNS Topic for Notifications ---
resource "aws_sns_topic" "visit_notification_topic" {
  # The name of the SNS Topic.
  name = "tech-translator-visit-notifications"

  # Optional: Enable server-side encryption for the topic
  # kms_master_key_id = "alias/aws/sns" # Use default SNS KMS key

  # Optional: Add tags
  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}