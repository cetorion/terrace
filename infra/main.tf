terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket       = "terraform-state-bc00d4c914446324"
    use_lockfile = true
    key          = "env/test/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}
