# Shared assume-role policy: only the ECS tasks service may assume these roles.
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------
# Task EXECUTION role — used by the ECS agent to pull images and ship logs.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "task_execution" {
  name               = "${var.name_prefix}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

# Baseline AWS-managed policy (ECR pull + CW Logs write for the standard flow).
resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Least-privilege inline policy: explicit ECR pull scoped to this repo, plus
# CloudWatch Logs for this app's log-group namespace only.
data "aws_iam_policy_document" "task_execution_inline" {
  statement {
    sid       = "EcrAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"] # GetAuthorizationToken cannot be resource-scoped.
  }

  statement {
    sid    = "EcrPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [var.ecr_repository_arn]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:/ecs/${var.name_prefix}*",
    ]
  }
}

resource "aws_iam_role_policy" "task_execution_inline" {
  name   = "${var.name_prefix}-ecs-task-execution-inline"
  role   = aws_iam_role.task_execution.id
  policy = data.aws_iam_policy_document.task_execution_inline.json
}

# ---------------------------------------------------------------------------
# Task ROLE — assumed by the application container itself. Scoped S3 access
# to the single app bucket only.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

data "aws_iam_policy_document" "task_s3" {
  statement {
    sid       = "ListAppBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.s3_bucket_arn]
  }

  statement {
    sid    = "ReadWriteAppObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${var.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "task_s3" {
  name   = "${var.name_prefix}-ecs-task-s3"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_s3.json
}
