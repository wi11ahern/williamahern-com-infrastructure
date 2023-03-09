terraform {
  source = "../../../modules//s3"
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  environment_name = local.env_vars["environment_name"]
}

include "root" {
  path = find_in_parent_folders()
}