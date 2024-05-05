terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "resistor-color-code-bucket"
    key            = "state/terraform-app.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    kms_key_id     = "alias/terraform-bucket-key"
    dynamodb_table = "terraform-state"

  }
}

provider "aws" {
  region = "eu-central-1"
}
