terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }

  required_version = ">= 1.1"
}

provider "aws" {
  profile = "default"
}

module "kms_primary_key_policy" {
  source = "../../modules/iam/policy/log-group"

  users = ["root", "user/infrauser"]
}

###########################
# Creating a customer 
# managed KMS key
###########################
module "custom_kms_primary_key" {
  source = "../../modules/kms/primary-key"

  alias                   = "primary-key"
  description             = "KMS Key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
  multi_region            = false
  policy                  = module.kms_primary_key_policy.log_group_policy_json
}
