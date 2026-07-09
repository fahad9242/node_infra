# Both SGs live in this module so the ecs_sg -> alb_sg reference resolves
# locally, avoiding a cross-module dependency cycle.

# ---------------------------------------------------------------------------
# ALB security group — public HTTP/HTTPS in, all out.
# ---------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "ALB: allow inbound 80/443 from the internet."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from anywhere"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from anywhere"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------------------------------------------------------------------------
# ECS service security group — container port ONLY from the ALB SG, all out.
# ---------------------------------------------------------------------------
resource "aws_security_group" "ecs" {
  name        = "${var.name_prefix}-ecs-sg"
  description = "ECS tasks: allow inbound container port only from the ALB."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-ecs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  description                  = "Container port from the ALB security group only"
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_all" {
  security_group_id = aws_security_group.ecs.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------------------------------------------------------------------------
# Additive rule on the EXISTING shared VPC-endpoint SG: allow 443 from this
# env's ECS tasks so they can reach the ECR/Logs interface endpoints (private
# DNS routes ECR traffic to those endpoints, not the NAT). This adds ONE
# ingress source and leaves every existing rule on that SG untouched.
# ---------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "endpoints_from_ecs" {
  count = var.vpc_endpoint_sg_id != "" ? 1 : 0

  security_group_id            = var.vpc_endpoint_sg_id
  description                  = "HTTPS from ${var.name_prefix} ECS tasks (VPC interface endpoints)"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs.id
}
