package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFinOpsModuleBasic(t *testing.T) {
	t.Parallel()

	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"name_prefix": "test-basic-",
			"environment": "test",
		},
		NoColor: true,
	})

	// Clean up resources after the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	budgetID := terraform.Output(t, terraformOptions, "budget_id")
	budgetARN := terraform.Output(t, terraformOptions, "budget_arn")
	accountID := terraform.Output(t, terraformOptions, "account_id")

	// Assertions
	assert.NotEmpty(t, budgetID)
	assert.NotEmpty(t, budgetARN)
	assert.NotEmpty(t, accountID)
	assert.Contains(t, budgetARN, "budgets")
}

func TestFinOpsModuleAdvanced(t *testing.T) {
	t.Parallel()

	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/advanced",
		Vars: map[string]interface{}{
			"name_prefix": "test-advanced-",
			"environment": "test",
		},
		NoColor: true,
	})

	// Clean up resources after the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	productionBudgetID := terraform.Output(t, terraformOptions, "production_budget_id")
	developmentBudgetID := terraform.Output(t, terraformOptions, "development_budget_id")
	budgetActionID := terraform.Output(t, terraformOptions, "budget_action_id")
	costUsageReportID := terraform.Output(t, terraformOptions, "cost_usage_report_id")
	s3BucketID := terraform.Output(t, terraformOptions, "s3_bucket_id")
	iamRoleARN := terraform.Output(t, terraformOptions, "iam_role_arn")

	// Assertions
	assert.NotEmpty(t, productionBudgetID)
	assert.NotEmpty(t, developmentBudgetID)
	assert.NotEmpty(t, budgetActionID)
	assert.NotEmpty(t, costUsageReportID)
	assert.NotEmpty(t, s3BucketID)
	assert.NotEmpty(t, iamRoleARN)
}

func TestFinOpsModuleValidation(t *testing.T) {
	t.Parallel()

	// Test module validation
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "..",
		NoColor:      true,
	})

	// Validate the module
	terraform.Validate(t, terraformOptions)
}

func TestFinOpsModuleFormat(t *testing.T) {
	t.Parallel()

	// Test module formatting
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "..",
		NoColor:      true,
	})

	// Format the module
	terraform.Fmt(t, terraformOptions)
}
