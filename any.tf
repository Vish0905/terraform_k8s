resource "aws_instance" "my_instance" {
    ami = "ami-024ebedf48d280810"
    instance_type = "t2.micro"
    key_name = "ubuntu"
    tags = {
        Name = "my_instance"
    }
}