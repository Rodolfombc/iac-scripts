terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

data "aws_region" "current" {}

resource "aws_kms_replica_key" "kms_replica_key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enabled                 = var.enabled
  policy                  = var.policy
  primary_key_arn         = var.primary_key_arn
}

resource "aws_kms_alias" "kms_replica_key_alias" {
    name          = "alias/${data.aws_region.current.name}-${var.alias}"
    target_key_id = aws_kms_replica_key.kms_replica_key.key_id
}

output "kms_replica_key_arn" {
  value = aws_kms_replica_key.kms_replica_key.arn
}
