terraform {
  source = "../../../modules//ecs"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id           = ""
    vpc_cidr_block   = ""
    public_subnet_id = ""
  }
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    target_group_arn      = ""
    alb_security_group_id = ""
  }
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    ecr_repository_url = ""
  }
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env                   = local.env_vars["env"]
  project_name          = local.env_vars["project_name"]
  vpc_id                = dependency.vpc.outputs.vpc_id
  vpc_cidr_block        = dependency.vpc.outputs.vpc_cidr_block
  public_subnet_ids     = dependency.vpc.outputs.public_subnet_ids
  alb_target_group_arn  = dependency.alb.outputs.target_group_arn
  alb_security_group_id = dependency.alb.outputs.alb_security_group_id
  ecr_repository_url    = dependency.ecr.outputs.ecr_repository_url

}

include "root" {
  path = find_in_parent_folders()
}