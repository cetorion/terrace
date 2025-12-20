terraform {
  required_version = ">= 1.14.0"
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

resource "random_id" "this" {
  byte_length = 8
}

data "ct_config" "this" {
  content = templatefile("${path.module}/fcos.yaml",
    {
      hostname  = var.project,
      ssh_key   = var.ssh_key,
      time_zone = var.time_zone
    }
  )
  strict       = true
  pretty_print = false
}

locals {
  userdata = data.ct_config.this.rendered
  ami_name = "fedora-coreos-${var.fcos_vers}*"

  tags = {
    Owner       = "Nero Dicentra"
    Environment = var.environment
    Build       = random_id.this.id
  }
}

data "aws_ami" "this" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [local.ami_name]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
