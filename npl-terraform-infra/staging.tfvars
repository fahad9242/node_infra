# ---------------------------------------------------------------------------
# Staging environment values — committed (no secrets: account id and domain
# name here are not sensitive). Used by both local `terraform plan` and CI
# via `-var-file=staging.tfvars`.
# ---------------------------------------------------------------------------
region = "us-west-2"

name_prefix = "cltx-staging-001"

tags = {
  Project     = "cltx"
  Environment = "staging"
  ManagedBy   = "terraform"
  Owner       = "devops"
}

# Existing infra lookups (filter by Name tag — no hardcoded IDs)
vpc_name                    = "vpc_wheelchair_staging"
public_subnet_name_pattern  = "wheelchair_staging_subnet_public*"
private_subnet_name_pattern = "wheelchair_staging_subnet_private*"

# ECR
ecr_repository_name      = "cltx-staging-001-app"
ecr_image_tag_mutability = "IMMUTABLE"
ecr_keep_last_images     = 10
ecr_untagged_expire_days = 14

# S3 (must be globally unique)
s3_bucket_name = "cltx-staging-001-app-675475398281"

# App / networking — matches index.js (PORT env, /health route)
container_port    = 3000
health_check_path = "/health"

# Custom domain + TLS (ACM DNS-validated, HTTPS listener, HTTP->HTTPS redirect, ALIAS)
enable_https      = true
domain_name       = "cltx-staging.nplhomemedical.app"
route53_zone_name = "nplhomemedical.app"

# ECS / Fargate
task_cpu           = 256
task_memory        = 512
desired_count      = 1
log_retention_days = 30

# container_image is intentionally omitted here — the app-deploy workflow job
# always passes it explicitly as -var="container_image=<ecr>:<sha>". The
# very first `terraform apply` (before any image has been pushed) will use
# the ecr/module default of ":latest", which the ECS service can't yet pull;
# that's expected — push the first image right after to make it healthy.
