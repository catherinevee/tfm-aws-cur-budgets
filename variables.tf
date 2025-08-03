# AWS Budgets and Cost Usage Reports Module Variables

variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
  default     = "finops-"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]*$", var.name_prefix))
    error_message = "Name prefix can only contain alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name for tagging and conditional logic"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# Budgets Configuration
variable "budgets" {
  description = "Map of AWS Budgets to create"
  type = map(object({
    name              = string
    budget_type       = string
    limit_amount      = number
    limit_unit        = string
    time_period_start = string
    time_period_end   = optional(string)
    time_unit         = string
    cost_filters      = optional(map(list(string)))
    cost_types = optional(object({
      include_credit             = optional(bool, true)
      include_discount           = optional(bool, true)
      include_other_subscription = optional(bool, true)
      include_recurring          = optional(bool, true)
      include_refund             = optional(bool, true)
      include_subscription       = optional(bool, true)
      include_support            = optional(bool, true)
      include_tax                = optional(bool, true)
      include_upfront            = optional(bool, true)
      use_amortized              = optional(bool, false)
      use_blended                = optional(bool, false)
    }))
    notifications = optional(list(object({
      comparison_operator        = string
      threshold                  = number
      threshold_type             = string
      notification_type          = string
      subscriber_email_addresses = optional(list(string))
      subscriber_sns_topic_arns  = optional(list(string))
    })))
  }))
  default = {}
}

# Budget Actions Configuration
variable "budget_actions" {
  description = "Map of AWS Budget Actions to create"
  type = map(object({
    budget_key              = string
    action_type             = string
    notification_type       = string
    action_threshold_value  = number
    action_threshold_type   = string
    policy_arn              = string
    role_arn                = string
    execution_role_arn      = string
    approval_model          = string
    subscribers = optional(list(object({
      address           = string
      subscription_type = string
    })))
  }))
  default = {}
}

# Cost Usage Report Configuration
variable "create_cost_usage_report" {
  description = "Whether to create a Cost Usage Report"
  type        = bool
  default     = false
}

variable "cost_usage_report" {
  description = "Configuration for Cost Usage Report"
  type = object({
    name                    = string
    time_unit              = string
    format                  = string
    compression             = string
    additional_schema_elements = list(string)
    s3_bucket              = string
    s3_region              = string
    additional_artifacts   = list(string)
    report_versioning      = string
    refresh_closed_reports = bool
    report_frequency       = string
  })
  default = {
    name                    = "cost-usage-report"
    time_unit              = "HOURLY"
    format                  = "Parquet"
    compression             = "Parquet"
    additional_schema_elements = ["RESOURCES"]
    s3_bucket              = "my-cost-usage-reports"
    s3_region              = "us-east-1"
    additional_artifacts   = ["ATHENA"]
    report_versioning      = "OVERWRITE_REPORT"
    refresh_closed_reports = true
    report_frequency       = "DAILY"
  }
}

# S3 Bucket Configuration
variable "create_s3_bucket" {
  description = "Whether to create an S3 bucket for Cost Usage Reports"
  type        = bool
  default     = false
}

variable "s3_bucket_force_destroy" {
  description = "Whether to force destroy the S3 bucket"
  type        = bool
  default     = false
}

variable "existing_s3_bucket_arn" {
  description = "ARN of an existing S3 bucket to use for Cost Usage Reports (if not creating a new one)"
  type        = string
  default     = null
}

# IAM Configuration
variable "create_iam_role" {
  description = "Whether to create an IAM role for budget actions"
  type        = bool
  default     = false
} 