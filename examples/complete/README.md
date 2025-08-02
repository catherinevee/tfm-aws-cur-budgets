# Complete AWS FinOps Example

This example demonstrates a complete setup of AWS FinOps tools including budgets, budget actions, and cost usage reports.

## Usage

See the `main.tf` file for the complete configuration.

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
- Budget actions for automated cost control
- Cost Usage Report with Athena integration
- S3 bucket for report storage
- IAM roles and policies for budget actions
- Email and SNS notifications

## Notes

- Replace the example SNS topic ARN with your actual ARN
- Update email addresses to valid recipients
- Adjust IAM role ARNs to match your AWS account ID
