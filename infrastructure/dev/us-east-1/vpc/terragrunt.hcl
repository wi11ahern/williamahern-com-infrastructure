terraform {
  source = "../../../modules//vpc"
}

prevent_destroy = true

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env          = local.env_vars["env"]
  project_name = local.env_vars["project_name"]
}

include "root" {
  path = find_in_parent_folders()
}