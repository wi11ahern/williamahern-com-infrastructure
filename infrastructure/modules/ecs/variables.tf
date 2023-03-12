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

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_id" {
  type = string
}