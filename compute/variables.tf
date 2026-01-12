variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "time_zone" {
  type    = string
  default = "Australia/Sydney"
}

variable "project" {
  description = "Project configuration"
  type = object({
    name  = string
    owner = string
    build = string
    env   = string
  })
}

variable "compute" {
  description = "Instance configuration"
  type = map(object({
    type     = string
    access   = string
    key      = string
    port     = optional(number)
    subnet   = optional(string)
    ami      = optional(string)
    sgs      = optional(list(string))
    userdata = optional(string)
    count    = optional(number)
  }))
}

variable "amis" {
  description = "AMI configuration"
  type = map(object({
    owner = string
    name  = string
    arch  = string
  }))
}
