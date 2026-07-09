output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = module.ecs.service_name
}

output "s3_bucket_name" {
  description = "Name of the application S3 bucket."
  value       = module.s3.bucket_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group fronting the ECS service."
  value       = module.alb.target_group_arn
}

output "app_url" {
  description = "Public HTTPS URL for the app (custom domain), when HTTPS is enabled."
  value       = var.enable_https ? "https://${var.domain_name}" : null
}

output "acm_certificate_arn" {
  description = "ARN of the issued ACM certificate, when HTTPS is enabled."
  value       = var.enable_https ? module.acm[0].certificate_arn : null
}
