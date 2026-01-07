variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "owner" {
  description = "Project owner"
  type        = string
  default     = "Nero Dicentra"
}

variable "id" {
  description = "Project ID"
  type        = string
  default     = "nero"
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "build" {
  description = "Build ID"
  type        = string
  default     = null
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
