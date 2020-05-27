# ---------------------------------------------------------------------------------------------------------------------
# AWS LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------
output "lb" {
  description = "$${var.name_prefix} Load Balancer"
  value       = aws_lb.lb
}

output "fqdn" {
  description = "The FQDN DNS record we created"
  value       = aws_route53_record.record.fqdn
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------
output "lb_sg" {
  description = "$${var.name_prefix} Load Balancer Security Group - The ID of the security group"
  value       = aws_security_group.lb_sg
}

output "alb_listener" {
  value = aws_lb_listener.listener
}
