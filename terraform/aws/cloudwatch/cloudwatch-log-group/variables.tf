variable "name" {
  description = "Name of the log group"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt logs"
  type        = string
}
