resource "aws_lb" "lb" {
  name                             = "${var.name_prefix}-lb"
  internal                         = var.internal_lb
  load_balancer_type               = "application"
  subnets                          = var.alb_subnets
  security_groups                  = [aws_security_group.lb_sg.id]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  tags                             = merge(var.common_tags, { Name = "${var.name_prefix}-alb" })

  access_logs {
    bucket  = var.logging_bucket
    prefix  = "ELBLogs/${var.name_prefix}"
    enabled = true
  }
}

resource "aws_wafregional_web_acl_association" "lb" {
  resource_arn = aws_lb.lb.arn
  web_acl_id   = var.wafregional_web_acl_id
}

// Rules are added later by orchestration and dataworks-analytical-frontend service
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.analytical-alb-cert-pub.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service unavailable"
      status_code  = "503"
    }
  }
}
