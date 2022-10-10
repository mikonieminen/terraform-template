# If this already exists import it with:
# ```sh
# terraform import aws_iam_group.infrastructure_admins InfraAdmins
# ```
resource "aws_iam_group" "infra_admins" {
  name = "InfraAdmins"
}

resource "aws_iam_group_membership" "infra_admins" {
  name = "infra-admin-group-membership"

  users = [
    data.aws_iam_user.miko.user_name
  ]

  group = aws_iam_group.infra_admins.name
}

resource "aws_iam_group_policy_attachment" "account_admins_can_assume_infra_admin_role" {
  group      = aws_iam_group.infra_admins.name
  policy_arn = aws_iam_policy.allow_assume_infra_admin_role.arn
}
