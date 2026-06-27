variable "my_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Ec2 instance type to create"
}

variable "ec2_ami" {
  type        = string
  default     = "ami-024ebedf48d280810"
  description = "Ec2 ami to create instance"
}

variable "pem_key_name" {
  type        = string
  description = "Ec2 key pair name to create instance"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources into"
}

variable "s3_bucket_name" {
  type        = string
  description = "Globally unique name for the S3 bucket"
}

variable "backup_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain backups in the vault"
}

variable "backup_schedule" {
  type        = string
  default     = "cron(0 12 * * ? *)"
  description = "AWS Backup schedule cron expression (defaults to daily at 12:00 UTC)"
}