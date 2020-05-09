output "s3_bucket_name" {
  value = aws_s3_bucket.kaggle_s3_bucket.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.kaggle_s3_bucket.arn
}

output "lifecycle_script_arn" {
  value = aws_sagemaker_notebook_instance_lifecycle_configuration.competition_lifecycle.arn
}

output "notebook_arn" {
  value = aws_sagemaker_notebook_instance.notebook_instance.arn
}
