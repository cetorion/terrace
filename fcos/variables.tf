variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "time_zone" {
  type    = string
  default = "Australia/Sydney"
}

variable "environment" {
  type    = string
  default = "test"
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
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

variable "project" {
  type = string
}

variable "ssh_key" {
  type = string
}
