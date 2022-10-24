#
# List user here by adding `aws_iam_user` segments:
#
# ```hcl
# resource "aws_iam_user" "myuser" {
#   name = "myuser"
# }
# ```
#
# You can import existing users by running:
# ```sh
# terraform import aws_iam_user.myuser myuser
# ```
#
# or as data
#
# ```hcl
# data "aws_iam_user" "myuser" {
#   user_name = "myuser"
# }
# ```
#
# If user is declared as a resource, `terraform destroy` will try to remove this user
# if this is undesired, add the following lifecycle block to those users or declare them
# as data when not managing them with terraform.
#
# ```hcl
# resource "aws_iam_user" "myuser" {
#   name = "myuser"
#   lifecycle {
#     prevent_destroy = true
#   }
# }
# ```
