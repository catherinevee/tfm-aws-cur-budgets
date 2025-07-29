# AWS Budgets and Cost Usage Reports Module Outputs

output "budget_ids" {
  description = "Map of budget names to budget IDs"
  value = {
    for k, v in aws_budgets_budget.this : k => v.id
  }
}

output "budget_arns" {
  description = "Map of budget names to budget ARNs"
  value = {
    for k, v in aws_budgets_budget.this : k => v.arn
  }
}

output "budget_action_ids" {
  description = "Map of budget action names to action IDs"
  value = {
    for k, v in aws_budgets_budget_action.this : k => v.id
  }
}

output "budget_action_arns" {
  description = "Map of budget action names to action ARNs"
  value = {
    for k, v in aws_budgets_budget_action.this : k => v.arn
  }
}

output "cost_usage_report_id" {
  description = "The ID of the Cost Usage Report"
  value       = var.create_cost_usage_report ? aws_cur_report_definition.this[0].id : null
}

output "cost_usage_report_arn" {
  description = "The ARN of the Cost Usage Report"
  value       = var.create_cost_usage_report ? aws_cur_report_definition.this[0].arn : null
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket for Cost Usage Reports"
  value       = var.create_cost_usage_report && var.create_s3_bucket ? aws_s3_bucket.cur_bucket[0].id : null
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for Cost Usage Reports"
  value       = var.create_cost_usage_report && var.create_s3_bucket ? aws_s3_bucket.cur_bucket[0].arn : null
}

output "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket for Cost Usage Reports"
  value       = var.create_cost_usage_report && var.create_s3_bucket ? aws_s3_bucket.cur_bucket[0].bucket_domain_name : null
}

output "iam_role_id" {
  description = "The ID of the IAM role for budget actions"
  value       = var.create_iam_role ? aws_iam_role.budget_action[0].id : null
}

output "iam_role_arn" {
  description = "The ARN of the IAM role for budget actions"
  value       = var.create_iam_role ? aws_iam_role.budget_action[0].arn : null
}

output "iam_role_name" {
  description = "The name of the IAM role for budget actions"
  value       = var.create_iam_role ? aws_iam_role.budget_action[0].name : null
}

output "account_id" {
  description = "The AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "The AWS Region"
  value       = data.aws_region.current.name
} 