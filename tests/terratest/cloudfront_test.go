package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestCloudfrontModule(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../terraform/modules/cloudfront",
		Vars: map[string]interface{}{
			"bucket_name": "test-frontend-bucket-" + RandomString(t, 8),
		},
	}

	// Clean up after test
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs
	s3Bucket := terraform.Output(t, terraformOptions, "s3_bucket")
	cdnDomain := terraform.Output(t, terraformOptions, "cloudfront_domain")

	assert.NotEmpty(t, s3Bucket)
	assert.NotEmpty(t, cdnDomain)
	assert.Contains(t, cdnDomain, "cloudfront.net")
}
