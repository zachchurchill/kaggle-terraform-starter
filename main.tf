# ----------------------------------------------------------------------------------------------------------------------
# SET-UP SERVICES FOR KAGGLE COMPETITION
# This module provides some key resources needed when setting up your AWS environment before
# participating in a Kaggle competition.
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  version = "~> 2.57"
  region  = "us-east-2"

}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ----------------------------------------------------------------------------------------------------------------------
# KAGGLE API CREDENTIALS SECRET
# In order to allow the user to interact with Kaggle from the SageMaker Notebook Instance, the Secrets
# Manager secret containing the API key provided in the `kaggle.json` file needs to already exist in
# the user's AWS account. Thus, we will just reference it using a `data` block.
# ----------------------------------------------------------------------------------------------------------------------

data "aws_secretsmanager_secret" "kaggle_api" {
  name = var.secret_name
}
