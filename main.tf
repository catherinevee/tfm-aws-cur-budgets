# AWS Budgets and Cost Usage Reports Module
# This module creates AWS Budgets and Cost Usage Reports for cost management and monitoring

# Data sources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# AWS Budgets
resource "aws_budgets_budget" "this" {
  for_each = var.budgets

  name              = each.value.name
  budget_type       = each.value.budget_type
  limit_amount      = each.value.limit_amount
  limit_unit        = each.value.limit_unit
  time_period_start = each.value.time_period_start
  time_period_end   = each.value.time_period_end
  time_unit         = each.value.time_unit

  dynamic "cost_filters" {
    for_each = each.value.cost_filters != null ? each.value.cost_filters : {}
    content {
      name   = cost_filters.key
      values = cost_filters.value
    }
  }

  dynamic "cost_types" {
    for_each = each.value.cost_types != null ? [each.value.cost_types] : []
    content {
      include_credit             = cost_types.value.include_credit
      include_discount           = cost_types.value.include_discount
      include_other_subscription = cost_types.value.include_other_subscription
      include_recurring          = cost_types.value.include_recurring
      include_refund             = cost_types.value.include_refund
      include_subscription       = cost_types.value.include_subscription
      include_support            = cost_types.value.include_support
      include_tax                = cost_types.value.include_tax
      include_upfront            = cost_types.value.include_upfront
      use_amortized              = cost_types.value.use_amortized
      use_blended                = cost_types.value.use_blended
    }
  }

  dynamic "notification" {
    for_each = each.value.notifications != null ? each.value.notifications : []
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                  = notification.value.threshold
      threshold_type             = notification.value.threshold_type
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses
      subscriber_sns_topic_arns  = notification.value.subscriber_sns_topic_arns
    }
  }

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# AWS Budgets Action
resource "aws_budgets_budget_action" "this" {
  for_each = var.budget_actions

  budget_name        = aws_budgets_budget.this[each.value.budget_key].name
  action_type        = each.value.action_type
  notification_type  = each.value.notification_type
  action_threshold {
    action_threshold_value = each.value.action_threshold_value
    action_threshold_type  = each.value.action_threshold_type
  }

  definition {
    iam_action_definition {
      policy_arn = each.value.policy_arn
      role_arn   = each.value.role_arn
    }
  }

  execution_role_arn = each.value.execution_role_arn

  approval_model = each.value.approval_model

  dynamic "subscriber" {
    for_each = each.value.subscribers != null ? each.value.subscribers : []
    content {
      address           = subscriber.value.address
      subscription_type = subscriber.value.subscription_type
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${each.value.budget_key}-action"
    }
  )
}

# Cost Usage Report
resource "aws_cur_report_definition" "this" {
  count = var.create_cost_usage_report ? 1 : 0

  report_name                = var.cost_usage_report.name
  time_unit                  = var.cost_usage_report.time_unit
  format                     = var.cost_usage_report.format
  compression                = var.cost_usage_report.compression
  additional_schema_elements = var.cost_usage_report.additional_schema_elements
  s3_bucket                  = var.cost_usage_report.s3_bucket
  s3_region                  = var.cost_usage_report.s3_region
  additional_artifacts       = var.cost_usage_report.additional_artifacts
  report_versioning          = var.cost_usage_report.report_versioning
  refresh_closed_reports     = var.cost_usage_report.refresh_closed_reports
  report_frequency           = var.cost_usage_report.report_frequency

  dynamic "report_frequency" {
    for_each = var.cost_usage_report.report_frequency == "DAILY" ? [1] : []
    content {
      # Daily reports don't need additional configuration
    }
  }

  dynamic "report_frequency" {
    for_each = var.cost_usage_report.report_frequency == "MONTHLY" ? [1] : []
    content {
      # Monthly reports don't need additional configuration
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.cost_usage_report.name
    }
  )
}

# S3 Bucket for Cost Usage Report (if create_s3_bucket is true)
resource "aws_s3_bucket" "cur_bucket" {
  count = var.create_cost_usage_report && var.create_s3_bucket ? 1 : 0

  bucket        = var.cost_usage_report.s3_bucket
  force_destroy = var.s3_bucket_force_destroy

  tags = merge(
    var.tags,
    {
      Name = "${var.cost_usage_report.s3_bucket}-cur"
    }
  )
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "cur_bucket" {
  count = var.create_cost_usage_report && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cur_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cur_bucket" {
  count = var.create_cost_usage_report && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cur_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms_encryption ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms_encryption ? var.kms_key_arn : null
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "cur_bucket" {
  count = var.create_cost_usage_report && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cur_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for Cost Usage Report
resource "aws_s3_bucket_policy" "cur_bucket" {
  count = var.create_cost_usage_report && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cur_bucket[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSBillingDelivery"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.cur_bucket[0].arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          StringLike = {
            "aws:SourceArn" = "arn:aws:cur:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:definition/*"
          }
        }
      }
    ]
  })
}

# IAM Role for Budget Actions (if create_iam_role is true)
resource "aws_iam_role" "budget_action" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name_prefix}budget-action-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}budget-action-role"
    }
  )
}

# IAM Policy for Budget Actions
resource "aws_iam_role_policy" "budget_action" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name_prefix}budget-action-policy"
  role = aws_iam_role.budget_action[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "rds:StopDBInstance",
          "rds:StopDBCluster",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:SetDesiredCapacity"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = var.environment
          }
        }
      }
    ]
  })
} 