output "deployed_url" {
  description = "Primary URL for the deployed site"
  value       = module.amplify_website.deployed_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID (if created)"
  value       = module.amplify_website.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront Domain Name (if created)"
  value       = module.amplify_website.cloudfront_domain_name
}

output "cloudfront_url" {
  description = "CloudFront URL (if created)"
  value       = module.amplify_website.cloudfront_url
}
