terraform {
  source = "../../../modules//route53"
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    alb_dns_name = ""
    alb_zone_id  = ""
  }
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env          = local.env_vars["env"]
  project_name = local.env_vars["project_name"]
  domain_name  = local.env_vars["domain_name"]
  alb_dns_name = dependency.alb.outputs.alb_dns_name
  alb_zone_id  = dependency.alb.outputs.alb_zone_id
}

include "root" {
  path = find_in_parent_folders()
}