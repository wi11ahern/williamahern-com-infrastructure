terraform {
  source = "../../../modules//ecs"
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  env               = local.env_vars["env"]
  project_name      = local.env_vars["project_name"]
  private_subnet_id = dependency.vpc.outputs.private_subnet_id
}

include "root" {
  path = find_in_parent_folders()
}