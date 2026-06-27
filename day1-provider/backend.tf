terraform {
  backend "s3" {
    bucket = "backend-a1443de7"
    key    = "day1-provider/terraform.tfstate"
    region = "us-east-1"
  }
}
