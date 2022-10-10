resource "aws_iam_role" "infra_admin" {
  name               = "InfraAdmin"
  assume_role_policy = data.aws_iam_policy_document.assume_infra_admin_role.json
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

resource "aws_iam_policy" "allow_assume_infra_admin_role" {
  name = "AllowAssumeInfraAdminRole"

  policy = data.aws_iam_policy_document.allow_assume_infra_admin_role.json
}

data "aws_iam_policy_document" "allow_assume_infra_admin_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.infra_admin.arn]
  }
}

resource "aws_iam_role_policy_attachment" "iam_read_only_access" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = data.aws_iam_policy.iam_read_only_access.arn
}


resource "aws_iam_role_policy_attachment" "allow_infrastructure_terraform_state_access" {
  role       = aws_iam_role.infra_admin.name
  policy_arn = aws_iam_policy.allow_infrastructure_terraform_state_access.arn
}
