variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secret_name" {
  description = "S3 bucket secret name"
  type        = string
  default     = "secret-name-from-secrets-manager"
}
