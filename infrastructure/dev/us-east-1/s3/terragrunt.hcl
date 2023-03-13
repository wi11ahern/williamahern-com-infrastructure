terraform {
  source = "../../../modules//s3"
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env               = local.env_vars["env"]
  project_name      = local.env_vars["project_name"]
  elb_account_id    = local.env_vars["elb_account_id"]
}

include "root" {
  path = find_in_parent_folders()
}