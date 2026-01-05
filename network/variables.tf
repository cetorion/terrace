variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "owner" {
  type    = string
  default = "Nero Dicentra"
}

variable "id" {
  type    = string
  default = "nero"
}

variable "project" {
  type    = string
  default = "planet"
}

variable "purpose" {
  type    = string
  default = "jupiter"
}

variable "environment" {
  type    = string
  default = "test"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "subnets" {
  description = "List of subnet definitions (can be empty)"
  type = list(object({
    cidr   = optonal(string)
    az     = optional(string)
    access = optional(string)
  }))
  default = []

  validation {
    condition = alltrue(
      [for v in var.subnets :
      contains(["public", "private"], v.access) if v.access != null]
    )
    error_message = "Only 'private and 'public' access types are allowed"
  }
  validation {
    condition = (
      alltrue([for s in var.subnets : s.cidr == null])
      ||
      alltrue([for s in var.subnets : can(cidrhost(s.cidr, 1))])
    )
    error_message = "Must be either all valid CIDRs or all NULLs"
  }
  validation {
    condition = (
      length([for s in var.subnets : s.cidr if s.cidr != null])
      ==
      length(distinct([for s in var.subnets : s.cidr if s.cidr != null]))
    )
    error_message = "Each CIDR must be unique"
  }
}
