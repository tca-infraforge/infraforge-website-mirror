output "api_url" {
  description = "Base API Gateway URL for the form-backend (without path)"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "form_backend_api_url" {
  description = "Full API Gateway invoke URL for submitting the form"
  value       = "${aws_apigatewayv2_stage.dev.invoke_url}/form"
}
