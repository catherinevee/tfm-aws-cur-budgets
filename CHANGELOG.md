# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-02

### Added
- Initial release of the AWS FinOps module
- AWS Budgets management with notifications
- Budget actions for automated cost control
- Cost Usage Report configuration
- S3 bucket management for cost reports
- IAM role and policy management
- Comprehensive examples (basic and complete)
- Test suite with Terratest and native testing
- Input variable validations
- Terraform 1.13.0 compatibility
- AWS Provider 6.2.0 support
- Azure Provider 4.38.1 support

### Changed
- Updated provider version requirements
- Enhanced security configurations for S3 buckets
- Improved variable validations

### Security
- Implemented S3 bucket encryption
- Added public access blocking
- Implemented IAM least privilege principle
