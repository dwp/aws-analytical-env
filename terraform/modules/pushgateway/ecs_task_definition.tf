resource "aws_ecs_task_definition" "td" {
  family                = "${var.name_prefix}-td"
  container_definitions = module.container_definition.json_map_encoded_list
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  network_mode          = "awsvpc"

  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = ["FARGATE"]

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-td" })
}


