# Basic Example Outputs

output "budget_id" {
  description = "The ID of the monthly budget"
  value       = module.finops_basic.budget_ids["monthly-budget"]
}

output "budget_arn" {
  description = "The ARN of the monthly budget"
  value       = module.finops_basic.budget_arns["monthly-budget"]
}

output "account_id" {
  description = "The AWS Account ID"
  value       = module.finops_basic.account_id
} 