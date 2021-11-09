locals {
  project = "project-rds-mysql"
  region  = "us-east-2"
  zones   = ["us-east-1a", "us-east-1b", "us-east-1f"]


  aws_state_bucket_region = get_env("AWS_STATE_BUCKET_REGION", "us-east-1")
  aws_state_bucket        = "${get_aws_account_id()}-${local.aws_state_bucket_region}-${local.project}-terragrunt"
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3"
    }
  }
}
provider "aws" {
  region      = "${local.region}"
  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = local.aws_state_bucket
    key     = "${local.project}/documents/${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_state_bucket_region
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = ".//main"
}

inputs = {
  function_root = "${get_terragrunt_dir()}/../functions"
  region = local.region
  db_dbname = "db_dbname"
  db_username = "db_dbname_admin"
  tags = {}
  project = local.project
}