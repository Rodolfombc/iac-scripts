variable "users" {
  description = "List of users names that will be granted permissions"
  type = list
}

variable "policy_id" {
  description = "ID for the policy document"
  type = string
}
