terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

data "aws_region" "current" {}

resource "aws_kms_key" "kms_key" {
    description             = var.description
    key_usage               = var.key_usage
    deletion_window_in_days = var.deletion_window_in_days
    is_enabled              = var.is_enabled
    multi_region            = var.multi_region
    policy                  = var.policy
}

resource "aws_kms_alias" "kms_key_alias" {
    name          = "alias/${data.aws_region.current.name}-${var.alias}"
    target_key_id = aws_kms_key.kms_key.key_id
}

output "kms_primary_key_arn" {
  value = aws_kms_key.kms_key.arn
}
