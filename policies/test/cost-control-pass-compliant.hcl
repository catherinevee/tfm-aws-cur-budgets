# Test case: Compliant FinOps resources that should pass cost control policy
# This test validates that properly configured resources pass all cost control checks

mock "tfplan/v2" {
  module {
    source = "./mock-compliant-finops.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "./mock-cost-estimate-compliant.sentinel"
  }
}

test {
  rules = {
    main = true
    budget_threshold_rule = true
    encryption_rule = true
    tagging_rule = true
  }
} 