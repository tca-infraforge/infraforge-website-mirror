variable "config" {
  description = "Configuration object for S3 backend module."
  type = object({
    bucket_name         = string
    dynamodb_table_name = string
    tags                = map(string)
  })
}
