terraform {
  source = "../../../../modules//admin-node"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "abc"
    vpc_cidr_block    = "10.0.0.0/16"
    public_subnet_ids = ["abc"]
  }
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env              = local.env_vars["env"]
  project_name     = local.env_vars["project_name"]
  vpc_id           = dependency.vpc.outputs.vpc_id
  vpc_cidr_block   = dependency.vpc.outputs.vpc_cidr_block
  public_subnet_id = dependency.vpc.outputs.public_subnet_ids[0]
}

include "root" {
  path = find_in_parent_folders()
}