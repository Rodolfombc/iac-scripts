terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

resource "aws_iam_role" "vpc_flowlogs_role" {
  name          = "vpc-flowlogs-role"
  description   = "IAM role to allow access to vpc flow logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

output "id" {
  value = aws_iam_role.vpc_flowlogs_role.id
}

output "arn" {
  value = aws_iam_role.vpc_flowlogs_role.arn
}
