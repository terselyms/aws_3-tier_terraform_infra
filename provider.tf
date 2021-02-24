provider "aws" {
  access_key = "AKIAUHC7CFEMHJSJMRG2"
  secret_key = "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"
  region = "ap-northeast-2"
}
terraform {
  required_version = "0.14.6"

  required_providers {
    aws = ">= 3.28.0"
  }
}
