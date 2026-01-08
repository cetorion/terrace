terraform {
  required_version = ">= 1.14.0"
  backend "s3" {
    bucket       = "terraform-state-ba4abc2f2c13982d"
    key          = "terraform/state/compute/8378"
    region       = "ap-southeast-2"
    use_lockfile = true
    encrypt      = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27"
    }

    ct = {
      source  = "poseidon/ct"
      version = "~> 0.14"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  region = var.region
}
