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
  type = map(string)
}

variable "compute" {
  description = "Instance configuration"
  type = list(object({
    ami_id    = optional(string)
    ami_label = optional(string)
    ins_type  = string
    access    = optional(string)
    ssh_port  = number
    subnet_id = optional(string)
    sgs       = optional(list(string))
    public_ip = optional(bool)
    key_name  = string
    user_data = optional(string)
    count     = optional(number)
    name      = optional(string)
  }))

  default = [
    {
      ami_id    = null
      ami_label = "fcos"
      ins_type  = "t4g.small"
      public_ip = true
      count     = 1
      key_name  = "cetorion"
      access    = "public"
      ssh_port  = 22
    }
  ]

  validation {
    condition = alltrue(
      [
        for c in var.compute :
        c.ami_id == null || c.ami_label == null
      ]
    )
    error_message = "Cannot set both ami_id and ami_label at the same time"
  }

  validation {
    condition = alltrue(
      [
        for c in var.compute :
        (c.ami_id != null && c.ami_label == null) || (c.ami_id == null && c.ami_label != null)
      ]
    )
    error_message = "Exactly one of ami_id or ami_label must be set."
  }
}

variable "ami_cfg" {
  description = "AMI labels configuration"
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
