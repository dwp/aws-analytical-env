resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.name_prefix}-lb-tg"
  target_type = "ip"
  protocol    = "HTTP"
  port        = var.container_port
  vpc_id      = var.vpc_id
  health_check {
    path     = var.health_check_path
    port     = var.container_port
    protocol = "HTTP"
  }
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-tg" })
}

resource "aws_lb_listener" "listener" {
  depends_on        = [aws_lb_target_group.lb_tg]
  load_balancer_arn = var.loadbalancer_arn
  port              = 9091
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.lb.arn
  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    type             = "forward"
  }
}
