output "amplify_app_id" {
  description = "The ID of the Amplify App"
  value       = aws_amplify_app.this.id
}

output "default_domain" {
  description = "The default domain assigned by AWS Amplify"
  value       = aws_amplify_app.this.default_domain
}

output "app_url" {
  description = "Primary app URL (Amplify default domain)"
  value       = "https://${aws_amplify_app.this.default_domain}"
}

output "deployed_url" {
  description = "URL where app is deployed (prioritizes CloudFront for testing)"
  value       = var.config.enable_cloudfront ? "https://${aws_cloudfront_distribution.fallback[0].domain_name}" : "https://${aws_amplify_app.this.default_domain}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID for testing/fallback"
  value       = try(aws_cloudfront_distribution.fallback[0].id, null)
}

output "cloudfront_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = try(aws_cloudfront_distribution.fallback[0].domain_name, null)
}

output "cloudfront_url" {
  description = "CloudFront URL for testing"
  value       = try("https://${aws_cloudfront_distribution.fallback[0].domain_name}", null)
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for monitoring and budgeting alerts"
  value       = aws_sns_topic.notifications.arn
}
