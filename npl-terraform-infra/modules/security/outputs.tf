output "alb_sg_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "ecs_sg_id" {
  description = "ID of the ECS service security group."
  value       = aws_security_group.ecs.id
}
