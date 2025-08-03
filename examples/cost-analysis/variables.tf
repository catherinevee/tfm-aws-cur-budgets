# Variables for cost analysis example

variable "environment" {
  description = "Environment name for tagging and resource naming"
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
  default     = "finops-"
}

variable "athena_output_bucket" {
  description = "S3 bucket for Athena query results"
  type        = string
  default     = null
}
