provider "aws" {
  region = var.region
  # Empty string (the CI default) falls back to the ambient credential chain
  # (OIDC-assumed role env vars in GitHub Actions); a non-empty value uses
  # that named local SSO/CLI profile.
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = var.tags
  }
}
