# ---------------------------------------------------------------------------
# Lookups for EXISTING infrastructure. Nothing here is created by this project.
# All lookups filter by Name tag (not hardcoded IDs) so the code stays portable
# across accounts/re-creations. IDs discovered at build time are recorded in the
# README for reference only.
# ---------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Existing VPC: vpc_wheelchair_staging (10.0.0.0/16)
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Public subnets — matched by Name tag pattern. Public/private status was
# confirmed against route tables at discovery time (public -> IGW, private -> NAT),
# not by name alone.
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = [var.public_subnet_name_pattern]
  }
}

# Private subnets — matched by Name tag pattern.
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = [var.private_subnet_name_pattern]
  }
}

# Existing security group fronting the shared VPC interface endpoints
# (ECR api/dkr, CloudWatch Logs, etc.). We add an ingress rule to it so this
# environment's ECS tasks can reach those endpoints — we never modify the
# endpoints, NAT, or the SG's other rules.
data "aws_security_group" "vpc_endpoints" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "group-name"
    values = [var.vpc_endpoint_sg_name]
  }
}

# Existing public hosted zone that owns domain_name (only looked up when HTTPS
# is enabled). Records are added to it; the zone itself is never modified.
data "aws_route53_zone" "main" {
  count        = var.enable_https ? 1 : 0
  name         = "${var.route53_zone_name}."
  private_zone = false
}
