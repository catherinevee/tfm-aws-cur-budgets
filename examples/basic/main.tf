# Basic AWS Budgets Example
# This example demonstrates a simple monthly cost budget with email notifications

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "finops_basic" {
  source = "../../"

  name_prefix = "basic-example-"
  environment = "dev"
  
  tags = {
    Environment = "dev"
    Project     = "cost-management"
    Owner       = "finops-team"
    Example     = "basic"
  }

  budgets = {
    monthly-budget = {
      name              = "Monthly Cost Budget"
      budget_type       = "COST"
      limit_amount      = 1000
      limit_unit        = "USD"
      time_period_start = "2024-01-01_00:00"
      time_unit         = "MONTHLY"
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
          threshold                  = 100
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_email_addresses = ["alerts@example.com"]
        }
      ]
    }
  }
} 