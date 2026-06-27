# ==============================================================================
# S3 Bucket Configuration
# ==============================================================================

resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# AWS Backup for S3 requires versioning to be enabled
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Server-Side Encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==============================================================================
# AWS Backup Configuration
# ==============================================================================

# Create a Backup Vault to store the recovery points
resource "aws_backup_vault" "s3_backup_vault" {
  name = "${var.s3_bucket_name}-backup-vault"
  tags = {
    Name      = "${var.s3_bucket_name}-backup-vault"
    ManagedBy = "Terraform"
  }
}

# Create a Backup Plan
resource "aws_backup_plan" "s3_backup_plan" {
  name = "${var.s3_bucket_name}-backup-plan"

  rule {
    rule_name         = "${var.s3_bucket_name}-backup-rule"
    target_vault_name = aws_backup_vault.s3_backup_vault.name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = {
    Name      = "${var.s3_bucket_name}-backup-plan"
    ManagedBy = "Terraform"
  }
}

# IAM Role assumed by AWS Backup
resource "aws_iam_role" "backup_role" {
  name = "${var.s3_bucket_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

# Attach standard backup policy to the role
resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

# Attach standard restore policy to the role
resource "aws_iam_role_policy_attachment" "restore_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_role.name
}

# Associate the S3 bucket with the backup plan
resource "aws_backup_selection" "s3_backup_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.s3_bucket_name}-backup-selection"
  plan_id      = aws_backup_plan.s3_backup_plan.id

  resources = [
    aws_s3_bucket.bucket.arn
  ]
}
