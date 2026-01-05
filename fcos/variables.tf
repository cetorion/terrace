variable "region" {
  type    = string
  default = "ap-southeast-2"
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
  default     = "test"
}

variable "build" {
  description = "Build ID"
  type        = string
  default     = null
}

variable "time_zone" {
  type    = string
  default = "Australia/Sydney"
}

variable "instance_type" {
  type    = string
  default = "t4g.small"
}

variable "fcos_vers" {
  type    = string
  default = "43"
}

variable "ami_owner" {
  type    = string
  default = "125523088429"
}

variable "key_name" {
  type = string
}

variable "ssh_key" {
  type = string
}
