# ---------------------------------------------------------------------------
# Root module — wires the child modules together and threads outputs between
# them. Module dependency order (implicit via references):
#
#   ecr ─┐
#   s3 ──┼─> iam ──┐
#        └─────────┼─> ecs
#   security ─> alb ┘
# ---------------------------------------------------------------------------

locals {
  # Default the container image to the freshly-created ECR repo unless the
  # caller overrides it.
  container_image = var.container_image != "" ? var.container_image : "${module.ecr.repository_url}:latest"
}

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  keep_last_images     = var.ecr_keep_last_images
  untagged_expire_days = var.ecr_untagged_expire_days
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name
}

module "iam" {
  source = "./modules/iam"

  name_prefix        = var.name_prefix
  region             = data.aws_region.current.name
  account_id         = data.aws_caller_identity.current.account_id
  s3_bucket_arn      = module.s3.bucket_arn
  ecr_repository_arn = module.ecr.repository_arn
}

module "security" {
  source = "./modules/security"

  name_prefix        = var.name_prefix
  vpc_id             = data.aws_vpc.main.id
  container_port     = var.container_port
  vpc_endpoint_sg_id = data.aws_security_group.vpc_endpoints.id
}

# DNS-validated ACM certificate for the custom domain (created only when HTTPS
# is enabled). No dependency on the ALB, so there's no module cycle.
module "acm" {
  count  = var.enable_https ? 1 : 0
  source = "./modules/acm"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.main[0].zone_id
}

module "alb" {
  source = "./modules/alb"

  name_prefix       = var.name_prefix
  vpc_id            = data.aws_vpc.main.id
  public_subnet_ids = data.aws_subnets.public.ids
  alb_sg_id         = module.security.alb_sg_id
  container_port    = var.container_port
  health_check_path = var.health_check_path

  enable_https = var.enable_https
  # Prefer the module-issued cert; fall back to an explicitly-passed ARN.
  acm_certificate_arn = var.enable_https ? module.acm[0].certificate_arn : var.acm_certificate_arn
}

# ALIAS A record: domain_name -> ALB. Depends on the ALB (not on ACM), so no cycle.
resource "aws_route53_record" "app" {
  count = var.enable_https ? 1 : 0

  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix             = var.name_prefix
  region                  = data.aws_region.current.name
  private_subnet_ids      = data.aws_subnets.private.ids
  ecs_sg_id               = module.security.ecs_sg_id
  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn
  container_image         = local.container_image
  container_command       = var.container_command
  container_port          = var.container_port
  task_cpu                = var.task_cpu
  task_memory             = var.task_memory
  desired_count           = var.desired_count
  log_retention_days      = var.log_retention_days
  target_group_arn        = module.alb.target_group_arn

  # Explicit dependency on the ALB module: the ECS service must not be created
  # until the HTTP listener exists, otherwise target registration races the LB.
  depends_on = [module.alb]
}
