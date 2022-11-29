terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # When starting from scratch:
  # 1) make sure the the below `backend` block is commented out
  # 2) run:
  # ```sh
  # terraform init
  # terraform apply -target=aws_s3_bucket.terraform_bucket -target=aws_dynamodb_table.terraform_state_lock
  # ```
  # 3) uncomment the following `backend` block
  # 4) run the following command by replacing values from the earlier output
  # ```sh
  # terraform init -backend-config="bucket=<bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<dynamodb_table>"
  # # answer `yes` when prompt for replacing pre-existing state while migrating from local to newly configured "s3" backend
  # ```
  #
  # When initializing the project using existing S3 bucket, simply get the output
  # from another user, replace values as above and execute the command:
  # ```sh
  # terraform init -backend-config="bucket=<bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<dynamodb_table>"
  # ```
  #
  # Doing it this way, none of these values are stored in plain text under version
  # control system. Alternatively, you could store these values in the `backend`
  # block and it's enough simply to run `terraform init` as the last step.
  #

  # backend "s3" {
  #   bucket         = ""
  #   key            = "aws-account/terraform.tfstate"
  #   encrypt        = true
  #   region         = ""
  #   dynamodb_table = ""
  # }
}

# Map current caller identity as data so that we use it below
data "aws_caller_identity" "current" {}

locals {
  default_bucket_name = format("%s-%s-terraform-backend", data.aws_caller_identity.current.account_id, var.project_name)
}

resource "aws_s3_bucket" "terraform_bucket" {
  # If var.terraform_backend_s3_bucket_name is empty, use default one
  bucket = coalesce(var.terraform_backend_s3_bucket_name, local.default_bucket_name)

  object_lock_enabled = true

  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}

resource "aws_s3_bucket_acl" "terraform_bucket_acl" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_bucket_encryption" {
  bucket = aws_s3_bucket.terraform_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "terraform_bucket_object_lock_configuration" {
  bucket = aws_s3_bucket.terraform_bucket.bucket

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 5
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${aws_s3_bucket.terraform_bucket.bucket}-state-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}
