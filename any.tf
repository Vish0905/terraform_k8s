locals {
  ec2_type = "t3.micro"
  ami      = "ami-024ebedf48d280810"
  key_name = "ubuntu"
  tags = {
    Name = "my_instance"
  }

}

resource "aws_key_pair" "pem_key_name" {
  key_name   = var.pem_key_name
  public_key = file("${path.module}/id_rsa.pub")
}


resource "aws_instance" "my_instance-1" {
  ami               = local.ami
  instance_type     = local.ec2_type
  key_name          = local.key_name
  availability_zone = "us-east-1a"
  tags = {
    Name = local.tags.Name
  }
}