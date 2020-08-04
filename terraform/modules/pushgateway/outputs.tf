output push_gateway_sg {
  value = aws_security_group.ecs_tasks_sg.id
}
