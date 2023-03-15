# williamahern.com Infrastructure
## Overview
This project contains Terraform infrastructure definitions for `williamahern.com`.

## Infrastructure Layout
Infrastructure is separated by environment and region (environment-region). The modules directory contains Terraform modules that are then referenced by the Terragrunt configuration files of each environment-region infrastructure folder.
```
.
└── infrastructure
    ├── dev
    │   ├── us-east-1
    │   │   └── ecr
    │   ├── us-west-1
    │   │   └── ecr
    │   └── ...
    ├── test
    │   ├── us-east-1
    │   │   └── ecr
    │   ├── us-west-1
    │   │   └── ecr
    │   └── ...
    ├── prod
    │   ├── us-east-1
    │   │   └── ecr
    │   ├── us-west-1
    │   │   └── ecr
    │   └── ...
    └── modules
        ├── .bootstrap
        ├── vpc
        ├── s3
        ├── route53
        └── ...
```
By using Terragrunt's ability to recursively search up and down directories
as well utility to generate files that would otherwise need to be duplicated between
Terraform modules, we can leverage this structure to logically separate infrastructure configurations
depending on the environment and region we want to deploy to.

## Run Locally
**Note: Before proceeding with this section, ensure you have the AWS Docker image built from the [Dockerfile library](https://github.com/wi11ahern/dockerfile-library).**
1. Create an `env.list` file with your AWS credentials included as variables.
    - These will be used by the AWS CLI and by Terraform to perform deployments.
    - **WARNING: Do NOT commit this file. As a precaution, this file is IGNORED by Git.**

2. Execute the AWS docker container.
```bash
docker run -it --rm --env-file env.list -v $HOME/Projects/willahern-com-infrastructure:/willahern-com-infrastructure -t aws
```

3. Run Terragrunt + Terraform commands to your heart's delight!

### Bootstrapping an AWS Account
In order to take advantage of Terraform's [remote state](https://registry.terraform.io/providers/FlexibleEngineCloud/flexibleengine/latest/docs/guides/remote-state-backend), the following resources must exist prior to using Terraform:
- An S3 bucket for managing Terraform state files
- A DynamoDB (DDB) table for managing Terraform locks

Terraform cannot create these resources itself while also simultaneously using remote state
as this would introduce a "chick and the egg" situation. In other words, Terraform would see that it needs to create the S3 bucket and DDB table, then would go to check the state and set the lock for the same resources, and because they wouldn't exist, the deployment would fail.

Terragrunt can automatically provision these resources for us, but for more flexibility and ownership of the resources, I have opted to create them using a CloudFormation template.

In order to bootstrap an AWS account for Terraform, simply execute the below command:
```bash
# Environment name -- e.g. "dev" | "test" | "prod"
ENV="dev"
# Region name -- e.g. "us-east-1" | "us-east-2" | "us-west-1"
REGION="us-east-1"
STATE_BUCKET_NAME=williamahern-com-${ENV}-terraform-state \
STATE_LOG_BUCKET_NAME=williamahern-com-${ENV}-terraform-state-logs \
LOCK_TABLE_NAME=williamahern-com-${ENV}-terraform-state-locks

aws cloudformation deploy \
  --region ${REGION} \
  --template-file terraform-bootstrap.cf.yml \
  --stack-name Terraform-Bootstrap \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    StateBucketName=${STATE_BUCKET_NAME} \
    StateLogBucketName=${STATE_LOG_BUCKET_NAME} \
    LockTableName=${LOCK_TABLE_NAME}
```