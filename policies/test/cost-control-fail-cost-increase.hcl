# Test case: Cost increase violations that should fail cost control policy
# This test validates that excessive cost increases are caught

mock "tfplan/v2" {
  module {
    source = "./mock-compliant-finops.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "./mock-cost-estimate-violation.sentinel"
  }
}

test {
  rules = {
    main = false
    budget_threshold_rule = true
    encryption_rule = true
    tagging_rule = true
  }
} 