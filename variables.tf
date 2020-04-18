# ----------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ----------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ----------------------------------------------------------------------------------------------------------------------

variable "competition" {
  description = "Name of the Kaggle competition used by the `kaggle` API, e.g. house-prices-advanced-regression-techniques"
  type        = string
}

variable "secret_name" {
  description = "The name of the Secrets Manager secret that contains the `kaggle.json` API credentials"
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ----------------------------------------------------------------------------------------------------------------------
