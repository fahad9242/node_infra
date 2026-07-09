# ---------------------------------------------------------------------------
# Staging environment values — committed (no secrets: account id and domain
# name here are not sensitive). Used by both local `terraform plan` and CI
# via `-var-file=staging.tfvars`.
# ---------------------------------------------------------------------------

# ===========================================================================
# CHANGE THESE when reusing this stack for a different app.
# Also update TF_STATE_KEY, ECR_REPOSITORY, ECS_CLUSTER, ECS_SERVICE in
# .github/workflows/deploy.yml to match, and the AWS IAM policy scoped to
# these resource names (see README).
# ===========================================================================

name_prefix = "cltx-staging-001" # prefixes every resource name (ECR, ECS, IAM, SGs, ALB, log group)

tags = {
  Project     = "cltx"
  Environment = "staging"
  ManagedBy   = "terraform"
  Owner       = "devops"
}

# ECR / S3 names must be unique per app (S3 bucket name must be globally unique)
ecr_repository_name = "cltx-staging-001-app"
s3_bucket_name      = "cltx-staging-001-app-675475398281"

# App / networking — must match the app's own listen port + health route
container_port    = 3000
health_check_path = "/health"

# Custom domain (ACM DNS-validated, HTTPS listener, HTTP->HTTPS redirect, ALIAS)
domain_name       = "cltx-staging.nplhomemedical.app"
route53_zone_name = "nplhomemedical.app" # only change if the new domain is under a different parent zone

# Fargate sizing — adjust to the new app's actual needs
task_cpu      = 256
task_memory   = 512
desired_count = 1

# ===========================================================================
# SHARED / rarely need to change — same AWS account, region, and network
# regardless of which app this stack is deployed for.
# ===========================================================================

region = "us-west-2"

# Existing infra lookups (filter by Name tag — no hardcoded IDs)
vpc_name                    = "vpc_wheelchair_staging"
public_subnet_name_pattern  = "wheelchair_staging_subnet_public*"
private_subnet_name_pattern = "wheelchair_staging_subnet_private*"

ecr_image_tag_mutability = "IMMUTABLE"
ecr_keep_last_images     = 10
ecr_untagged_expire_days = 14

enable_https       = true
log_retention_days = 30

# container_image is intentionally omitted here — the app-deploy workflow job
# always passes it explicitly as -var="container_image=<ecr>:<tag>". The
# very first `terraform apply` (before any image has been pushed) will use
# the ecr/module default of ":latest", which the ECS service can't yet pull;
# that's expected — push the first image right after to make it healthy.
