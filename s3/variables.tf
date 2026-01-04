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
  default = "terraform"
}

variable "purpose" {
  type    = string
  default = "state"
}

variable "environment" {
  type    = string
  default = "test"
}

variable "destroy" {
  type    = bool
  default = true
}
