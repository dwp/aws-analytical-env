resource "aws_lb" "lb" {
  name                             = "${var.name}-lb"
  internal                         = true
  load_balancer_type               = "application"
  subnets                          = var.subnet_ids
  security_groups                  = [aws_security_group.lb_sg.id]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 600
  tags                             = merge(var.common_tags, { Name = "${var.name}-alb" })

  access_logs {
    bucket  = var.log_bucket_id
    prefix  = "ELBLogs/${var.name}"
    enabled = true
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.name}-lb-tg"
  target_type = "ip"
  protocol    = "HTTP"
  port        = var.container_port
  vpc_id      = var.vpc_id
  health_check {
    path     = "/"
    port     = var.container_port
    protocol = "HTTP"
    matcher  = "200-299,401"
  }
  tags = merge(var.common_tags, { Name = "${var.name}-tg" })
}

resource "aws_lb_listener" "listener" {
  depends_on        = [aws_lb_target_group.lb_tg]
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.certificate.arn
  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    type             = "forward"
  }
}
