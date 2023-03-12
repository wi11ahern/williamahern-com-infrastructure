terraform {
  source = "../../../modules//ecr-cleaner-lambda"
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    ecr_arn = ""
  }
}

inputs = {
  env          = local.env_vars["env"]
  project_name = local.env_vars["project_name"]
  ecr_arn      = dependency.ecr.outputs.ecr_arn
}

include "root" {
  path = find_in_parent_folders()
}