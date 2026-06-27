terraform {
  backend "s3" {
    bucket = "backend-a1443de7"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
