terraform {
  source = "../../../../modules//alb"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "abc"
    public_subnet_ids = ["abc"]
  }
}

dependency "s3" {
  config_path = "../../global/s3"
  mock_outputs = {
    log_bucket_name = "abc"
  }
}

dependency "route53" {
  config_path = "../../global/route53"
  mock_outputs = {
    # acm_certificate_arn = "arn:aws:acm:us-east-1:927822646792:certificate/abc"
    public_zone_id = "abc"
  }
}

locals {
  env_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
}

inputs = {
  env             = local.env_vars["env"]
  project_name    = local.env_vars["project_name"]
  domain_name     = local.env_vars["domain_name"]
  vpc_id          = dependency.vpc.outputs.vpc_id
  subnet_ids      = dependency.vpc.outputs.public_subnet_ids
  log_bucket_name = dependency.s3.outputs.log_bucket_name
  # acm_certificate_arn = dependency.route53.outputs.acm_certificate_arn
  public_zone_id = dependency.route53.outputs.public_zone_id
}

include "root" {
  path = find_in_parent_folders()
}