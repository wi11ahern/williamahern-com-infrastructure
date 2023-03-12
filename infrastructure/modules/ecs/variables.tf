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

variable "private_subnet_id" {
  type = string
}