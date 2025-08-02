variables {
  name_prefix = "test-"
  environment = "test"
  
  budgets = {
    test_budget = {
      name              = "test-budget"
      budget_type       = "COST"
      limit_amount      = 100
      limit_unit        = "USD"
      time_period_start = "2025-01-01_00:00"
      time_unit         = "MONTHLY"
    }
  }
}

run "validate_budget_creation" {
  command = plan

  assert {
    condition     = length(aws_budgets_budget.this) > 0
    error_message = "No budgets would be created"
  }
}

run "validate_budget_configuration" {
  command = plan

  assert {
    condition     = aws_budgets_budget.this["test_budget"].limit_amount == 100
    error_message = "Budget limit amount does not match expected value"
  }

  assert {
    condition     = aws_budgets_budget.this["test_budget"].time_unit == "MONTHLY"
    error_message = "Budget time unit does not match expected value"
  }
}

run "validate_s3_bucket_encryption" {
  command = plan

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.cur_bucket[0].rule[0].apply_server_side_encryption_by_default.sse_algorithm == "AES256"
    error_message = "S3 bucket encryption is not properly configured"
  }
}
