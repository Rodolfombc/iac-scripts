terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }

  required_version = ">= 1.1"
}

provider "aws" {
  alias = "default"
  profile = "default"
}

provider "aws" {
  alias = "ohio"
  region = "us-east-2"
}

###########################
# Creating keys' policies
###########################
module "kms_primary_key_policy" {
  source = "../../modules/iam/policy/log-group"

  policy_id = "primary-key-policy"
  users = ["root", "user/infrauser"]

  providers = {
    aws = aws.default
  }
}

module "kms_replica_key_policy" {
  source = "../../modules/iam/policy/log-group"

  policy_id = "replica-key-policy"
  users = ["root", "user/infrauser"]

  providers = {
    aws = aws.ohio
  }
}

###########################
# Creating a customer 
# managed KMS key
###########################
module "custom_kms_primary_key" {
  source = "../../modules/kms/primary-key"

  alias                   = "primary-key"
  description             = "KMS Key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
  multi_region            = true
  policy                  = module.kms_primary_key_policy.log_group_policy_json

  providers = {
    aws = aws.default
  }
}

###########################
# Creating a replica key
###########################
module "ohio_replica_key" {
  source = "../../modules/kms/replica-key"

  alias                   = "replica-key"
  description             = "KMS replica key"
  deletion_window_in_days = 7
  enabled                 = true
  policy                  = module.kms_replica_key_policy.log_group_policy_json
  primary_key_arn         = module.custom_kms_primary_key.kms_primary_key_arn

  providers = {
    aws = aws.ohio
  }
}

###########################
# Creating a log group
###########################
module "ohio_log_group" {
  source = "../../modules/cloudwatch/log-group"

  name  = "log-group" 
  retention_in_days = 7
  kms_key_arn = module.ohio_replica_key.kms_replica_key_arn

  providers = {
    aws = aws.ohio
  }
}

###########################
# Creating a vpc flowlog
###########################
module "vpc_flowlogs_iam_role" {
  source = "../../modules/iam/role/vpc-flowlogs-role"

  providers = {
    aws = aws.default
  }
}

module "ohio_vpc_flowlog" {
  source = "../../modules/vpc/flow-log"

  traffic_type              = "ALL"
  log_destination           = module.ohio_log_group.log_group_arn
  vpc_id                    = "my-vpc-id"
  max_aggregation_interval  = 600

  iam_role_arn              = module.vpc_flowlogs_iam_role.arn
  iam_role_id               = module.vpc_flowlogs_iam_role.id

  providers = {
    aws = aws.ohio
  }
}
