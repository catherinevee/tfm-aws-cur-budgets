# Advanced Example Outputs

output "production_budget_id" {
  description = "The ID of the production budget"
  value       = module.finops_advanced.budget_ids["production-budget"]
}

output "development_budget_id" {
  description = "The ID of the development budget"
  value       = module.finops_advanced.budget_ids["development-budget"]
}

output "budget_action_id" {
  description = "The ID of the budget action"
  value       = module.finops_advanced.budget_action_ids["production-readonly"]
}

output "cost_usage_report_id" {
  description = "The ID of the Cost Usage Report"
  value       = module.finops_advanced.cost_usage_report_id
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket for Cost Usage Reports"
  value       = module.finops_advanced.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for Cost Usage Reports"
  value       = module.finops_advanced.s3_bucket_arn
}

output "iam_role_arn" {
  description = "The ARN of the IAM role for budget actions"
  value       = module.finops_advanced.iam_role_arn
}

output "account_id" {
  description = "The AWS Account ID"
  value       = module.finops_advanced.account_id
} 