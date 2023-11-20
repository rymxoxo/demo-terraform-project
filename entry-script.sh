#!/bin/bash
# The above line specifies that this script should be interpreted using Bash

# Update the package manager and install Docker
#-y : the confirm is automated because we are not on interactive mode
sudo yum update -y && sudo yum install -y docker

# Start the Docker service
sudo systemctl start docker

# Add the user "ec2-user" to the "docker" group
sudo usermod -aG docker ec2-user

# Run a Docker container using the Nginx image, mapping port 8080 on the host to port 80 in the container
docker run -p 8080:80 nginx
