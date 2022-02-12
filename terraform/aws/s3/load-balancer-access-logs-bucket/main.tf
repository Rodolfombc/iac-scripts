terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }

  required_version = ">= 0.15"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

###################################
# A secret from secrets manager
###################################
data "aws_secretsmanager_secret" "bucket_secret_name" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "bucket_name" {
  secret_id = data.aws_secretsmanager_secret.bucket_secret_name.id
}

########################
# Bucket creation
########################
resource "aws_s3_bucket" "access_logs_bucket" {
  bucket = data.aws_secretsmanager_secret_version.bucket_name.secret_string
}

##########################
# Bucket private access
##########################
resource "aws_s3_bucket_acl" "access_logs_bucket_acl" {
  bucket = aws_s3_bucket.access_logs_bucket.id
  acl    = "private"
}

#############################
# Enable bucket versioning
#############################
resource "aws_s3_bucket_versioning" "access_logs_bucket_versioning" {
  bucket = aws_s3_bucket.access_logs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

##########################################
# Enable default Server Side Encryption
##########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.access_logs_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

############################
# Creating Lifecycle Rule
############################
resource "aws_s3_bucket_lifecycle_configuration" "access_logs_bucket_lifecycle_rule" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.access_logs_bucket_versioning]

  bucket = aws_s3_bucket.access_logs_bucket.bucket

  rule {
    id = "basic_config"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }
}

########################
# Disabling bucket
# public access
########################
resource "aws_s3_bucket_public_access_block" "access_logs_bucket_access" {
  bucket = aws_s3_bucket.access_logs_bucket.id

  # Block public access
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

########################
# Policy to make this 
# bucket able to 
# receive access logs 
########################
data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "enable_access_logs_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.access_logs_bucket.arn}/*"
    ]
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.access_logs_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      "${aws_s3_bucket.access_logs_bucket.arn}"
    ]
  }
}

resource "aws_s3_bucket_policy" "enable_access_logs_policy" {
  bucket = aws_s3_bucket.access_logs_bucket.id
  policy = data.aws_iam_policy_document.enable_access_logs_policy.json
}
