variable "name_prefix" {
  description = "Prefix for security group names."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the security groups belong to."
  type        = string
}

variable "container_port" {
  description = "Port the ECS container listens on (ALB -> ECS ingress)."
  type        = number
}

variable "vpc_endpoint_sg_id" {
  description = "ID of the EXISTING shared VPC-endpoint security group. Empty disables the added rule. When set, an additive 443 ingress rule from ecs_sg is created on it."
  type        = string
  default     = ""
}
