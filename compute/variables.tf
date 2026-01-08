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

variable "ssh_keys" {
  type = map(list(string))
}

variable "compute" {
  description = "Instance configuration"
  type = list(object({
    ami_id          = optional(string)
    ami_name        = optional(string)
    instance_type   = string
    access          = optional(string)
    subnet_id       = optional(string)
    security_groups = optional(list(string))
    public_ip       = optional(bool)
    key_name        = string
    user_data       = optional(string)
    count           = optional(number)
    name            = optional(string)
  }))

  default = [
    {
      ami_id        = null
      ami_name      = "fcos"
      instance_type = "t4g.small"
      public_ip     = true
      count         = 1
      key_name      = "cetorion"
      access        = "public"
    }
  ]

  validation {
    condition = alltrue(
      [
        for c in var.compute :
        c.ami_id == null || c.ami_name == null
      ]
    )
    error_message = "Cannot set both ami_id and ami_name at the same time"
  }

  validation {
    condition = alltrue(
      [
        for c in var.compute :
        (c.ami_id != null && c.ami_name == null) || (c.ami_id == null && c.ami_name != null)
      ]
    )
    error_message = "Exactly one of ami_id or ami_name must be set."
  }
}

variable "ami_cfg" {
  description = "AMI configuration"
  type = map(object({
    owner = string
    name  = string
    arch  = string
  }))
  default = {
    fcos = {
      owner = "125523088429"
      name  = "fedora-coreos-43*"
      arch  = "arm64"
    }
  }
}
