variable "config" {
  description = "Form backend configuration"
  type = object({
    app_name = string
    iam = object({
      user = string
      team = string
    })
    tags               = map(string)
    app_api_secret_key = string
    aws_region         = string
  })
}
