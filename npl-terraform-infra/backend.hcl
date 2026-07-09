# Partial backend config, applied via `terraform init -backend-config=backend.hcl`.
# These are the constants of the state STORAGE mechanism, shared across every
# repo/project that keeps its state in this bucket. The state file PATH
# (`key`) is intentionally not here — it's passed separately as a single
# variable (TF_STATE_KEY in deploy.yml) so reusing this stack elsewhere never
# touches this file, just that one line.
bucket       = "npl-terraform-infra"
region       = "us-west-2"
use_lockfile = true
encrypt      = true
