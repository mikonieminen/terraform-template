
output "terraform_backend_config" {
  value = {
    bucket         = aws_s3_bucket.terraform_bucket.bucket
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
    region         = aws_s3_bucket.terraform_bucket.region
  }
}
