/* If you want to change the default security , you can do it by having the resource " aws_default_security_group" */
resource "aws_security_group" "demo-app-aws_security_group" {
  name   = "demo-app-sg"
  vpc_id = var.vpc_id
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



resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key-2"
  public_key = file(var.path_to_public_key)

}

resource "aws_instance" "demo-app-server" {
  ami           = data.aws_ami.latest_linux_image.id
  instance_type = var.instance_type

  #   subnet_id                   = module.demo-app-subnet-module.subnet.id
  #We don't have acces to the module of subnet 
  subnet_id = var.subnet_id

  vpc_security_group_ids = [aws_security_group.demo-app-aws_security_group.id]


  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name
  user_data                   = file("entry-script.sh")
  tags = {
    Name : "${var.env_prefix}-server"

  }

}
