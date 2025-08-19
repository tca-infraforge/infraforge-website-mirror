terraform {
  backend "s3" {
    bucket         = "infraforge-tf-state-1754378870"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "infraforge-tf-lock"
    encrypt        = true
  }
}
