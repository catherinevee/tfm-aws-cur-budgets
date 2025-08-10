# Advanced AWS Budgets Example with KMS Encryption
# This example demonstrates advanced features including KMS encryption, budget actions, and comprehensive monitoring

terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create KMS key for encryption (optional - you can use existing key)
resource "aws_kms_key" "finops" {
  description             = "KMS key for FinOps module encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = "production"
    Project     = "cost-management"
    Owner       = "finops-team"
  }
}

resource "aws_kms_alias" "finops" {
  name          = "alias/finops-encryption"
  target_key_id = aws_kms_key.finops.key_id
}

# Create SNS topic for budget notifications
resource "aws_sns_topic" "budget_alerts" {
  name = "budget-alerts"
  
  tags = {
    Environment = "production"
    Project     = "cost-management"
  }
}

# Create IAM policy for budget actions
resource "aws_iam_policy" "budget_action_policy" {
  name        = "budget-action-policy"
  description = "Policy for budget actions to stop/terminate resources"

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
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = "dev"
          }
        }
      }
    ]
  })
}

module "finops_advanced" {
  source = "../../"

  name_prefix = "advanced-example-"
  environment = "prod"
  
  tags = {
    Environment = "production"
    Project     = "cost-management"
    Owner       = "finops-team"
    Example     = "advanced"
    Security    = "high"
  }

  budgets = {
    monthly-budget = {
      name              = "Monthly Cost Budget"
      budget_type       = "COST"
      limit_amount      = 5000
      limit_unit        = "USD"
      time_period_start = "2024-01-01_00:00"
      time_unit         = "MONTHLY"
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 80
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
        },
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 100
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
        }
      ]
    }
    
    quarterly-budget = {
      name              = "Quarterly Cost Budget"
      budget_type       = "COST"
      limit_amount      = 15000
      limit_unit        = "USD"
      time_period_start = "2024-01-01_00:00"
      time_unit         = "QUARTERLY"
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 90
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
        }
      ]
    }
  }

  budget_actions = {
    stop-dev-resources = {
      budget_key              = "monthly-budget"
      action_type             = "APPLY_IAM_POLICY"
      notification_type       = "ACTUAL"
      action_threshold_value  = 100
      action_threshold_type   = "PERCENTAGE"
      policy_arn              = aws_iam_policy.budget_action_policy.arn
      role_arn                = aws_iam_policy.budget_action_policy.arn
      execution_role_arn      = aws_iam_policy.budget_action_policy.arn
      approval_model          = "MANUAL"
      subscribers = [
        {
          address           = aws_sns_topic.budget_alerts.arn
          subscription_type = "SNS"
        }
      ]
    }
  }

  create_cost_usage_report = true
  create_s3_bucket        = true
  create_iam_role         = true
  
  enable_kms_encryption   = true
  kms_key_arn            = aws_kms_key.finops.arn
}

# Outputs for the advanced example
output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.finops.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for budget alerts"
  value       = aws_sns_topic.budget_alerts.arn
}

output "budget_action_policy_arn" {
  description = "ARN of the budget action policy"
  value       = aws_iam_policy.budget_action_policy.arn
} 