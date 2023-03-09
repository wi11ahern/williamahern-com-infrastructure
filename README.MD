# willahern.com Infrastructure
## Overview
This project contains Terraform infrastructure definitions for `willahern.com`.

## Infrastructure Layout
Infrastructure is seperated by environment and region.
```
.
└── infrastructure
    ├── dev
    │   ├── us-east-1
    │   │   └── ecr
    │   └── us-west-1
    │       └── ecr
    ├── test
    │   ├── us-east-1
    │   │   └── ecr
    │   └── us-west-1
    │       └── ecr
    └── prod
        ├── us-east-1
        │   └── ecr
        └── us-west-1
            └── ecr
```
By using Terragrunt's ability to recursively search up and down directories
as well utility to generate files that would otherwise need to be duplicated between
Terraform modules, we can leverage this structure to logically separate infrastructure configurations
depending on the environment and region we want to deploy to.

## Run Locally
```bash
docker run -it --rm --env-file env.list -v $HOME/Projects/willahern-com-infrastructure:/willahern-com-infrastructure -t aws
```