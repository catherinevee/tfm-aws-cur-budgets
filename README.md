# AWS Budgets and Cost Usage Reports Terraform Module

This Terraform module provides a comprehensive solution for managing AWS Budgets and Cost Usage Reports (CUR) for cost management and monitoring. It follows AWS best practices and includes features for budget notifications, automated actions, and detailed cost reporting.

## Features

- **AWS Budgets**: Create and manage cost and usage budgets
- **Budget Actions**: Automate responses to budget threshold breaches
- **Cost Usage Reports**: Generate detailed cost and usage reports
- **S3 Integration**: Secure storage for cost reports with proper IAM policies
- **IAM Roles**: Pre-configured roles for budget actions
- **Tagging**: Comprehensive resource tagging for cost allocation
- **Security**: Encryption, versioning, and access controls

## Usage

### Basic Budget Configuration

```hcl
module "finops" {
  source = "./finops"

  name_prefix = "my-company-"
  environment = "production"
  
  tags = {
    Environment = "production"
    Project     = "cost-management"
    Owner       = "finops-team"
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
          subscriber_email_addresses = ["finops@company.com"]
        }
      ]
    }
  }
}
```

### Advanced Budget with Actions

```hcl
module "finops" {
  source = "./finops"

  name_prefix = "my-company-"
  environment = "production"
  create_iam_role = true

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
      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 90
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_email_addresses = ["alerts@company.com"]
        }
      ]
    }
  }

  budget_actions = {
    stop-non-critical = {
      budget_key             = "production-budget"
      action_type            = "APPLY_IAM_POLICY"
      notification_type      = "ACTUAL"
      action_threshold_value = 95
      action_threshold_type  = "PERCENTAGE"
      policy_arn             = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      role_arn               = module.finops.iam_role_arn
      execution_role_arn     = module.finops.iam_role_arn
      approval_model         = "AUTOMATIC"
    }
  }
}
```

### Cost Usage Report Configuration

```hcl
module "finops" {
  source = "./finops"

  name_prefix = "my-company-"
  environment = "production"
  
  create_cost_usage_report = true
  create_s3_bucket        = true

  cost_usage_report = {
    name                    = "detailed-cost-report"
    time_unit              = "HOURLY"
    format                  = "Parquet"
    compression             = "Parquet"
    additional_schema_elements = ["RESOURCES"]
    s3_bucket              = "my-company-cost-reports-${random_string.bucket_suffix.result}"
    s3_region              = "us-east-1"
    additional_artifacts   = ["ATHENA"]
    report_versioning      = "OVERWRITE_REPORT"
    refresh_closed_reports = true
    report_frequency       = "DAILY"
  }

  tags = {
    Environment = "production"
    Project     = "cost-management"
    Owner       = "finops-team"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix to be used for resource names | `string` | `"finops-"` | no |
| environment | Environment name for tagging and conditional logic | `string` | `"dev"` | no |
| tags | A map of tags to assign to all resources | `map(string)` | `{}` | no |
| budgets | Map of AWS Budgets to create | `map(object)` | `{}` | no |
| budget_actions | Map of AWS Budget Actions to create | `map(object)` | `{}` | no |
| create_cost_usage_report | Whether to create a Cost Usage Report | `bool` | `false` | no |
| cost_usage_report | Configuration for Cost Usage Report | `object` | See variables.tf | no |
| create_s3_bucket | Whether to create an S3 bucket for Cost Usage Reports | `bool` | `false` | no |
| s3_bucket_force_destroy | Whether to force destroy the S3 bucket | `bool` | `false` | no |
| create_iam_role | Whether to create an IAM role for budget actions | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| budget_ids | Map of budget names to budget IDs |
| budget_arns | Map of budget names to budget ARNs |
| budget_action_ids | Map of budget action names to action IDs |
| budget_action_arns | Map of budget action names to action ARNs |
| cost_usage_report_id | The ID of the Cost Usage Report |
| cost_usage_report_arn | The ARN of the Cost Usage Report |
| s3_bucket_id | The ID of the S3 bucket for Cost Usage Reports |
| s3_bucket_arn | The ARN of the S3 bucket for Cost Usage Reports |
| s3_bucket_domain_name | The domain name of the S3 bucket for Cost Usage Reports |
| iam_role_id | The ID of the IAM role for budget actions |
| iam_role_arn | The ARN of the IAM role for budget actions |
| iam_role_name | The name of the IAM role for budget actions |
| account_id | The AWS Account ID |
| region | The AWS Region |

## Examples

### Basic Budget
- Simple monthly cost budget with email notifications
- Suitable for small to medium organizations

### Advanced Budget with Actions
- Production environment budget with automated actions
- Includes IAM role creation and budget actions
- Suitable for production environments requiring automated cost control

### Cost Usage Report
- Detailed cost reporting with S3 storage
- Includes Athena integration for querying
- Suitable for organizations requiring detailed cost analysis

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Security Considerations

1. **S3 Bucket Security**: The module creates S3 buckets with encryption, versioning, and public access blocking enabled
2. **IAM Roles**: IAM roles are created with least privilege principles
3. **Budget Actions**: Actions are configured with proper approval models and conditions
4. **Cost Filters**: Use cost filters to scope budgets to specific resources or tags

## Best Practices

1. **Tagging**: Always use consistent tagging for cost allocation and resource management
2. **Budget Thresholds**: Set realistic thresholds (80-90%) for notifications to allow time for action
3. **Cost Filters**: Use cost filters to create targeted budgets for different environments or projects
4. **Monitoring**: Regularly review budget performance and adjust thresholds as needed
5. **Documentation**: Document budget purposes and action plans for threshold breaches

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See LICENSE file for details.

## References

- [AWS Budgets Documentation](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/budgets-managing-costs.html)
- [AWS Cost and Usage Reports](https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)