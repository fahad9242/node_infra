# ---------------------------------------------------------------------------
# Global / provider
# ---------------------------------------------------------------------------
variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "Named AWS CLI/SDK profile used for credentials (~/.aws). Empty = use the ambient credential chain (e.g. CI's OIDC-assumed role)."
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Prefix applied to all created resource names."
  type        = string
  default     = "wheelchair-staging"
}

variable "tags" {
  description = "Common tags merged onto every resource via provider default_tags."
  type        = map(string)
  default = {
    Project     = "wheelchair"
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Existing infrastructure lookups (data sources)
# ---------------------------------------------------------------------------
variable "vpc_name" {
  description = "Name tag of the existing VPC to reference."
  type        = string
  default     = "vpc_wheelchair_staging"
}

variable "public_subnet_name_pattern" {
  description = "Name tag pattern matching the existing PUBLIC subnets (route to IGW)."
  type        = string
  default     = "wheelchair_staging_subnet_public*"
}

variable "private_subnet_name_pattern" {
  description = "Name tag pattern matching the existing PRIVATE subnets (route to NAT)."
  type        = string
  default     = "wheelchair_staging_subnet_private*"
}

# ---------------------------------------------------------------------------
# ECR
# ---------------------------------------------------------------------------
variable "ecr_repository_name" {
  description = "Name of the ECR repository to create."
  type        = string
  default     = "wheelchair-staging-app"
}

variable "ecr_image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE tag policy for the ECR repository."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "ecr_keep_last_images" {
  description = "Number of most-recent tagged images to retain in the lifecycle policy."
  type        = number
  default     = 10
}

variable "ecr_untagged_expire_days" {
  description = "Days after which untagged images expire."
  type        = number
  default     = 14
}

# ---------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------
variable "s3_bucket_name" {
  description = "Globally-unique name of the application S3 bucket to create."
  type        = string
  default     = "wheelchair-staging-app-675475398281"
}

# ---------------------------------------------------------------------------
# Networking / security
# ---------------------------------------------------------------------------
variable "container_port" {
  description = "Port the application container listens on (ALB -> ECS ingress)."
  type        = number
  default     = 8080
}

variable "vpc_endpoint_sg_name" {
  description = "Name of the EXISTING security group fronting the shared VPC interface endpoints (ECR/Logs). An additive 443 ingress rule from this env's ecs_sg is added to it so tasks can pull images."
  type        = string
  default     = "pe_sg_wheelchair_staging"
}

# ---------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------
variable "health_check_path" {
  description = "HTTP path the ALB target group uses for health checks."
  type        = string
  default     = "/health"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener. Empty leaves HTTPS disabled/stubbed."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Custom domain / TLS
# ---------------------------------------------------------------------------
variable "enable_https" {
  description = "Provision an ACM cert (DNS-validated), an HTTPS listener, HTTP->HTTPS redirect, and a Route53 ALIAS for domain_name."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "FQDN to serve the app on (ACM subject + Route53 ALIAS -> ALB)."
  type        = string
  default     = "cltx-staging.nplhomemedical.app"
}

variable "route53_zone_name" {
  description = "Public Route53 hosted zone that owns domain_name (no trailing dot)."
  type        = string
  default     = "nplhomemedical.app"
}

# ---------------------------------------------------------------------------
# ECS / Fargate
# ---------------------------------------------------------------------------
variable "container_image" {
  description = "Container image for the task. Empty defaults to the created ECR repo URL (:latest)."
  type        = string
  default     = ""
}

variable "container_command" {
  description = "Optional container command override (ECS container 'command'). Empty = image default."
  type        = list(string)
  default     = []
}

variable "task_cpu" {
  description = "Fargate task CPU units (e.g. 256, 512, 1024)."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory in MiB (e.g. 512, 1024, 2048)."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Number of ECS service tasks to run."
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days."
  type        = number
  default     = 30
}
