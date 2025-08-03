# Organization-Level AWS Budgets Example

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "finops_org" {
  source = "../.."

  name_prefix = "org-${var.environment}-"
  environment = var.environment
  
  create_iam_role = true

  # Organization-wide budget
  budgets = {
    org-total-budget = {
      name              = "Organization Total Budget"
      budget_type       = "COST"
      limit_amount      = var.total_budget_limit
      limit_unit        = "USD"
      time_period_start = "2025-01-01_00:00"
      time_unit         = "MONTHLY"
      
      cost_types = {
        include_credit        = true
        include_discount     = true
        include_recurring    = true
        include_refund      = false
        include_subscription = true
        include_support     = true
        include_tax        = true
        include_upfront    = true
        use_amortized     = true
        use_blended      = false
      }
      
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 80
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_sns_topic_arns  = [aws_sns_topic.org_budget_alerts.arn]
        },
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 90
          threshold_type             = "PERCENTAGE"
          notification_type          = "FORECASTED"
          subscriber_sns_topic_arns  = [aws_sns_topic.org_budget_alerts.arn]
        }
      ]
    }
  }

  # Budget actions
  budget_actions = {
    org-readonly = {
      budget_key             = "org-total-budget"
      action_type            = "APPLY_IAM_POLICY"
      notification_type      = "ACTUAL"
      action_threshold_value = 95
      action_threshold_type  = "PERCENTAGE"
      policy_arn             = aws_iam_policy.org_readonly.arn
      role_arn               = module.finops_org.iam_role_arn
      execution_role_arn     = module.finops_org.iam_role_arn
      approval_model         = "MANUAL"
    }
  }

  tags = {
    Environment = var.environment
    Project     = "organization-cost-management"
    CostCenter  = "central-finance"
  }
}

# SNS Topic for organization budget alerts
resource "aws_sns_topic" "org_budget_alerts" {
  name = "org-budget-alerts-${var.environment}"
  
  tags = {
    Name        = "org-budget-alerts"
    Environment = var.environment
  }
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "org_budget_alerts" {
  arn = aws_sns_topic.org_budget_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBudgetPublish"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.org_budget_alerts.arn
      }
    ]
  })
}

# IAM Policy for organization-wide read-only access
resource "aws_iam_policy" "org_readonly" {
  name        = "organization-readonly-${var.environment}"
  description = "Organization-wide read-only access when budget threshold is reached"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "organizations:Describe*",
          "organizations:List*",
          "ec2:Describe*",
          "rds:Describe*",
          "s3:List*",
          "s3:GetBucket*"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "organizations:Create*",
          "organizations:Delete*",
          "organizations:Update*",
          "organizations:Move*",
          "organizations:Remove*",
          "organizations:Tag*",
          "organizations:Untag*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda function to process budget notifications
resource "aws_lambda_function" "budget_notification_processor" {
  filename      = "${path.module}/lambda/budget_notification_processor.zip"
  function_name = "budget-notification-processor-${var.environment}"
  role         = aws_iam_role.lambda_role.arn
  handler      = "index.handler"
  runtime      = "nodejs16.x"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      ENVIRONMENT      = var.environment
    }
  }

  tags = {
    Name        = "budget-notification-processor"
    Environment = var.environment
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "budget-notification-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/budget-notification-processor-${var.environment}"
  retention_in_days = 14
}

# Lambda SNS subscription
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.org_budget_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.budget_notification_processor.arn
}

# Lambda permission for SNS
resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.budget_notification_processor.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.org_budget_alerts.arn
}

# Outputs
output "org_budget_id" {
  description = "The ID of the organization budget"
  value       = module.finops_org.budget_ids["org-total-budget"]
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for budget alerts"
  value       = aws_sns_topic.org_budget_alerts.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function processing budget notifications"
  value       = aws_lambda_function.budget_notification_processor.function_name
}
