resource "aws_subnet" "demo-app-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}
# resource "aws_route_table" "demo-app-route_table" {
#   vpc_id = var.vpc_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.demo-app-internet-gateway.id
#   }
#   tags = {
#     Name : "${var.env_prefix}-route-table"
#   }

# }
resource "aws_internet_gateway" "demo-app-internet-gateway" {
  vpc_id = var.vpc_id
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

  default_route_table_id = var.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-app-internet-gateway.id
  }
  tags = {
    Name : "${var.env_prefix}-main-rtb"
  }
}
