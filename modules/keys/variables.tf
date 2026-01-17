variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "algorithm" {
  type    = string
  default = "ED25519"
}

variable "keys" {
  type = list(object(
    {
      name   = string
      create = bool
    }
  ))
}
