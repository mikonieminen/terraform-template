
# Define here container repositories for your application containers

# resource "aws_ecr_repository" "my_app" {
#   name                 = "my-app"

#   # TODO: change this to "IMMUTABLE"
#   # Usually tags should not move, but in the beginning
#   # it's probably better to allow moving them. Once thigs
#   # are running smooth(er), it's good idea to change this
#   # to "IMMUTABLE".
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }
