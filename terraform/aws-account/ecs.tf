
# This defines needed policies and roles for ECS servies, tasks and containers

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.project_name}_ecsTaskExecutionRole"
  description        = "Allows ECS tasks to call AWS services on your behalf."
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_task_execution_role.json
}

data "aws_iam_policy_document" "assume_ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
