# Wheelchair — Staging Infrastructure (Terraform)

Modular Terraform for the **staging** environment.
Region `us-west-2` · Account `675475398281`.

This stack **creates** ECR, IAM, S3, security groups, an ALB, and an ECS/Fargate
service. It **references** the pre-existing network (VPC, subnets, IGW, NAT, S3
endpoint, route tables) via `data` sources filtered by `Name` tag — it never
creates or modifies networking.

## Discovered existing infrastructure

Confirmed live via AWS CLI at build time (route tables cross-checked — public/private
verified by IGW-vs-NAT routing, not name alone; all subnets have
`MapPublicIpOnLaunch = false`):

| Resource | ID | Notes |
|---|---|---|
| VPC `vpc_wheelchair_staging` | `vpc-037b06ded517d83bf` | 10.0.0.0/16 |
| public1 (us-west-2a) | `subnet-0030490c0fc3da4bc` | 10.0.0.0/20 → IGW |
| public2 (us-west-2b) | `subnet-0747183bc73b13999` | 10.0.16.0/20 → IGW |
| private1 (us-west-2a) | `subnet-0834297f703a03d8b` | 10.0.128.0/20 → NAT |
| private2 (us-west-2b) | `subnet-09b66ea4a58d0d6c1` | 10.0.144.0/20 → NAT |
| Internet Gateway | `igw-0d61ea118574cf3d9` | |
| NAT Gateway | `nat-0da00f9daef071d05` | |
| S3 gateway endpoint | `vpce-0384dcd75700ac82a` | on both private route tables |

IDs above are **for reference only** — the code selects these resources by
`Name` tag so it stays portable.

> **Profile note:** credentials for account `675475398281` are available on this
> machine through the `default` SSO profile; a profile literally named `NPL` is
> not configured. `aws_profile` defaults to `default` — set it to `NPL` in
> `terraform.tfvars` once that profile exists.

## Module graph

```
                     data sources (existing VPC + subnets, by Name tag)
                                       │
  ┌──────────┐   ┌──────────┐          │
  │  ecr     │   │   s3     │          │
  └────┬─────┘   └────┬─────┘          │
       │ repo arn/url  │ bucket arn    │
       └──────┬────────┘               │
              ▼                        │
          ┌───────┐                    │
          │  iam  │  (exec + task roles, scoped to ecr/s3)
          └───┬───┘                    │
              │ role arns              │
  ┌───────────┴───┐    ┌───────────────┴───┐
  │   security    │───▶│        alb        │  (public subnets, alb_sg)
  │ alb_sg/ecs_sg │    │  tg (ip) + :80    │
  └───────┬───────┘    └─────────┬─────────┘
          │ ecs_sg               │ target group arn
          └──────────┬───────────┘
                     ▼
                 ┌───────┐
                 │  ecs  │  cluster + task def + service (private subnets)
                 └───────┘  depends_on = [module.alb]
```

- **security** owns *both* SGs so the `ecs_sg → alb_sg` reference resolves inside
  one module — no cross-module cycle.
- **ecs** takes an explicit `depends_on = [module.alb]` so the service is created
  only after the HTTP listener exists.
- **container image** defaults to `${ecr.repository_url}:latest` unless
  `container_image` is set.

## File layout

```
versions.tf      terraform + provider pins, commented S3 backend
providers.tf     region + profile, default_tags
data.tf          existing VPC/subnet lookups (by Name tag)
main.tf          module wiring
variables.tf     all inputs
terraform.tfvars staging values
outputs.tf       exposed outputs
modules/
  ecr/  iam/  s3/  security/  alb/  ecs/
```

## Apply order

Terraform resolves ordering automatically from references; the effective order is:

1. `data` lookups (existing VPC + subnets)
2. `ecr`, `s3` (independent, parallel)
3. `iam` (needs ecr + s3 ARNs)
4. `security` (needs VPC id)
5. `alb` (needs public subnets + alb_sg)
6. `ecs` (needs iam roles, ecs_sg, target group; waits on the whole alb module)

## Usage

```bash
terraform init
terraform plan   -out=staging.tfplan
terraform apply  staging.tfplan   # not run here — review the plan first
```

To enable remote state, uncomment the `backend "s3"` block in `versions.tf`
(after creating the bucket + lock table) and run `terraform init -migrate-state`.

## Outputs

`alb_dns_name` · `ecr_repository_url` · `ecs_cluster_name` · `ecs_service_name`
· `s3_bucket_name` · `target_group_arn`

## Post-apply notes

- The HTTPS:443 listener is stubbed (commented) in `modules/alb/main.tf`. Provide
  `acm_certificate_arn` and uncomment to enable TLS.
- Push an image to the ECR repo before the service can pull `:latest`, or point
  `container_image` at an existing image.
```
# npl-terraform-infra
