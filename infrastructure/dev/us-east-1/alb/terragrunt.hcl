terraform {
  source = "../../../modules//alb"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = ""
    public_subnet_ids = []
  }
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    log_bucket_name = ""
  }
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env               = local.env_vars["env"]
  project_name      = local.env_vars["project_name"]
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.public_subnet_ids
  log_bucket_name    = dependency.s3.outputs.log_bucket_name
}

include "root" {
  path = find_in_parent_folders()
}