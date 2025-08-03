# Advanced Cost Usage Reports Example with Athena Integration

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "finops_cur" {
  source = "../.."

  name_prefix = "cur-example-"
  environment = var.environment
  
  create_cost_usage_report = true
  create_s3_bucket        = true
  create_iam_role        = true

  cost_usage_report = {
    name                    = "detailed-cost-report"
    time_unit              = "HOURLY"
    format                  = "Parquet"
    compression             = "Parquet"
    additional_schema_elements = ["RESOURCES", "SPLIT_COST_ALLOCATION_DATA"]
    s3_bucket              = "${var.name_prefix}cost-reports-${random_string.bucket_suffix.result}"
    s3_region              = var.region
    additional_artifacts   = ["ATHENA"]
    report_versioning      = "OVERWRITE_REPORT"
    refresh_closed_reports = true
    report_frequency       = "DAILY"
  }

  tags = {
    Environment = var.environment
    Project     = "cost-analysis"
    CostCenter  = "finance"
    DataCategory = "cost-reports"
  }
}

# Random string for S3 bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Athena Workgroup for cost analysis
resource "aws_athena_workgroup" "cost_analysis" {
  name = "cost-analysis-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.finops_cur.s3_bucket_id}/athena-results/"
      
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = {
    Name        = "cost-analysis-workgroup"
    Environment = var.environment
  }
}

# Athena named query for monthly costs by service
resource "aws_athena_named_query" "monthly_service_costs" {
  name        = "monthly-service-costs"
  workgroup   = aws_athena_workgroup.cost_analysis.id
  database    = "athenacurcfn_${var.name_prefix}cost_reports"
  description = "Monthly costs aggregated by AWS service"
  
  query = <<EOF
SELECT
  year,
  month,
  product_name,
  SUM(line_item_unblended_cost) as total_cost,
  SUM(line_item_usage_amount) as usage_amount,
  line_item_usage_type as usage_type
FROM
  ${var.name_prefix}cost_reports
WHERE
  year = CAST(year(current_date) AS VARCHAR)
  AND month = CAST(month(current_date) AS VARCHAR)
GROUP BY
  year,
  month,
  product_name,
  line_item_usage_type
HAVING
  SUM(line_item_unblended_cost) > 0
ORDER BY
  total_cost DESC
EOF
}

# Athena named query for daily costs by tag
resource "aws_athena_named_query" "daily_costs_by_tag" {
  name        = "daily-costs-by-tag"
  workgroup   = aws_athena_workgroup.cost_analysis.id
  database    = "athenacurcfn_${var.name_prefix}cost_reports"
  description = "Daily costs aggregated by resource tags"
  
  query = <<EOF
SELECT
  bill_billing_period_start_date as billing_period,
  line_item_usage_start_date as usage_date,
  resource_tags_user_environment as environment,
  resource_tags_user_project as project,
  SUM(line_item_unblended_cost) as total_cost
FROM
  ${var.name_prefix}cost_reports
WHERE
  line_item_usage_start_date >= date_add('day', -30, current_date)
GROUP BY
  bill_billing_period_start_date,
  line_item_usage_start_date,
  resource_tags_user_environment,
  resource_tags_user_project
ORDER BY
  line_item_usage_start_date DESC,
  total_cost DESC
EOF
}

# CloudWatch Dashboard for cost visualization
resource "aws_cloudwatch_dashboard" "cost_analysis" {
  dashboard_name = "cost-analysis-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Estimated Monthly Charges"
          period  = 86400
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "ServiceName", "AmazonEC2", "Currency", "USD"],
            ["AWS/Billing", "EstimatedCharges", "ServiceName", "AmazonRDS", "Currency", "USD"],
            ["AWS/Billing", "EstimatedCharges", "ServiceName", "AmazonS3", "Currency", "USD"]
          ]
          view    = "timeSeries"
          stacked = true
          region  = "us-east-1"
          title   = "Estimated Charges by Service"
          period  = 86400
        }
      }
    ]
  })
}

# Outputs
output "cost_usage_report_id" {
  description = "The ID of the Cost Usage Report"
  value       = module.finops_cur.cost_usage_report_id
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket for Cost Usage Reports"
  value       = module.finops_cur.s3_bucket_id
}

output "athena_workgroup_id" {
  description = "The ID of the Athena workgroup"
  value       = aws_athena_workgroup.cost_analysis.id
}

output "dashboard_arn" {
  description = "The ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.cost_analysis.dashboard_arn
}
