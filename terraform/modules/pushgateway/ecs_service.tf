resource "aws_ecs_service" "service" {
  depends_on              = [aws_lb_listener.listener]
  name                    = "${var.name_prefix}-service"
  cluster                 = data.aws_ecs_cluster.ecs_main_cluster.arn
  task_definition         = aws_ecs_task_definition.td.arn
  launch_type             = "FARGATE"
  enable_ecs_managed_tags = true

  desired_count = 1

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    subnets         = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-ecs-service" })
}
