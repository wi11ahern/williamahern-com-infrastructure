variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "tags" {
  type = map
  default = {}
}

variable "private_subnet_id" {
  type = string
}