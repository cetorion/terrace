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

variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "List of subnet definitions (can be empty)"
  type = list(object({
    cidr_block = string
    az         = optional(string)
    access     = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for v in var.subnets : contains(["public", "private"], v.access)])
    error_message = "Only 'private and 'public' types allowed"
  }
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}
