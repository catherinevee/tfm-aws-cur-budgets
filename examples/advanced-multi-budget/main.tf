# Advanced AWS Budget Example with Multiple Budgets and Actions

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "finops_advanced" {
  source = "../.."

  name_prefix = "advanced-example-"
  environment = "production"
  
  create_iam_role = true

  # Production Environment Budget
  budgets = {
    production-budget = {
      name              = "Production Environment Budget"
      budget_type       = "COST"
      limit_amount      = 5000
      limit_unit        = "USD"
      time_period_start = "2025-01-01_00:00"
      time_unit         = "MONTHLY"
      
      cost_filters = {
        "TagKeyValue" = ["Environment$production"]
      }
      
      cost_types = {
        include_credit             = true
        include_discount          = true
        include_recurring        = true
        include_refund           = false
        include_subscription     = true
        include_support         = true
        include_tax            = true
        include_upfront        = true
        use_amortized         = false
        use_blended          = false
      }
      
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 80
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_email_addresses = ["alerts@example.com"]
        },
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 90
          threshold_type             = "PERCENTAGE"
          notification_type          = "FORECASTED"
          subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
        }
      ]
    },
    
    # Development Environment Budget
    development-budget = {
      name              = "Development Environment Budget"
      budget_type       = "COST"
      limit_amount      = 1000
      limit_unit        = "USD"
      time_period_start = "2025-01-01_00:00"
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
          subscriber_email_addresses = ["dev-alerts@example.com"]
        }
      ]
    }
  }

  # Budget Actions
  budget_actions = {
    # Action to apply read-only policy when production budget reaches 95%
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
    },
    
    # Action to stop non-essential resources when development budget reaches 100%
    development-stop = {
      budget_key             = "development-budget"
      action_type            = "APPLY_IAM_POLICY"
      notification_type      = "ACTUAL"
      action_threshold_value = 100
      action_threshold_type  = "PERCENTAGE"
      policy_arn             = aws_iam_policy.stop_resources.arn
      role_arn               = module.finops_advanced.iam_role_arn
      execution_role_arn     = module.finops_advanced.iam_role_arn
      approval_model         = "MANUAL"
    }
  }

  tags = {
    Environment = "production"
    Project     = "cost-management"
    CostCenter  = "finance"
    ManagedBy   = "terraform"
  }
}

# SNS Topic for budget alerts
resource "aws_sns_topic" "budget_alerts" {
  name = "budget-alerts"
  
  tags = {
    Name        = "budget-alerts"
    Environment = "production"
  }
}

# IAM Policy to stop non-essential resources
resource "aws_iam_policy" "stop_resources" {
  name        = "stop-non-essential-resources"
  description = "Policy to stop non-essential resources when budget threshold is reached"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Environment": "development"
            "aws:ResourceTag/Essential": "false"
          }
        }
      }
    ]
  })
}

# Outputs
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

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for budget alerts"
  value       = aws_sns_topic.budget_alerts.arn
}
