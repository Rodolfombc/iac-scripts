terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms_replica_key_policy" {
  policy_id = "${data.aws_region.current.name}-replica-key-policy"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root",
        "arn:aws:iam::${var.aws_account_id}:user/infrauser"
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
        "arn:aws:logs:${data.aws_region.current.name}:${var.aws_account_id}:*",
      ]
    }
  }
}

resource "aws_kms_replica_key" "kms_replica_key" {
  description             = "Multi-region replica kms key"
  deletion_window_in_days = 7
  enabled                 = true
  policy                  = data.aws_iam_policy_document.kms_replica_key_policy.json
  primary_key_arn         = var.primary_key_arn
}

resource "aws_kms_alias" "kms_replica_key_alias" {
    name          = "alias/${data.aws_region.current.name}-replica-key"
    target_key_id = aws_kms_replica_key.kms_replica_key.key_id
}

output "kms_replica_key_arn" {
  value = aws_kms_replica_key.kms_replica_key.arn
}