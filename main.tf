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
# SET-UP VARIABLES
# In order to make use of the potential testing suffixes, we're going to create all of the necessary
# variables in a local block to utilize the suffix if provided.
# ----------------------------------------------------------------------------------------------------------------------

locals {
  competition      = var.random_testing_suffix == null ? var.competition : "${var.competition}-${var.random_testing_suffix}"
  s3_bucket_prefix = var.s3_bucket_prefix == null ? data.aws_caller_identity.current.account_id : var.s3_bucket_prefix
}

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

resource "aws_s3_bucket" "kaggle_s3_bucket" {
  bucket = "${local.s3_bucket_prefix}-kaggle-${local.competition}"
  acl    = "private"
}

# ----------------------------------------------------------------------------------------------------------------------
# IAM ROLE
#	In order to keep the permissions for various resources across the user's account tidy, we will set up an
#	IAM role that will be used by the SageMaker services. This IAM role will have access to get the Kaggle
#	API key from SecretsManager, and full access to the S3 bucket for this competition.
# ----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "kaggle_iam_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.kaggle_s3_bucket.bucket}"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      data.aws_secretsmanager_secret.kaggle_api.arn
    ]
  }
}

resource "aws_iam_policy" "kaggle_iam_policy" {
  name   = "kaggle-${local.competition}"
  path   = "/"
  policy = data.aws_iam_policy_document.kaggle_iam_policy.json
}

resource "aws_iam_role" "kaggle_iam_role" {
  name = "kaggle-${local.competition}"

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "sagemaker.amazonaws.com"
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kaggle_iam_policy_attach" {
  role       = aws_iam_role.kaggle_iam_role.name
  policy_arn = aws_iam_policy.kaggle_iam_policy.arn
}

# ----------------------------------------------------------------------------------------------------------------------
# SageMaker Lifecycle Configuration
# In order to provide users easy access to the Kaggle API package in every Python 3 environment provided
# by SageMaker, the following lifecycle configuration will: fetch the secret value of the Kaggle API key
# and save it in the default location on the EC2 instance that the Notebook instance creates, and performs
# a `pip install` in each Python 3 environment for the kaggle package.
# ----------------------------------------------------------------------------------------------------------------------

data "local_file" "lifecycle_script" {
  filename = "${path.module}/src/lifecycle.sh"
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "competition_lifecycle" {
  name     = "${local.competition}-lifecycle"
  on_start = base64encode(data.local_file.lifecycle_script.content)
}

# ----------------------------------------------------------------------------------------------------------------------
# SageMaker Notebook Instance
# The main purpose of this module, the following resource creates the SageMaker Notebook Instance
# using the IAM role and Lifecycle configuration defined above. Additionally, it utilizes a variable
# for the instance type so that the user can create large notebook instances with Terraform.
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_sagemaker_notebook_instance" "notebook_instance" {
  name                  = "${local.competition}-notebook"
  role_arn              = aws_iam_role.kaggle_iam_role.arn
  instance_type         = var.notebook_instance_type
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.competition_lifecycle.name
}
