terraform {
  backend "s3" {
    bucket = "code-craft-backend-supply"
    key    = "infra-base/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

