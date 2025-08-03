# FinOps Module Examples

This directory contains examples demonstrating various use cases for the AWS Budgets and Cost Usage Reports module.

## Examples

1. **[Basic](./basic)**
   - Simple budget setup with notifications
   - Email alerts for threshold breaches
   - Basic cost monitoring

2. **[Advanced Multi-Budget](./advanced-multi-budget)**
   - Multiple budgets with different thresholds
   - Automated actions on threshold breaches
   - Integration with IAM policies
   - SNS topic notifications
   - Environment-specific budgets (production and development)
   - Advanced cost filters and types

3. **[Cost Analysis](./cost-analysis)**
   - Detailed cost report configuration
   - S3 bucket setup with security controls
   - Athena integration and custom queries
   - CloudWatch dashboard for cost visualization
   - Advanced cost analytics setup
   - Cost data querying and analysis

4. **[Organization Budgets](./organization-budgets)**
   - Organization-wide budget management
   - Advanced notification system with Lambda
   - Slack integration for alerts
   - IAM policy automation
   - Multi-account budget controls
   - Centralized cost management

## Usage

Each example can be run using standard Terraform commands:

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Clean up when done
terraform destroy
```

## Security Features

Each example includes various security features:

- **S3 Bucket Security**
  - Server-side encryption
  - Versioning enabled
  - Public access blocked
  - Access logging
  - Secure transport enforcement

- **IAM Security**
  - Least privilege principle
  - Resource-based policies
  - Service role separation
  - Automated policy management

- **Data Protection**
  - Encryption at rest
  - Encryption in transit
  - Access auditing
  - Retention policies

## Best Practices

The examples follow these best practices:

1. **Budgeting**
   - Multiple threshold notifications
   - Graduated response actions
   - Resource tagging
   - Cost allocation tracking

2. **Cost Analysis**
   - Optimized Athena queries
   - Efficient data formats
   - Automated reporting
   - Custom dashboards

3. **Security**
   - Encryption everywhere
   - Access controls
   - Audit logging
   - Compliance features

## Requirements

| Name | Version |
|------|---------|
| terraform | = 1.13.0 |
| aws | = 6.2.0 |
| azurerm | = 4.38.1 |

## Contributing

Feel free to submit issues, fork the repository and create pull requests for any improvements.
