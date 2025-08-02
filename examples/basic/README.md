# Basic AWS Budget Example

This example demonstrates how to create a simple monthly cost budget with email notifications using the AWS FinOps module.

## Usage

```hcl
module "basic_budget" {
  source = "../../"

  name_prefix = "basic-"
  environment = "dev"

  budgets = {
    monthly_cost = {
      name              = "monthly-cost-budget"
      budget_type       = "COST"
      limit_amount      = 1000
      limit_unit        = "USD"
      time_period_start = "2025-01-01_00:00"
      time_unit         = "MONTHLY"
      
      notifications = [{
        comparison_operator        = "GREATER_THAN"
        threshold                  = 80
        threshold_type            = "PERCENTAGE"
        notification_type         = "ACTUAL"
        subscriber_email_addresses = ["user@example.com"]
      }]
    }
  }

  tags = {
    Environment = "dev"
    Project     = "cost-management"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.13.0 |
| aws | ~> 6.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.2.0 |

## Resources Created

- AWS Budget with monthly cost tracking
- Email notifications at 80% threshold
