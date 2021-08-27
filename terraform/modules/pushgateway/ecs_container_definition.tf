data "aws_ecr_image" "ecr_image" {
  provider = aws.management

  repository_name = split("/", var.image_ecr_repository)[1]
  image_tag       = "latest"
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.49.0"

  container_name               = var.container_name
  container_image              = "${var.image_ecr_repository}@${data.aws_ecr_image.ecr_image.image_digest}"
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  port_mappings = [{
    containerPort = var.container_port
    hostPort      = var.container_port
    protocol      = "tcp"
  }]
  container_cpu = var.container_cpu
  essential     = true
  environment = [
    {
      name  = "PROMETHEUS"
      value = true
    }
  ]
  log_configuration = {
    secretOptions = []
    logDriver     = "awslogs"
    options = {
      "awslogs-group"         = aws_cloudwatch_log_group.logs.name
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/ecs/${data.aws_ecs_cluster.ecs_main_cluster.cluster_name}/${var.name_prefix}"
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-ecs-logs" })
}
