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
# and if this is undesired, add the following lifecycle block to those users or declare
# them as data when not managing them with terraform.
#
# ```hcl
# resource "aws_iam_user" "myuser" {
#   name = "myuser"
#   lifecycle {
#     prevent_destroy = true
#   }
# }
# ```

data "aws_iam_user" "miko" {
  user_name = "miko"
}

resource "aws_key_pair" "miko" {
  key_name   = "miko@laptop:terraform-example"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+/dO8atoS6XEkz/fwMnooz3MynU5IpcqLuyiXkt31S miko@laptop:terraform-example"
}
