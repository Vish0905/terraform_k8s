resource "aws_instance" "my_instance-2" {
  ami               = local.ami
  instance_type     = local.ec2_type
  key_name          = local.key_name
  availability_zone = "us-east-1a"
  tags = {
    Name = local.tags.Name
  }
}