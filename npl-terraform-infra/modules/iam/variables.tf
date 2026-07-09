variable "name_prefix" {
  description = "Prefix for IAM role/policy names."
  type        = string
}

variable "region" {
  description = "AWS region (used to scope CloudWatch Logs ARNs)."
  type        = string
}

variable "account_id" {
  description = "AWS account ID (used to scope ARNs)."
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the app S3 bucket the task role is scoped to."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository the execution role may pull from."
  type        = string
}
