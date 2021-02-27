provider "aws" {
  access_key = ""
  secret_key = ""
  region = ""
}
terraform {
  required_version = "0.14.6"

  required_providers {
    aws = ">= 3.28.0"
  }
}
