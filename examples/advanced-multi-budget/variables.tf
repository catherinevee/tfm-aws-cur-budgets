# Variables for advanced multi-budget example

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

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = "alerts@example.com"
}

variable "dev_alert_email" {
  description = "Email address for development budget alerts"
  type        = string
  default     = "dev-alerts@example.com"
}
