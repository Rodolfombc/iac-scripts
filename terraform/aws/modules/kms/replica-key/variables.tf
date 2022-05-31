variable "alias" {
  description = "Name of the KMS key"
  type = string
}

variable "description" {
  description = "Description of the KMS key"
  type = string
}

variable "deletion_window_in_days" {
  description = "Time in days when the KMS key will be deleted"
  type = number
}

variable "enabled" {
  description = "Tells if KMS key is enabled when created"
  type = bool
}

variable "policy" {
  description = "A valid policy JSON document"
  type        = string
}

variable "primary_key_arn" {
  description = "ARN of the KMS key from which the replica key will be created"
  type        = string
}
