# Variables for organization-level budgeting example

variable "environment" {
  description = "Environment name for tagging and resource naming"
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "total_budget_limit" {
  description = "Total monthly budget limit for the organization in USD"
  type        = number
  default     = 10000
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for budget notifications"
  type        = string
  sensitive   = true
}

variable "notification_email" {
  description = "Email address for budget notifications"
  type        = string
  default     = "finance-team@example.com"
}

variable "enable_lambda_notifications" {
  description = "Enable Lambda function for processing budget notifications"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda function logs"
  type        = number
  default     = 14
}
