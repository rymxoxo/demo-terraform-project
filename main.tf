provider "aws" {
  region     = "us-east-1"
  access_key = "AKIASK3VTILNBVBJ6SJ3"
  secret_key = "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"


}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "path_to_public_key" {

}
variable "private_key" {

}




resource "aws_vpc" "demo-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }

}
resource "aws_subnet" "demo-app-subnet-1" {
  vpc_id            = aws_vpc.demo-app-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}
# resource "aws_route_table" "demo-app-route_table" {
#   vpc_id = aws_vpc.demo-app-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.demo-app-internet-gateway.id
#   }
#   tags = {
#     Name : "${var.env_prefix}-route-table"
#   }

# }
resource "aws_internet_gateway" "demo-app-internet-gateway" {
  vpc_id = aws_vpc.demo-app-vpc.id
  tags = {
    Name : "${var.env_prefix}-internet-gateway"
  }

}
# resource "aws_route_table_association" "demo-app-association-route-table" {
#   subnet_id      = aws_subnet.demo-app-subnet-1.id
#   route_table_id = aws_route_table.demo-app-route_table.id

# }
/**If we want to add route the existing route table ( main) the one created by default **/
/** If you are willing to use this solution, please don't forget to comment the part pf the creation of route table resource AND the assocation table resource**/

resource "aws_default_route_table" "main_rtb" {
  # At this step we don't need to refer to vpc id because the resource is not created by us 

  default_route_table_id = aws_vpc.demo-app-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-app-internet-gateway.id
  }
  tags = {
    Name : "${var.env_prefix}-main-rtb"
  }
}
/* If you want to change the default security , you can do it by having the resource " aws_default_security_group" */
resource "aws_security_group" "demo-app-aws_security_group" {
  name   = "demo-app-sg"
  vpc_id = aws_vpc.demo-app-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {

    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []

  }
  tags = {
    Name : "${var.env_prefix}-security-group"
  }

}

data "aws_ami" "latest_linux_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
/* to verify the ami obejct we can use the output but don't forget to comment the next part of resource ;)*/

# output "aws_ami_id" {
#   value = data.aws_ami.latest_linux_image.id

# }

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key-1"
  public_key = file(var.path_to_public_key)

}
output "public-ip-address" {
  value = aws_instance.demo-app-server.public_ip

}
resource "aws_instance" "demo-app-server" {
  ami           = data.aws_ami.latest_linux_image.id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.demo-app-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.demo-app-aws_security_group.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name
  #user_data                   = file("entry-script.sh")
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key)
  }

  /* You need t use the file provisoner to copy the file on the server because remote-exec works on the server not on our local machine */
  provisioner "file" {
    source      = "entry-script.sh"
    destination = "/home/ec2-user/entry-script.sh"

  }
  provisioner "remote-exec" {
    # inline = [
    #   "EXPORT ENV=env",
    #   "mkdir newdir"
    # ]

    /*If you want to have a script instead of inline commands */
    script = file("entry-script.sh")
  }
  tags = {
    Name : "${var.env_prefix}-server"

  }

}
