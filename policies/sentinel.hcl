policy "aws-finops-cost-control" {
  source = "./cost-control.sentinel"
  enforcement_level = "hard-mandatory"
}

# Policy parameters with environment-specific overrides
policy "aws-finops-cost-control" {
  source = "./cost-control.sentinel"
  enforcement_level = "hard-mandatory"
  
  # Production environment parameters
  param "environment" {
    value = "prod"
  }
  
  param "max_monthly_cost_increase" {
    value = 15.0
  }
  
  param "max_absolute_monthly_cost" {
    value = 50000.0
  }
  
  param "max_budget_threshold" {
    value = 85.0
  }
}

# Staging environment parameters
policy "aws-finops-cost-control-staging" {
  source = "./cost-control.sentinel"
  enforcement_level = "soft-mandatory"
  
  param "environment" {
    value = "staging"
  }
  
  param "max_monthly_cost_increase" {
    value = 25.0
  }
  
  param "max_absolute_monthly_cost" {
    value = 10000.0
  }
  
  param "max_budget_threshold" {
    value = 90.0
  }
}

# Development environment parameters
policy "aws-finops-cost-control-dev" {
  source = "./cost-control.sentinel"
  enforcement_level = "advisory"
  
  param "environment" {
    value = "dev"
  }
  
  param "max_monthly_cost_increase" {
    value = 50.0
  }
  
  param "max_absolute_monthly_cost" {
    value = 5000.0
  }
  
  param "max_budget_threshold" {
    value = 95.0
  }
} 