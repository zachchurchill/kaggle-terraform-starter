# Tests

This folder contains automated "unit" tests for the Module. These tests are written with
the [terratest](https://github.com/gruntwork-io/terratest) Go package created by
[Gruntwork](https://gruntwork.io/). These "unit" tests are broken into a file per service,
and deploys real infrastructure using Terraform to test if the services are set up correctly.
Thus, these "unit" tests are not actual unit tests, but rather the mindset behind focusing
each test case to a single service captures the spirit of unit testing in the traditional sense.

## Warning

1. These tests create actual infrastructure for the AWS account associated with whichever
credentials are provided to the tests are run-time, either through environment variables or the
default configuration set up by the AWS CLI.
2. These tests are set up to destroy any infrastructure created during the test, but may not
always be successful if the test is stopped in the middle of the process. Thus, always take care
to never forcefully shut the tests down while in progress.

## Running the tests

### Prerequisites

- Install latest version of [Go](https://golang.org)
- *Optional* Installation of [dep](https://github.com/golang/dep) for Go dependency management
- Install [Terraform](https://www.terraform.io/downloads.html)
- Configure AWS credentials for test account -- easiest way is to use the `AWS_ACCESS_KEY_ID`
and `AWS_SECRET_ACCESS_KEY` environment variables

### Steps
1. Download Go dependencies, e.g. if you're using `dep`, then run `dep ensure` in this directory.
2. Run all of the tests using `go test -v -timeout 60m`.
3. Run specific tests using `go test -v -timeout 60m -run TestFoo`

