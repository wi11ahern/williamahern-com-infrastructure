#!/bin/bash

# Note: terragrunt hclfmt already runs recursively. 
terraform fmt --recursive --diff && terragrunt hclfmt
