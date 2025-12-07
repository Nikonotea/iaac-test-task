package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestEC2Module is skipped - requires AWS credentials and VPC setup
// func TestEC2Module(t *testing.T) {
//	t.Parallel()
//
//	terraformOptions := &terraform.Options{
//		TerraformDir: "../../terraform/modules/ec2_app",
//		Vars: map[string]interface{}{
//			"name":      "test-app",
//			"vpc_id":    "vpc-12345",
//			"subnet_id": "subnet-12345",
//			"ami":       "ami-0c55b159cbfafe1f0", // Amazon Linux 2
//		},
//	}
//
//	// Clean up after test
//	defer terraform.Destroy(t, terraformOptions)
//
//	// Initialize and apply
//	terraform.InitAndApply(t, terraformOptions)
//
//	// Verify outputs
//	instanceID := terraform.Output(t, terraformOptions, "instance_id")
//	securityGroupID := terraform.Output(t, terraformOptions, "security_group_id")
//
//	assert.NotEmpty(t, instanceID)
//	assert.NotEmpty(t, securityGroupID)
//	assert.Contains(t, instanceID, "i-")
//	assert.Contains(t, securityGroupID, "sg-")
// }
