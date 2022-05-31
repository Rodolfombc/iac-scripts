terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${data.aws_region.current.name}-${var.name}"
  retention_in_days = var.retention_in_days
  kms_key_id = var.kms_key_arn
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.log_group.arn
}
