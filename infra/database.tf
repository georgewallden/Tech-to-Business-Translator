# --- AWS DynamoDB Table for Session Tracking ---
resource "aws_dynamodb_table" "sessions_table" {
  name = "tech-translator-sessions"

  billing_mode = "PAY_PER_REQUEST"

  # Define the primary key (Partition Key). We'll use 'sessionId'.
  hash_key = "sessionId"

  # Define the attributes used in the table.
  attribute {
    name = "sessionId"
    type = "S" # S stands for String
  }

  # Enable Time-To-Live (TTL). Items with an expired 'ttl' timestamp will be deleted automatically.
  ttl {
    attribute_name = "ttl" # The attribute to use for TTL (must be a Number, Unix timestamp)
    enabled        = true
  }

  # Optional: Add tags
  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}