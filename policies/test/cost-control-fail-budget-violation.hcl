# Test case: Budget configuration violations that should fail cost control policy
# This test validates that improper budget configurations are caught

mock "tfplan/v2" {
  module {
    source = "./mock-budget-violations.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "./mock-cost-estimate-compliant.sentinel"
  }
}

test {
  rules = {
    main = false
    budget_threshold_rule = false
    encryption_rule = true
    tagging_rule = true
  }
} 