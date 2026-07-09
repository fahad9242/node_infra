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
  #
  # Left empty intentionally: a `backend` block can't reference variables
  # (resolved before any var/local is evaluated), so bucket/key/region live
  # in backend.hcl instead, supplied via `terraform init -backend-config=backend.hcl`.
  # Reusing this stack elsewhere: copy backend.hcl, change only its `key` to a
  # different path in the same bucket — that's a distinct state file, so it
  # can never collide with or overwrite this stack's state.
  # ---------------------------------------------------------------------------
  backend "s3" {}
}
