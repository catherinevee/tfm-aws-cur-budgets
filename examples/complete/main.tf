provider "aws" {
  region = "us-west-1"
}

module "complete_finops" {
  source = "../../"

  name_prefix = "complete-"
  environment = "prod"

  # AWS Budgets
  budgets = {
    monthly_cost = {
      name              = "monthly-cost-budget"
      budget_type       = "COST"
      limit_amount      = 5000
      limit_unit        = "USD"
      time_period_start = "2025-01-01_00:00"
      time_unit         = "MONTHLY"
      
      cost_filters = {
        Service = ["Amazon Elastic Compute Cloud - Compute"]
      }
      
      cost_types = {
        include_credit             = true
        include_discount          = true
        include_other_subscription = true
        include_recurring         = true
        include_refund            = true
        include_subscription      = true
        include_support           = true
        include_tax              = true
        include_upfront          = true
        use_amortized            = false
        use_blended              = false
      }
      
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 80
          threshold_type            = "PERCENTAGE"
          notification_type         = "ACTUAL"
          subscriber_email_addresses = ["admin@example.com"]
          subscriber_sns_topic_arns  = ["arn:aws:sns:us-west-1:123456789012:budget-alerts"]
        }
      ]
    }
  }

  # Budget Actions
  create_iam_role = true
  budget_actions = {
    stop_dev_instances = {
      budget_key             = "monthly_cost"
      action_type            = "APPLY_IAM_POLICY"
      notification_type      = "ACTUAL"
      action_threshold_value = 90
      action_threshold_type  = "PERCENTAGE"
      policy_arn            = "arn:aws:iam::aws:policy/AWSBudgetActionsWithAWSResourceControlAccess"
      role_arn             = "arn:aws:iam::123456789012:role/budget-action-role"
      execution_role_arn    = "arn:aws:iam::123456789012:role/budget-action-execution-role"
      approval_model        = "AUTOMATIC"
      
      subscribers = [
        {
          address           = "admin@example.com"
          subscription_type = "EMAIL"
        }
      ]
    }
  }

  # Cost Usage Report
  create_cost_usage_report = true
  create_s3_bucket        = true
  
  cost_usage_report = {
    name                     = "detailed-cost-report"
    time_unit               = "HOURLY"
    format                  = "Parquet"
    compression             = "Parquet"
    additional_schema_elements = ["RESOURCES"]
    s3_bucket               = "my-detailed-cost-reports"
    s3_region               = "us-west-1"
    additional_artifacts    = ["ATHENA"]
    report_versioning       = "OVERWRITE_REPORT"
    refresh_closed_reports  = true
    report_frequency        = "DAILY"
  }

  s3_bucket_force_destroy = true

  tags = {
    Environment = "prod"
    Project     = "cost-management"
    Owner       = "finops-team"
  }
}
