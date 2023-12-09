variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "name" {
  type = string
}

variable "additional_volumes" {
  type = map(object({
    name = string
    size = number
    type = string
  }))
  default = {}
}

variable "volume_size" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "network" {
  type = string
}

variable "subnet" {
  type = string
}

variable "network_tags" {
  type    = list(string)
  default = ["ssh-server"]
}

variable "instance_image" {
  type    = string
  default = "debian-cloud/debian-11"
}
