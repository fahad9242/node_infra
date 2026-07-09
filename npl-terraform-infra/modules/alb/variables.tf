variable "name_prefix" {
  description = "Prefix for ALB / target group names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID the target group registers targets in."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs to place the ALB in."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB."
  type        = string
}

variable "container_port" {
  description = "Port targets (Fargate task ENIs) receive traffic on."
  type        = number
}

variable "health_check_path" {
  description = "HTTP path used for target group health checks."
  type        = string
  default     = "/health"
}

variable "enable_https" {
  description = "Create the HTTPS:443 listener and redirect HTTP->HTTPS. Must be known at plan time."
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM cert ARN for the HTTPS listener (used only when enable_https = true)."
  type        = string
  default     = ""
}
