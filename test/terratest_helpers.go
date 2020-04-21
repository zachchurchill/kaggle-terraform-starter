// terratest_helpers providers constants and functions used across all of the tests
package test

// Constants that will be used by all tests
const awsRegion string = "us-east-2"
const competitionName string = "test-competition"
const kaggleApiSecret string = "KaggleApiKey"

// getRequiredVariables is a helper function that provides tests with
// a map of the necessary input variables for the module
func getRequiredVariables() map[string]interface{} {
	variables := map[string]interface{}{
		"competition": competitionName,
		"secret_name": kaggleApiSecret,
	}
	return variables
}
