# Generate a random suffix for the S3 bucket to ensure global uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket for remote state storage
resource "aws_s3_bucket" "backend" {
  bucket        = "backend-${random_id.bucket_suffix.hex}"
  force_destroy = true # Allows clean destroy during testing/learning

  tags = {
    Name        = "Terraform Backend Bucket"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Enable S3 bucket versioning for remote state history and recovery
resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access to the backend bucket (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "backend_public_access" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Fetch the current AWS account ID dynamically
data "aws_caller_identity" "current" {}

# IAM Role that can be assumed to read/write state in the S3 bucket
resource "aws_iam_role" "backend_role" {
  name = "terraform-backend-role-${random_id.bucket_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "Terraform Backend Role"
    ManagedBy   = "Terraform"
  }
}

# IAM Policy defining exact permissions needed to access the S3 bucket
resource "aws_iam_policy" "backend_policy" {
  name        = "terraform-backend-policy-${random_id.bucket_suffix.hex}"
  description = "IAM Policy for Terraform remote state S3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.backend.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.backend.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "backend_policy_attachment" {
  role       = aws_iam_role.backend_role.name
  policy_arn = aws_iam_policy.backend_policy.arn
}
