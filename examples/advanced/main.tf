# Advanced AWS Budgets and Cost Usage Reports Example
# This example demonstrates budget actions, cost filters, and detailed cost reporting

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Generate unique bucket suffix
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

module "finops_advanced" {
  source = "../../"

  name_prefix = "advanced-example-"
  environment = "production"
  create_iam_role = true
  create_cost_usage_report = true
  create_s3_bucket = true

  tags = {
    Environment = "production"
    Project     = "cost-management"
    Owner       = "finops-team"
    Example     = "advanced"
  }

  budgets = {
    production-budget = {
      name              = "Production Environment Budget"
      budget_type       = "COST"
      limit_amount      = 5000
      limit_unit        = "USD"
      time_period_start = "2024-01-01_00:00"
      time_unit         = "MONTHLY"
      cost_filters = {
        "TagKeyValue" = ["Environment$production"]
      }
      cost_types = {
        include_credit             = true
        include_discount           = true
        include_other_subscription = true
        include_recurring          = true
        include_refund             = true
        include_subscription       = true
        include_support            = true
        include_tax                = true
        include_upfront            = true
        use_amortized              = false
        use_blended                = false
      }
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 80
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_email_addresses = ["finops@example.com"]
        },
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 90
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_email_addresses = ["alerts@example.com"]
        }
      ]
    }
    
    development-budget = {
      name              = "Development Environment Budget"
      budget_type       = "COST"
      limit_amount      = 1000
      limit_unit        = "USD"
      time_period_start = "2024-01-01_00:00"
      time_unit         = "MONTHLY"
      cost_filters = {
        "TagKeyValue" = ["Environment$development"]
      }
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 90
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_email_addresses = ["dev-team@example.com"]
        }
      ]
    }
  }

  budget_actions = {
    production-readonly = {
      budget_key             = "production-budget"
      action_type            = "APPLY_IAM_POLICY"
      notification_type      = "ACTUAL"
      action_threshold_value = 95
      action_threshold_type  = "PERCENTAGE"
      policy_arn             = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      role_arn               = module.finops_advanced.iam_role_arn
      execution_role_arn     = module.finops_advanced.iam_role_arn
      approval_model         = "AUTOMATIC"
      subscribers = [
        {
          address           = "finops@example.com"
          subscription_type = "EMAIL"
        }
      ]
    }
  }

  cost_usage_report = {
    name                    = "detailed-cost-report"
    time_unit              = "HOURLY"
    format                  = "Parquet"
    compression             = "Parquet"
    additional_schema_elements = ["RESOURCES"]
    s3_bucket              = "example-cost-reports-${random_string.bucket_suffix.result}"
    s3_region              = "us-east-1"
    additional_artifacts   = ["ATHENA"]
    report_versioning      = "OVERWRITE_REPORT"
    refresh_closed_reports = true
    report_frequency       = "DAILY"
  }

  s3_bucket_force_destroy = true
} 