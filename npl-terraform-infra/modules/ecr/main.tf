resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # Every deploy pushes a new tag (immutable repo), so the repo always has
  # images by the time anyone runs `terraform destroy` — without this,
  # destroy fails with RepositoryNotEmptyException instead of tearing down.
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Lifecycle: keep the last N tagged images, and expire untagged images after
# X days. Rules evaluate in priority order.
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.untagged_expire_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_expire_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the last ${var.keep_last_images} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.keep_last_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
