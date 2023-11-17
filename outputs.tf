# output "public-ip-address" {
#   value = aws_instance.demo-app-server.public_ip

# }
# output "aws_ami_id" {
#   value = data.aws_ami.latest_linux_image.id

# }
output "public-ip-address" {
  value = module.instance_ec2-module.ec2-instance.public_ip

}
