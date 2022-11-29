resource "aws_iam_role" "account_admin" {
  name               = "${var.project_name}_AccountAdmin"
  assume_role_policy = data.aws_iam_policy_document.assume_account_admin_role.json
}

data "aws_iam_policy_document" "assume_account_admin_role" {
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

resource "aws_iam_policy" "allow_assume_account_admin_role" {
  name = "${var.project_name}_AllowAssumeAccountAdminRole"

  policy = data.aws_iam_policy_document.allow_assume_account_admin_role.json
}

data "aws_iam_policy_document" "allow_assume_account_admin_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.account_admin.arn]
  }
}

resource "aws_iam_role_policy_attachment" "administrator_access" {
  role       = aws_iam_role.account_admin.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

resource "aws_iam_role_policy_attachment" "allow_aws_account_terraform_state_access" {
  role       = aws_iam_role.account_admin.name
  policy_arn = aws_iam_policy.allow_aws_account_terraform_state_access.arn
}
