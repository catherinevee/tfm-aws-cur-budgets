# Upgrade Guide

This document provides instructions for upgrading from previous versions of the module.

## Upgrading to v1.0.0

### Breaking Changes

1. Provider Version Requirements
   - Terraform version requirement changed to ~> 1.13.0
   - AWS provider version requirement changed to ~> 6.2.0
   - Added Azure provider requirement ~> 4.38.1

2. Variable Changes
   - Added validation rules for `name_prefix` and `environment` variables
   - `environment` variable now restricted to: dev, staging, prod, test

### Migration Steps

1. Update provider versions in your Terraform configuration:
```hcl
terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.38.1"
    }
  }
}
```

2. Update environment values to match new constraints:
```hcl
environment = "dev"  # Must be one of: dev, staging, prod, test
```

3. Run terraform init -upgrade to update providers

4. Review and update any custom budget actions to ensure compatibility

### New Features

1. Enhanced Security
   - S3 bucket encryption enabled by default
   - Stricter IAM permissions
   - Added bucket versioning

2. Improved Testing
   - Added native Terraform tests
   - Added Terratest integration

3. Documentation
   - Added resource map
   - Improved examples
   - Added CHANGELOG.md
