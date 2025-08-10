# AWS FinOps Cost Control Sentinel Policy

This Sentinel policy enforces cost controls, budget limits, and financial governance for AWS FinOps infrastructure. It ensures that all FinOps-related resources follow organizational cost management standards and security requirements.

## Policy Overview

### Purpose
- Enforce cost controls and budget limits for FinOps infrastructure
- Ensure proper resource tagging for cost allocation
- Validate budget configurations follow organizational standards
- Enforce encryption requirements for cost data
- Optimize S3 bucket configurations for cost efficiency
- Validate IAM roles follow least privilege principles

### Scope
The policy validates the following AWS resources:
- `aws_budgets_budget` - AWS Budgets
- `aws_budgets_budget_action` - Budget Actions
- `aws_cur_report_definition` - Cost Usage Reports
- `aws_s3_bucket` - S3 buckets for cost reports
- `aws_iam_role` - IAM roles for budget actions
- `aws_iam_role_policy` - IAM policies

### Enforcement Levels
- **Production**: Hard Mandatory
- **Staging**: Soft Mandatory
- **Development**: Advisory

## Policy Parameters

### Core Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `environment` | `"dev"` | Environment name (dev, staging, prod) |
| `max_monthly_cost_increase` | `20.0` | Maximum allowed monthly cost increase percentage |
| `max_absolute_monthly_cost` | `10000.0` | Maximum absolute monthly cost limit |
| `require_cost_tags` | `true` | Whether to require cost allocation tags |
| `require_encryption` | `true` | Whether to require encryption |
| `max_budget_threshold` | `90.0` | Maximum budget notification threshold |

### Environment-Specific Limits
The policy automatically applies different limits based on the environment:

#### Production
- Max Monthly Cost: $50,000
- Max Cost Increase: 15%
- Budget Threshold: 85%

#### Staging
- Max Monthly Cost: $10,000
- Max Cost Increase: 25%
- Budget Threshold: 90%

#### Development
- Max Monthly Cost: $5,000
- Max Cost Increase: 50%
- Budget Threshold: 95%

## Validation Rules

### 1. Cost Increase Validation
- Validates that monthly cost increases are within acceptable thresholds
- Uses Terraform cost estimates when available
- Applies environment-specific percentage limits

### 2. Budget Configuration Validation
- Budget names must start with `cost-budget-`
- Budget amounts must be greater than 0
- Budget thresholds cannot exceed environment-specific limits
- Time units must be MONTHLY, QUARTERLY, or ANNUALLY

### 3. Required Tagging
The following tags are mandatory for all FinOps resources:
- `Environment` - Must match workspace environment
- `Project` - Project identifier
- `Owner` - Resource owner
- `CostCenter` - Cost center code
- `BudgetOwner` - Budget owner

### 4. S3 Cost Optimization
- Requires lifecycle policies for cost optimization
- Recommends intelligent tiering configuration
- Validates versioning with lifecycle management

### 5. Encryption Requirements
- S3 buckets must use server-side encryption (AES256 or KMS)
- Validates encryption algorithm configuration

### 6. IAM Role Validation
- Checks for overly permissive policies
- Validates presence of cost management permissions
- Ensures conditions are applied to wildcard policies

## Usage

### Basic Configuration
```hcl
# sentinel.hcl
policy "aws-finops-cost-control" {
  source = "./cost-control.sentinel"
  enforcement_level = "hard-mandatory"
}
```

### Environment-Specific Configuration
```hcl
# Production environment
policy "aws-finops-cost-control-prod" {
  source = "./cost-control.sentinel"
  enforcement_level = "hard-mandatory"
  
  param "environment" {
    value = "prod"
  }
  
  param "max_monthly_cost_increase" {
    value = 15.0
  }
}

# Development environment
policy "aws-finops-cost-control-dev" {
  source = "./cost-control.sentinel"
  enforcement_level = "advisory"
  
  param "environment" {
    value = "dev"
  }
  
  param "max_monthly_cost_increase" {
    value = 50.0
  }
}
```

### Customizing Cost Limits
```hcl
policy "aws-finops-cost-control-custom" {
  source = "./cost-control.sentinel"
  enforcement_level = "hard-mandatory"
  
  param "max_absolute_monthly_cost" {
    value = 75000.0  # Custom monthly limit
  }
  
  param "max_budget_threshold" {
    value = 80.0  # Custom budget threshold
  }
}
```

## Testing

### Running Tests
```bash
# Run all tests
sentinel test

# Run specific test
sentinel test cost-control-pass-compliant.hcl

# Run with verbose output
sentinel test -verbose
```

