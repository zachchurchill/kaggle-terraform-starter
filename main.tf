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

# ----------------------------------------------------------------------------------------------------------------------
# S3 BUCKET
# We're going to set up an S3 bucket that is dedicated to storing the data and model artifacts for each
# Kaggle competition that's created with this module. In order to ensure that the S3 uses a unique bucket
# name, a variable for the S3 bucket prefix is provided for the user to use; otherwise, if the variable is
# not given a value, then the AWS caller identity's account ID number is used.
# ----------------------------------------------------------------------------------------------------------------------

locals {
  s3_bucket_prefix = var.s3_bucket_prefix == null ? data.aws_caller_identity.current.account_id : var.s3_bucket_prefix
}

resource "aws_s3_bucket" "kaggle_s3_bucket" {
  bucket = "${local.s3_bucket_prefix}-kaggle-${var.competition}"
  acl    = "private"
}
