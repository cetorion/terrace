variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "name" {
  type = string
}

variable "create" {
  type    = bool
  default = true
}

variable "algorithm" {
  type    = string
  default = "ED25519"
}
