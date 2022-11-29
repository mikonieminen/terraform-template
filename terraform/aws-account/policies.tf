
data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "iam_read_only_access" {
  arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

data "aws_iam_policy" "rds_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

data "aws_iam_policy" "route53_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

data "aws_iam_policy" "ecr_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

data "aws_iam_policy" "ecs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "aws_iam_policy" "ec2_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

data "aws_iam_policy" "vpc_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

data "aws_iam_policy" "cognito_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
}

data "aws_iam_policy" "cognito_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

data "aws_iam_policy" "acm_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

data "aws_iam_policy" "acm_read_only" {
  arn = "arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly"
}

data "aws_iam_policy" "api_gateway_administrator" {
  arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}

resource "aws_iam_policy" "allow_aws_account_terraform_state_access" {
  name = "${var.project_name}_AllowAwsAccountTerraformStateAccess"

  policy = data.aws_iam_policy_document.allow_aws_account_terraform_shared_state_access.json
}

resource "aws_iam_policy" "allow_infrastructure_terraform_state_access" {
  name = "${var.project_name}_AllowInfrastructureTerraformStateAccess"

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
      format("%s/infrastructure/terraform.tfstate", aws_s3_bucket.terraform_bucket.arn),
      format("%s/env:/*/infrastructure/terraform.tfstate", aws_s3_bucket.terraform_bucket.arn)
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

data "aws_iam_policy_document" "assume_ec2_instance_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
