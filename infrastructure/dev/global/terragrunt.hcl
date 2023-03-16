remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "williamahern-com-dev-terraform-state"

    key      = "${path_relative_to_include()}/global/dev.tfstate"
    region   = "us-east-1"
    encrypt  = true
    role_arn = "arn:aws:iam::927822646792:role/terraform/TerraformBackend"

    dynamodb_table            = "williamahern-com-dev-terraform-state-locks"
    accesslogging_bucket_name = "williamahern-com-dev-terraform-state-logs"
  }
}

inputs = merge(
  yamldecode(
    file("${find_in_parent_folders("environment.yaml", find_in_parent_folders("environment.yaml"))}"),
  ),
  yamldecode(
    file("${find_in_parent_folders("region.yaml", find_in_parent_folders("environment.yaml"))}"),
  ),
  yamldecode(
    file("${find_in_parent_folders("app.yaml", find_in_parent_folders("environment.yaml"))}"),
  ),
)

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}