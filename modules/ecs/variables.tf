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

variable "task_instance_count" {
  type    = number
  default = 1
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_ids" {
  type = set(string)
}

variable "alb_target_group_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}