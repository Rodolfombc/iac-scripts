terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

resource "aws_cloudwatch_log_group" "my_log_group" {
  name = var.name
  retention_in_days = 30
  kms_key_id = var.kms_key_arn
}
