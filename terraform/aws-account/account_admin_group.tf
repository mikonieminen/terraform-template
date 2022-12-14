# If this already exists import it with:
# ```sh
# terraform import aws_iam_group.account_admins AccountAdmins
# ```
resource "aws_iam_group" "account_admins" {
  name = "${var.project_name}_AccountAdmins"
}

resource "aws_iam_group_membership" "account_admins" {
  name = "${var.project_name}-account-admin-group-membership"

  users = [
    # TODO: add users here who can manage this AWS account
  ]

  group = aws_iam_group.account_admins.name
}

resource "aws_iam_group_policy_attachment" "account_admins_can_assume_account_admin_role" {
  group      = aws_iam_group.account_admins.name
  policy_arn = aws_iam_policy.allow_assume_account_admin_role.arn
}
