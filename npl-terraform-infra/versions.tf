terraform {
  required_version = ">= 1.10.0" # S3 native state locking (use_lockfile) requires >= 1.10

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote state backend (S3, native S3 locking — no DynamoDB table needed).
  # Credentials come from the caller's ambient AWS credentials (SSO profile
  # locally, OIDC-assumed role in CI) — none are hardcoded here.
  # ---------------------------------------------------------------------------
  backend "s3" {
    bucket       = "npl-terraform-infra"
    key          = "staging/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
  }
}
