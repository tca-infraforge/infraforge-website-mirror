output "deployed_url" {
  description = "Primary URL for the deployed site"
  value       = var.config.enable_cloudfront ? "https://${aws_cloudfront_distribution.fallback.domain_name}" : "https://${aws_amplify_app.this.default_domain}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID (if created)"
  value       = try(aws_cloudfront_distribution.fallback.id, null)
}

output "cloudfront_domain_name" {
  description = "CloudFront Domain Name (if created)"
  value       = try(aws_cloudfront_distribution.fallback.domain_name, null)
}

output "cloudfront_url" {
  description = "CloudFront URL (if created)"
  value       = try("https://${aws_cloudfront_distribution.fallback.domain_name}", null)
}
