package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../terraform/modules/vpc",
		Vars: map[string]interface{}{
			"name":       "test-vpc",
			"cidr_block": "10.0.0.0/16",
			"azs":        []string{"us-east-1a", "us-east-1b"},
		},
	}

	// Clean up after test
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply the terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs exist and are non-empty
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	publicSubnets := terraform.Output(t, terraformOptions, "public_subnets")
	privateSubnets := terraform.Output(t, terraformOptions, "private_subnets")

	assert.NotEmpty(t, vpcID)
	assert.NotEmpty(t, publicSubnets)
	assert.NotEmpty(t, privateSubnets)
}
