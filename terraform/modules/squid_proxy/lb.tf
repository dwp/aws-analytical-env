resource "aws_lb" "container_internet_proxy" {
  name               = "${var.name}-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags               = var.common_tags

  access_logs {
    bucket  = var.log_bucket_id
    prefix  = "ELBLogs/${var.name}"
    enabled = true
  }
}

resource "aws_lb_target_group" "proxy" {
  name              = "${var.name}-tg"
  port              = var.proxy_port
  protocol          = "TCP"
  target_type       = "ip"
  vpc_id            = var.vpc_id
  proxy_protocol_v2 = true

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    { Name = var.name },
  )
}

resource "aws_lb_listener" "container_internet_proxy" {
  load_balancer_arn = aws_lb.container_internet_proxy.arn
  port              = var.proxy_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy.arn
  }
}