### Test Cases
1. **Compliant Resources** (`cost-control-pass-compliant.hcl`)
   - Validates that properly configured resources pass all checks
   
2. **Budget Violations** (`cost-control-fail-budget-violation.hcl`)
   - Tests budget configuration violations
   
3. **Cost Increase Violations** (`cost-control-fail-cost-increase.hcl`)
   - Tests excessive cost increase scenarios

## Deployment

### Terraform Cloud
1. Upload the policy to your Terraform Cloud organization
2. Configure policy sets in the Terraform Cloud UI
3. Assign policies to workspaces based on environment

### Terraform Enterprise
1. Place policies in the appropriate policy directory
2. Configure policy enforcement in the Terraform Enterprise UI
3. Set up policy overrides for different environments

### Local Development
1. Install Sentinel CLI
2. Configure local policy testing
3. Use `sentinel apply` for local validation

## Customization

### Adding New Resource Types
To add validation for new resource types:

1. Update the `finops_resources` filter:
```sentinel
finops_resources = filter tfplan.resource_changes as _, rc {
    rc.mode is "managed" and
    rc.type in [
        "aws_budgets_budget",
        "aws_budgets_budget_action",
        "aws_cur_report_definition",
        "aws_s3_bucket",
        "aws_iam_role",
        "aws_iam_role_policy",
        "aws_new_resource_type"  # Add new resource type
    ] and
    rc.change.actions is not ["delete"]
}
```

2. Add validation function:
```sentinel
validate_new_resource = func(resource) {
    # Add validation logic
    return true
}
```

3. Update main rule:
```sentinel
main = rule {
    # ... existing validations ...
    all new_resources as _, resource {
        validate_new_resource(resource)
    }
}
```

### Customizing Cost Limits
To customize cost limits for your organization:

1. Update the `cost_limits` map:
```sentinel
cost_limits = {
    "prod": {
        "max_monthly": decimal.new(100000.0),  # Custom limit
        "max_increase_percent": 10.0,          # Custom percentage
        "budget_threshold": 80.0               # Custom threshold
    }
    # ... other environments
}
```

### Adding New Tags
To add new required tags:

1. Update `mandatory_cost_tags`:
```sentinel
mandatory_cost_tags = [
    "Environment",
    "Project",
    "Owner",
    "CostCenter",
    "BudgetOwner",
    "NewTag"  # Add new tag
]
```

## Troubleshooting

### Common Issues

#### Policy Fails Due to Missing Tags
**Error**: "Missing required cost tag: CostCenter"
**Solution**: Add the missing tag to your resources:
```hcl
tags = {
  Environment = "prod"
  Project     = "cost-management"
  Owner       = "finops-team"
  CostCenter  = "IT-001"  # Add missing tag
  BudgetOwner = "finance-team"
}
```

#### Budget Threshold Exceeds Limit
**Error**: "Budget threshold cannot exceed 85%"
**Solution**: Reduce the budget threshold:
```hcl
notifications = [
  {
    comparison_operator = "GREATER_THAN"
    threshold          = 80.0  # Reduce from 95% to 80%
    threshold_type     = "PERCENTAGE"
    notification_type  = "ACTUAL"
  }
]
```

#### Cost Increase Exceeds Limit
**Error**: Cost increase exceeds allowed percentage
**Solution**: 
1. Review the planned changes
2. Consider breaking changes into smaller increments
3. Request policy override if necessary

### Policy Overrides
For legitimate cases where policy violations are acceptable:

1. **Terraform Cloud**: Use policy overrides in the UI
2. **Terraform Enterprise**: Configure policy bypass rules
3. **Local**: Use `sentinel apply -policy-override`

## Best Practices

### 1. Gradual Implementation
- Start with advisory enforcement
- Gradually increase enforcement levels
- Monitor policy effectiveness

### 2. Regular Review
- Review cost limits quarterly
- Update thresholds based on business needs
- Monitor policy violation patterns

### 3. Documentation
- Document policy decisions
- Maintain change logs
- Train teams on policy requirements

### 4. Testing
- Test policy changes in development
- Use comprehensive test cases
- Validate with real infrastructure

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review test cases for examples
3. Consult Terraform documentation
4. Contact your infrastructure team

## Version History

- **v1.0.0**: Initial release with basic cost controls
- **v1.1.0**: Added S3 cost optimization validation
- **v1.2.0**: Enhanced IAM role validation
- **v1.3.0**: Added environment-specific limits 