terraform {
  source = "../../../../modules//route53"
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env          = local.env_vars["env"]
  project_name = local.env_vars["project_name"]
  domain_name  = local.env_vars["domain_name"]
}

include "root" {
  path = find_in_parent_folders()
}