variable "region" {
  type    = string
  default = "ap-southeast-2"
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
    type      = string
    access    = string
    port      = optional(number)
    key       = optional(string)
    ami_label = optional(string)
    userdata  = optional(string)
    count     = optional(number)
  }))

}

variable "amis" {
  description = "AMI labels configuration"
  type = map(object({
    owner = string
    name  = string
    arch  = string
  }))
}
