output "lb" {
  value = aws_lb.lb
}

output "lb_sg" {
  value = aws_security_group.lb_sg
}

output "fqdn" {
  value = aws_route53_record.record.fqdn
}
