variable "name_prefix" {
  description = "Prefix for cluster / service / task names."
  type        = string
}

variable "region" {
  description = "AWS region (for the awslogs log driver)."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs the ECS service tasks run in."
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group ID applied to the service ENIs."
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task (application) role."
  type        = string
}

variable "container_image" {
  description = "Fully-qualified container image URI."
  type        = string
}

variable "container_command" {
  description = "Optional container command override. Empty = image default."
  type        = list(string)
  default     = []
}

variable "container_port" {
  description = "Port the container exposes."
  type        = number
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
}

variable "task_memory" {
  description = "Fargate task memory (MiB)."
  type        = number
}

variable "desired_count" {
  description = "Number of tasks the service maintains."
  type        = number
}

variable "log_retention_days" {
  description = "CloudWatch log group retention (days)."
  type        = number
  default     = 30
}

variable "target_group_arn" {
  description = "ALB target group ARN to attach the service to."
  type        = string
}
