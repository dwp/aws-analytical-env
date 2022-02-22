resource "aws_ecs_task_definition" "livy-proxy" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "1024"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.image_ecr_repository}:${var.livy_image_tag}",
    "name": "${var.name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.container_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.livy-proxy.name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "container-livy-proxy"
      }
    },
    "placementStrategy": [
      {
        "field": "attribute:ecs.availability-zone",
        "type": "spread"
      }
    ],
    "environment": [
      {
        "name": "LIVY_URL",
        "value": "http://${var.livy_dns_name}:8998"
      },
      {
        "name": "KEYSTORE_DATA",
        "value": "${var.base64_keystore_data}"
      }
    ]
  }
]
DEFINITION
  tags                  = merge(var.common_tags, { Name : "${var.name}-proxy-td" })
}

resource "aws_ecs_service" "livy-proxy" {
  name            = var.name
  cluster         = data.aws_ecs_cluster.ecs_main_cluster.arn
  task_definition = aws_ecs_task_definition.livy-proxy.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    subnets         = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.name
    container_port   = var.container_port
  }
  tags = merge(var.common_tags, { Name : "${var.name}-proxy-ecs" })

  lifecycle {
    ignore_changes = [desired_count]
  }
}
