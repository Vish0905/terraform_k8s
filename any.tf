local {
    ec2_type = "t3.micro"
    ami = "ami-024ebedf48d280810"
    key_name = "ubuntu"
    tags = {
        Name = "my_instance"
    }

}




resource "aws_instance" "my_instance-1" {
    ami = local.ami
    instance_type = local.ec2_type
    key_name = local.key_name
    tags = {
        Name = local.tags.Name
    }
}