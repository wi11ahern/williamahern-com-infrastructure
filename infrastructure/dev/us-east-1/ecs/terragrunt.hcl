terraform {
  source = "../../../modules//ecs"
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = ""
    private_subnet_id = ""
  }
}

inputs = {
  env               = local.env_vars["env"]
  project_name      = local.env_vars["project_name"]
  vpc_id            = dependency.vpc.outputs.vpc_id
  private_subnet_id = dependency.vpc.outputs.private_subnet_id
}

include "root" {
  path = find_in_parent_folders()
}