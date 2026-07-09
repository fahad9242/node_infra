# Partial backend config, applied via `terraform init -backend-config=backend.hcl`.
# Reusing this Terraform stack in another repo/project? Copy this file and
# change only `key` to a different path — same bucket, different state file,
# so it can never collide with this stack's state.
bucket       = "npl-terraform-infra"
key          = "staging/terraform.tfstate"
region       = "us-west-2"
use_lockfile = true
encrypt      = true
