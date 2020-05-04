// s3_bucket_test runs some basic tests on the S3 bucket to ensure it's created correctly
package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Constants specific to these tests
const s3BucketPrefixVariable string = "s3_bucket_prefix"
const s3BucketNameOutput string = "s3_bucket_name"

// getBucketName is a helper function that returns the bucket name using the
// same formatted string as the Terraform module code
func getBucketName(prefix, competition, randomSuffix string) string {
	return fmt.Sprintf("%s-kaggle-%s-%s", prefix, competition, randomSuffix)
}

func TestS3BucketWithDefaultBucketPrefix(t *testing.T) {
	t.Parallel()

	// Set up variables to include random testing suffix
	variables := getRequiredVariables()
	suffixVariable, suffixValue := getRandomTestingSuffix()
	variables[suffixVariable] = suffixValue

	testS3Bucket(
		t,
		variables,
		getBucketName(aws.GetAccountId(t), competitionName, suffixValue),
	)
}

func TestS3BucketWithProvidedBucketPrefix(t *testing.T) {
	t.Parallel()

	// Set up variables to include random testing suffix and include prefix for S3
	variables := getRequiredVariables()

	suffixVariable, suffixValue := getRandomTestingSuffix()
	variables[suffixVariable] = suffixValue

	s3BucketPrefix := "test-prefix"
	variables[s3BucketPrefixVariable] = s3BucketPrefix

	testS3Bucket(
		t,
		variables,
		getBucketName(s3BucketPrefix, competitionName, suffixValue),
	)
}

func testS3Bucket(t *testing.T, inputVariables map[string]interface{}, expectedBucketName string) {
	// Set up Terraform options with necessary input and environment variables
	terraformOptions := &terraform.Options{
		TerraformDir: "..",
		Vars:         inputVariables,
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// Ensure test cleans up resources, regardless if it is successful
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply Terraform resources
	terraform.InitAndApply(t, terraformOptions)

	// Ensure actual bucket name equals expected
	actualBucketName := terraform.Output(t, terraformOptions, s3BucketNameOutput)
	assert.Equal(t, expectedBucketName, actualBucketName)

	// Ensure bucket actual exists
	aws.AssertS3BucketExists(t, awsRegion, actualBucketName)
}
