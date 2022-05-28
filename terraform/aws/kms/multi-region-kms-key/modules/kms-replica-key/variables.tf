variable "aws_account_id" {
  type = string
}

variable "primary_key_arn" {
  description = "ARN of the KMS key from which the replica key will be created"
  type        = string
}