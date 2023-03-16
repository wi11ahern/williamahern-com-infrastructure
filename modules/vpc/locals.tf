locals {
  common_tags = {
    Environment = var.env
    Project     = var.project_name
  }

  project_prefix     = "${var.project_name}-${var.env}"
  availability_zones = data.aws_availability_zones.availability_zones.names

  cidr_to_public_subnet_map = {
    a = ["10.0.1.0/24", local.availability_zones[0]]
    b = ["10.0.2.0/24", local.availability_zones[1]]
  }

  cidr_to_private_subnet_map = {
    a = ["10.0.3.0/24", local.availability_zones[0]]
    b = ["10.0.4.0/24", local.availability_zones[1]]
  }
}