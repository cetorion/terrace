variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "project" {
  description = "Project configuration"
  type = object({
    name  = string
    owner = string
    build = string
    env   = string
  })
  default = {
    name  = "marble"
    owner = "nero"
    build = null
    env   = "test"
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_hostnames" {
  description = "Whether to enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "dns_support" {
  description = "Whether to enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "subnets" {
  description = "List of subnet definitions (can be empty)"
  type = list(object({
    cidr   = optional(string)
    az     = optional(string)
    access = optional(string)
    count  = optional(number)
  }))

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
