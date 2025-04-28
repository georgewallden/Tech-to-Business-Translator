# --- AWS Certificate Manager Certificate ---
resource "aws_acm_certificate" "custom_domain_cert" {
  provider = aws # Ensure we are using the main provider, which is us-east-1 based on providers.tf

  domain_name       = "translator-api.georgewallden.com" # The domain the backend will use
  validation_method = "DNS" # Use DNS validation via Route 53

  tags = {
    Project     = "TechToBusinessTranslator"
    ManagedBy   = "Terraform"
    Component   = "ACM Certificate"
    Environment = "Development"
  }

  lifecycle {
    create_before_destroy = true # Important for certificate updates
  }
}

# --- Data Source: AWS Route 53 Hosted Zone ---
data "aws_route53_zone" "hosted_zone" {
  name         = "georgewallden.com." # Your domain name, include the trailing dot!
  private_zone = false # Your domain is public
}

# --- AWS Route 53 Record for ACM Validation ---
resource "aws_route53_record" "acm_validation_record" {
  # Use for_each to create a record for each validation option provided by ACM
  for_each = {
    for dvo in aws_acm_certificate.custom_domain_cert.domain_validation_options : dvo.domain_name => dvo
  }

  # Reference the hosted zone found by the data source
  zone_id = data.aws_route53_zone.hosted_zone.zone_id

  # Use the validation option details from ACM for the record
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value] # Records must be a list
  ttl     = 60 # Time-to-live for the record
}

# --- AWS ACM Certificate Validation ---
# Waits for the ACM certificate to be validated by DNS records.
resource "aws_acm_certificate_validation" "custom_domain_cert_validation" {
  provider = aws # Ensure we are using the us-east-1 provider

  certificate_arn = aws_acm_certificate.custom_domain_cert.arn # Reference the ARN of the certificate request

  # Reference the FQDNs of the validation records created
  # This ensures validation resource waits for the records to exist.
  validation_record_fqdns = [for record in aws_route53_record.acm_validation_record : record.fqdn]

  # Explicitly depend on the validation records being created first
  depends_on = [
    aws_route53_record.acm_validation_record,
  ]
}