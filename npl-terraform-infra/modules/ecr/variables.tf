variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE tag policy."
  type        = string
  default     = "IMMUTABLE"
}

variable "keep_last_images" {
  description = "Number of most-recent tagged images to retain."
  type        = number
  default     = 10
}

variable "untagged_expire_days" {
  description = "Days after which untagged images expire."
  type        = number
  default     = 14
}
