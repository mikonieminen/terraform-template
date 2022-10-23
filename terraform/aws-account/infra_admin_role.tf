resource "aws_iam_role" "infra_admin" {
  name               = "InfraAdmin"
  assume_role_policy = data.aws_iam_policy_document.assume_infra_admin_role.json
}

resource "aws_iam_role_policy_attachment" "iam_read_only_access" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = data.aws_iam_policy.iam_read_only_access.arn
}

resource "aws_iam_role_policy_attachment" "rds_full_access" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = data.aws_iam_policy.rds_full_access.arn
}

resource "aws_iam_role_policy_attachment" "cognito_power_user" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = data.aws_iam_policy.cognito_power_user.arn
}

resource "aws_iam_role_policy_attachment" "allow_infrastructure_terraform_state_access" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = aws_iam_policy.allow_infrastructure_terraform_state_access.arn
}

resource "aws_iam_role_policy_attachment" "allow_running_packer" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = aws_iam_policy.allow_running_packer.arn
}

resource "aws_iam_role_policy_attachment" "allow_sops_updates" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = aws_iam_policy.allow_sops_updates.arn
}

resource "aws_iam_role_policy_attachment" "infra_admin_machine_control" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = aws_iam_policy.infra_admin_machine_control.arn
}

resource "aws_iam_role_policy_attachment" "infra_admin_network_control" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = aws_iam_policy.infra_admin_network_control.arn
}

resource "aws_iam_policy" "allow_assume_infra_admin_role" {
  name = "AllowAssumeInfraAdminRole"

  policy = data.aws_iam_policy_document.allow_assume_infra_admin_role.json
}

resource "aws_iam_policy" "allow_running_packer" {
  name = "AllowRunningPacker"

  policy = data.aws_iam_policy_document.allow_running_packer.json
}

resource "aws_iam_policy" "allow_sops_updates" {
  name = "AllowSopsUpdates"

  policy = data.aws_iam_policy_document.allow_sops_updates.json
}

resource "aws_iam_policy" "infra_admin_machine_control" {
  name = "InfraAdminMachineControl"

  policy = local.infra_admin_machine_control_merged_policy
}

resource "aws_iam_policy" "infra_admin_network_control" {
  name = "InfraAdminNetworkControl"

  policy = local.infra_admin_network_control_merged_policy
}

# To go around the limit of having maximum of 10 policies attached
# to a role, we'll merge some of the managed policies into bigger
# ones. We also need to limit size of the polices and split them
# in two, because otherwise we will hit size limit of the policy
# document itself.
locals {
  machine_control_iam_policies = [
    data.aws_iam_policy.ecr_full_access.policy,
    data.aws_iam_policy.ecs_full_access.policy,
    data.aws_iam_policy.ec2_full_access.policy,
    # # TODO: Uncomment when in need of passing roles to EC2 instances
    # data.aws_iam_policy_document.pass_machine_roles.json,
  ]
  network_control_iam_policies = [
    data.aws_iam_policy.route53_full_access.policy,
    data.aws_iam_policy.vpc_full_access.policy,
    data.aws_iam_policy.api_gateway_administrator.policy,
    data.aws_iam_policy.acm_full_access.policy,
    data.aws_iam_policy_document.allow_cloudfront_update_distribution_for_cognito_user_pool_domain.json,
  ]
  machine_control_iam_policy_statements = flatten([
    for policy in local.machine_control_iam_policies : jsondecode(policy).Statement
  ])
  network_control_iam_policy_statements = flatten([
    for policy in local.network_control_iam_policies : jsondecode(policy).Statement
  ])
  infra_admin_machine_control_merged_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.machine_control_iam_policy_statements
  })
  infra_admin_network_control_merged_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.network_control_iam_policy_statements
  })
}

data "aws_iam_policy_document" "allow_assume_infra_admin_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.infra_admin.arn]
  }
}

data "aws_iam_policy_document" "assume_infra_admin_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
      ]
    }
  }
}

# # Define here whare roles infra-admin can pass to different machines
# data "aws_iam_policy_document" "pass_machine_roles" {
#   statement {
#     actions = [
#       "iam:PassRole"
#     ]
#     resources = [
#       # TODO: list here roles that infra admin can pass to different EC2 instances
#     ]
#   }
# }

data "aws_iam_policy_document" "allow_running_packer" {
  statement {
    actions = [
      "iam:GetInstanceProfile"
    ]
    resources = [
      "arn:aws:iam::*:instance-profile/*"
    ]
  }
  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances"
    ]
    resources = [
      "*"
    ]
  }
}

# This policy allows infra-admin to update KMS managed keys in SOPS files
# See https://github.com/mozilla/sops#assuming-roles-and-using-kms-in-various-aws-accounts
data "aws_iam_policy_document" "allow_sops_updates" {
  statement {
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "allow_cloudfront_update_distribution_for_cognito_user_pool_domain" {
  statement {
    actions = [
      "cloudfront:UpdateDistribution",
    ]
    # TODO: how to limit resources to match cognito user pools?
    resources = [
      "*"
    ]
  }
}
