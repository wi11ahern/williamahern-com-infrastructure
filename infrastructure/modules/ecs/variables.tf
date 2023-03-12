variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}