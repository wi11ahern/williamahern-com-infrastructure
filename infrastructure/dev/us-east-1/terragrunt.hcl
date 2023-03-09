remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "willahern-tf-state-dev"

    key     = "${path_relative_to_include()}/dev.tfstate"
    region  = "us-east-1"
    encrypt = true
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