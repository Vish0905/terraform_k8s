output "ec2_public_ip" {
  description = "ec2_public_ip"
  value       = aws_instance.my_instance-1.public_ip

}

output "ec2_private_ip" {
  description = "ec2_private_ip"
  value       = aws_instance.my_instance-1.private_ip
}

output "ec2_id" {
  description = "ec2_id"
  value       = aws_instance.my_instance-1.id
}

output "ec2_sg" {
  description = "ec2_sg"
  value       = aws_instance.my_instance-1.security_groups
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "s3_bucket_id" {
  description = "The name/ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup Vault"
  value       = aws_backup_vault.s3_backup_vault.arn
}