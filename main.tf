provider "aws" {
  region     = "us-east-1"
  access_key = "AKIASK3VTILNLPJPTWOG"
  secret_key = "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"


}


resource "aws_vpc" "demo-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }

}
module "demo-app-subnet-module" {
  source                 = "./modules/subnet"
  subnet_cidr_block      = var.subnet_cidr_block
  avail_zone             = var.avail_zone
  env_prefix             = var.env_prefix
  vpc_id                 = aws_vpc.demo-app-vpc.id
  default_route_table_id = aws_vpc.demo-app-vpc.default_route_table_id

}
module "instance_ec2-module" {
  source             = "./modules/webserver"
  my_ip              = var.my_ip
  env_prefix         = var.env_prefix
  path_to_public_key = var.path_to_public_key
  instance_type      = var.instance_type
  avail_zone         = var.avail_zone
  vpc_id             = aws_vpc.demo-app-vpc.id
  subnet_id          = module.demo-app-subnet-module.subnet.id

}

