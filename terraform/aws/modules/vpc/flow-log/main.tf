terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

data "aws_caller_identity" "current" {}

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

resource "aws_iam_role_policy" "vpc_flowlogs_role_policy" {
  name          = "vpc-flowlogs-role-policy"
  role          = aws_iam_role.vpc_flowlogs_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*",
        "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"
      ]
    }
  ]
}
EOF
}

resource "aws_flow_log" "vpc_flow_log" {
  traffic_type              = var.traffic_type
  iam_role_arn              = aws_iam_role.vpc_flowlogs_role.arn
  log_destination_type      = "cloud-watch-logs"
  log_destination           = var.log_destination
  vpc_id                    = var.vpc_id
  max_aggregation_interval  = var.max_aggregation_interval
}

output "flow_log_id" {
  value = aws_flow_log.vpc_flow_log.id
}

output "flow_log_arn" {
  value = aws_flow_log.vpc_flow_log.arn
}
