variable "alias" {
  description = "Name of the KMS key"
  type = string
}

variable "description" {
  description = "Description of the KMS key"
  type = string
}

variable "key_usage" {
  description = "Specifies the intended use of the key"
  type = string
}

variable "deletion_window_in_days" {
  description = "Time in days when the KMS key will be deleted"
  type = number
}

variable "is_enabled" {
  description = "Tells if KMS key is enabled when created"
  type = bool
}

variable "multi_region" {
  description = "Tells if KMS key is multi region"
  type = bool
}

variable "policy" {
  description = "A valid policy JSON document"
  type        = string
}