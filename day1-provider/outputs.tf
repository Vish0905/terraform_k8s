output "backend_s3_bucket_name" {
  value       = aws_s3_bucket.backend.id
  description = "The name of the S3 bucket created for the remote state"
}

output "backend_s3_bucket_arn" {
  value       = aws_s3_bucket.backend.arn
  description = "The ARN of the S3 bucket created for the remote state"
}

output "backend_iam_role_arn" {
  value       = aws_iam_role.backend_role.arn
  description = "The ARN of the IAM role created for accessing the remote state"
}
