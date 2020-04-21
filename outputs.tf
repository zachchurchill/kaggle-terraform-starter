output "s3_bucket_name" {
  value = aws_s3_bucket.kaggle_s3_bucket.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.kaggle_s3_bucket.arn
}
