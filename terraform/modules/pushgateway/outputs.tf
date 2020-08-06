output "push_gateway_sg" {
  value = aws_security_group.ecs_tasks_sg.id
}

output "lb" {
  value = aws_lb.lb
}

output "lb_sg" {
  value = aws_security_group.lb_sg
}

output "fqdn" {
  value = aws_route53_record.record.fqdn
}
