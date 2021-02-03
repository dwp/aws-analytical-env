
# Note that the CONTAINER_VERSION environment variable below is just a dummy
# variable. If you need the ECS service to deploy an updated container version,
# just change that number (to anything). Future work will put proper version
# tags on the container image itself, at which point that psuedo-version
# environment variable can be removed again
resource "aws_ecs_task_definition" "proxy" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "2048"
  task_role_arn            = aws_iam_role.proxy.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.ecr_dkr_endpoint}/squid-s3:latest",
    "name": "squid-s3",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.proxy_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.proxy.name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "container-internet-proxy"
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
        "name": "SQUID_CONFIG_S3_BUCKET",
        "value": "${var.config_bucket.id}"
      },
      {
        "name": "SQUID_CONFIG_S3_PREFIX",
        "value": "${local.squid_config_s3_main_prefix}"
      },
      {
        "name": "CONTAINER_VERSION",
        "value": "0.0.2"
      },
      {
        "name": "PROXY_CFG_CHANGE_DEPENDENCY",
        "value": "${md5(data.template_file.squid_conf.rendered)}"
      },
      {
        "name": "PROXY_WHITELIST_CHANGE_DEPENDENCY",
        "value": "${md5(data.template_file.whitelist.rendered)}"
      }
    ]
  }
]
DEFINITION
  tags                  = merge(var.common_tags, { Name : "${var.name_prefix}-proxy-td" })
}

resource "aws_ecs_service" "proxy" {
  name            = var.name
  cluster         = var.ecs_cluster
  task_definition = aws_ecs_task_definition.proxy.arn
  desired_count   = length(data.aws_availability_zones.available.names)
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.internet_proxy.id]
    subnets         = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.proxy.arn
    container_name   = "squid-s3"
    container_port   = var.proxy_port
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-proxy-ecs" })
}

