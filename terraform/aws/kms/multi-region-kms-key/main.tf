terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }

  required_version = ">= 1.1"
}

data "aws_region" "current" {}

provider "aws" {
  profile = "default"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_key_policy" {
  policy_id = "kms-key-policy"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/infrauser"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
      ]
    }
  }
}

###########################
# Customer managed KMS key
###########################
resource "aws_kms_key" "kms_key" {
    description             = "KMS Key"
    key_usage               = "ENCRYPT_DECRYPT"
    deletion_window_in_days = 7
    is_enabled              = true
    multi_region            = true
    policy                  = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "kms_key_alias" {
    name          = "alias/${data.aws_region.current.name}-key"
    target_key_id = aws_kms_key.kms_key.key_id
}


##################################
# Providers for regions  where
# we will create the replica keys
##################################
provider "aws" {
  alias = "ohio"
  region = "us-east-2"
}
provider "aws" {
  alias = "north_california"
  region = "us-west-1"
}
provider "aws" {
  alias = "oregon"
  region = "us-west-2"
}

###########################
# Replicating created key
# among aws regions
###########################
module "ohio_replica_key" {
  source = "./modules/kms-replica-key"

  aws_account_id  = data.aws_caller_identity.current.account_id
  primary_key_arn = aws_kms_key.kms_key.arn

  providers = {
    aws = aws.ohio
  }
}

module "north_california_replica_key" {
  source = "./modules/kms-replica-key"

  aws_account_id  = data.aws_caller_identity.current.account_id
  primary_key_arn = aws_kms_key.kms_key.arn

  providers = {
    aws = aws.north_california
  }
}

module "oregon_replica_key" {
  source = "./modules/kms-replica-key"

  aws_account_id  = data.aws_caller_identity.current.account_id
  primary_key_arn = aws_kms_key.kms_key.arn

  providers = {
    aws = aws.oregon
  }
}