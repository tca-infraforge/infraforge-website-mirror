variable "config" {
  description = "Monitoring configuration"
  type = object({
    sns_topic_arn = string
    aws_region    = string
    lambda_name   = string
    tags          = map(string)
  })
}
