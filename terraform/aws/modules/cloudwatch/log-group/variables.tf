variable "name" {
  description = "Name of the log group"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain log events in log group"
  type        = number
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt logs"
  type        = string
}
