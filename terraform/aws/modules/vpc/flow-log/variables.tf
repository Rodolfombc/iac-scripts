variable "traffic_type" {
  description = "The type of traffic to capture"
  type        = string
  default     = "ALL"
  validation {
    condition     = var.traffic_type == "ACCEPT" || var.traffic_type == "REJECT" || var.traffic_type == "ALL"
    error_message = "traffic_type can only be ACCEPT, REJECT or ALL"
  }
}

variable "max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record."
  type        = number
  default     = 600
  validation {
    condition     = var.max_aggregation_interval == 60 || var.max_aggregation_interval == 600
    error_message = "max_aggregation_interval can only be 60 seconds or 600 seconds"
  }
}

variable "log_destination" {
  description = "ARN of the log group where flowlogs will be sent"
  type = string
}

variable "vpc_id" {
  description = "ID of the VPC from where we'll get flowlogs"
  type = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM Role created for vpc flowlogs"
  type = string
}

variable "iam_role_id" {
  description = "ID of the IAM Role created for vpc flowlogs"
  type = string
}