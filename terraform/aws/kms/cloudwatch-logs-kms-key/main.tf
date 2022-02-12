terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }

  required_version = ">= 0.15"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_cloudwatch_key_policy" {
  policy_id = "cloudwatch-logs-key"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
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
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
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
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*",
      ]
    }
  }
}

###########################
# Customer managed KMS key 
# for CloudWatch logs
###########################
resource "aws_kms_key" "kms_cloudwatch_key" {
    description             = "Key to protect cloudwatch logs"
    key_usage               = "ENCRYPT_DECRYPT"
    deletion_window_in_days = 7
    is_enabled              = true
    policy                  = data.aws_iam_policy_document.kms_cloudwatch_key_policy.json
}

resource "aws_kms_alias" "kms_cloudwatch_key_alias" {
    name          = "alias/cloudwatch-logs-key"
    target_key_id = aws_kms_key.kms_cloudwatch_key.key_id
}
