
data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "iam_read_only_access" {
  arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

resource "aws_iam_policy" "allow_aws_account_terraform_state_access" {
  name = "AllowAwsAccountTerraformStateAccess"

  policy = data.aws_iam_policy_document.allow_aws_account_terraform_shared_state_access.json
}

resource "aws_iam_policy" "allow_infrastructure_terraform_state_access" {
  name = "AllowInfrastructureTerraformStateAccess"

  policy = data.aws_iam_policy_document.allow_infrastructure_terraform_shared_state_access.json
}

data "aws_iam_policy_document" "allow_aws_account_terraform_shared_state_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:CreateBucket"
    ]
    resources = [
      aws_s3_bucket.terraform_bucket.arn
    ]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      format("%s/aws-account/terraform.tfstate", aws_s3_bucket.terraform_bucket.arn)
    ]
  }
  statement {
    actions = [
      "dynamodb:UntagResource",
      "dynamodb:TagResource",
      "dynamodb:PutItem",
      "dynamodb:List*",
      "dynamodb:GetItem",
      "dynamodb:Describe*",
      "dynamodb:DeleteTable",
      "dynamodb:DeleteItem",
      "dynamodb:CreateTable"
    ]
    resources = [
      aws_dynamodb_table.terraform_state_lock.arn
    ]
  }
}

data "aws_iam_policy_document" "allow_infrastructure_terraform_shared_state_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:CreateBucket"
    ]
    resources = [
      aws_s3_bucket.terraform_bucket.arn
    ]
  }
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      format("%s/aws-account/terraform.tfstate", aws_s3_bucket.terraform_bucket.arn)
    ]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      format("%s/infrastructure/terraform.tfstate", aws_s3_bucket.terraform_bucket.arn)
    ]
  }
  statement {
    actions = [
      "dynamodb:UntagResource",
      "dynamodb:TagResource",
      "dynamodb:PutItem",
      "dynamodb:List*",
      "dynamodb:GetItem",
      "dynamodb:Describe*",
      "dynamodb:DeleteItem",
    ]
    resources = [
      aws_dynamodb_table.terraform_state_lock.arn
    ]
  }
}
