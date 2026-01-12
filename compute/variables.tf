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
  default = {
    name  = "marble"
    owner = "nero"
    build = null
    env   = "test"
  }
}

# variable "vpc_id" {
#   type = string
# }

variable "compute" {
  description = "Instance configuration"
  type = map(object({
    type      = string
    access    = string
    ssh_port  = number
    subnet_id = string
    sgs       = optional(list(string))
    key_name  = string
    user_data = optional(string)
    count     = optional(number)
  }))
}

variable "ami_cfg" {
  description = "AMI labels configuration"
  type = map(object({
    owner = string
    name  = string
    arch  = string
  }))
}
