**HELLO!** 👋

Welcome to the exciting journey I've embarked on over the past few days, diving into the world of Terraform and exploring a demo project. 🌍🚀 This project is a tapestry of different branches, each addressing specific needs and exploring distinct features. Let's dive into the details of the `feature/deploy-ec2-default-component` branch, where we have a monolithic code structure with all the resources consolidated in one file, `main.tf`. 🤖

## Let's Get Started 🚀

### Goals 🎯

By the end of this demo project, you will:

1. 🌐 Provision an EC2 instance on AWS infrastructure.
2. 🐳 Run an Nginx Docker container on the EC2 instance.

### I. Provision AWS Infrastructure 🛠️

1. **Create Custom VPC**
2. **Create Custom Subnet**
3. **Create Route Table & Internet Gateway**
4. **Provision EC2 Instance**
5. **Deploy Nginx Docker Container**
6. **Create Security Group**

Before delving into the technical details, let's first understand the terms mentioned:

**VPC (Virtual Private Cloud)**
A VPC is an isolated network within cloud computing, allowing you to securely run and organize virtual resources such as servers and databases.

**Subnet**
A subnet is a network inside a network.

**Route Table**
A route table contains rules (routes) that determine where network traffic is directed. Each subnet in a VPC must be associated with a route table, controlling traffic routing for the subnet. It's like a virtual router in a VPC.

**Internet Gateway**
Used in our VPC to connect or communicate with the internet, not for communication between subnets.

**Security Group**
A security group is like a firewall for an instance (not a subnet), and by default, its role is to restrict communication.

## BEST PRACTICES 🌟

Throughout each part, I'll highlight the best practices learned from the demo project. 📘

```bash
# Create infrastructure from scratch
```

```bash
Leave the defaults created by AWS as they are.
```

# 1. VPC & Subnet:

In the development field, there are different stages:

- `dev-vpc`
- `staging-vpc`
- `prod-vpc`

Since this information is variable and can be one of the mentioned stages, we need to create a variable:

```hcl
variable "env_prefix" {}
```

The usage or call of this variable is generally within the VPC resource, as shown in the tags of the VPC resource:

```hcl
tags = {
  Name : "${var.env_prefix}-vpc"
}
```

Generally, the call of one variable is as follows:

```hcl
var.NAME_OF_VARIABLE
```

But in this case, since the call is within a string, we have to use `${}`:

```hcl
"${var.NAME_OF_VARIABLE}-some-text"
```

**Note:**

- There is a DEFAULT VPC for every region.
- There is 1 default subnet per Availability Zone, e.g., if there are 3 AZs in a region, that means 3 default subnets in the VPC.

**Creation of Resources:**
Terraform provides very detailed documentation, offering clear guidance and commands. For example: [Terraform AWS Default VPC Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc). Following this link, you'll find the "Resource: aws_default_vpc."

**Important:**
Whatever resource you create, like a subnet or internet gateway, you need to mention in which VPC they are associated, and this is done by the following attribute:

```hcl
vpc_id = aws_vpc.demo-app-vpc.id
```

You specify more precisely the ID of the VPC. How do you call the attribute? Easy:

```hcl
vpc_id = aws_vpc.name_of_vpc_you_have_chosen.id
```

```hcl
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
```

Now that we have created our VPC and our SUBNET, we need to move on and create our route table and internet gateway, right?

**Route Table**
Before we start, I want to mention the following notes:

- When we have created our subnet, a default route table has been created by AWS. The question is, do you want to work with this default created route table or create your own table? There is no correct answer for this question, and in this demo project, I have done both to explore more about them.
- How do we know the default route table from the default one?
  - While we create our table, it's among the best practice to tag the resource as follows:

```hcl
tags = {
  Name : "${var.env_prefix}-route-table"
}
```

- We can verify on the AWS UI website before the route table if the attribute 'main' is set to no or yes. If it's NO, this means that this table is not the default one. If it's YES, it's the default route.

Let's break down and understand what is written down here:

```hcl
resource "aws_route_table" "demo-app-route_table" {
  vpc_id = aws_vpc.demo-app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-app-internet-gateway.id
  }

  tags = {
    Name : "${var.env_prefix}-route-table"
  }
}
```

- `cidr_block` is set to "0.0.0.0/0," which represents all possible IP addresses (IPv4).
- `gateway_id` is set to the ID of an Internet Gateway (`aws_internet_gateway.demo-app-internet-gateway.id`).
  - PS: If we're changing the default route table, you don't need to mention the VPC ID because this resource is not created by us.
  - PS: By default, the router for internal routes is automatically created; that's why we only mention the internet route `0.0.0.0/0`.

**Internet Gateway**

```hcl
resource "aws_internet_gateway" "demo-app-internet-gateway" {
  vpc_id = aws_vpc.demo-app-vpc.id
  tags = {
    Name : "${var.env_prefix}-internet-gateway"
  }
}
```

PS: An important thing you need to know is that Terraform knows in which sequence the components must be created. For example, you can have the code of subnets before the one of the VPC.

**Subnet Association with Route Table**
As I mentioned before, the route table is for a subnet

. BUTTTT!!! Subnet association must be done only with the route table you create and not with the default one. Association happens by default with the existing resource (not created by us).

```hcl
resource "aws_route_table_association" "demo-app-association-route-table" {
  subnet_id      = aws_subnet.demo-app-subnet-1.id
  route_table_id = aws_route_table.demo-app-route_table.id
}
```

**Security Group**
Within the security group resource, we are going to tell the EC2 instance what rules to follow. Let me clarify more. Within the security group, we are going to specify the incoming traffic:

- SSH into EC2.
- Access from the browser (to the instance).
  And outgoing (from the instance) :
- Installation.
- Fetch Docker image.

Let's break this down and understand it:

```hcl
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = [var.my_ip]
```

- `from_port` to `to_port`: is to specify a range of ports.
- `cidr_blocks`: who is allowed to access the resource on port 22 (generally is your PC address, right? You can check your IP address by visiting this website: [What's my IP?](https://www.wizcase.com/tools/whats-my-ip/?gad_source=1&gclid=Cj0KCQiApOyqBhDlARIsAGfnyMqi8sbo2iEsbaESg9knQsP7YyAuUJCcXS9iB30AGaks5d8IKzjO9nIaApdzEALw_wcB))

```hcl
from_port       = 0 # to match any port
to_port         = 0
protocol        = "-1" # any traffic
cidr_blocks     = ["0.0.0.0/0"]
```

**Create EC2 Instance**
Best Practice: The image which the EC2 instance will be based on should NOT be hard-coded because the image ID can change. So, query the latest image from AWS instead of being hard-coded.

```hcl
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
```

`aws_ami` is data and not a resource, as we can see. So, the question is now, what is data and what is a resource?

**DATA VS RESOURCE**

- Data: used to query info about existing resources or external resources.
- Resource: is used to define, manage infra specifying how they should be created, configured, and maintained.

The creation of the EC2 instance must pass through other steps before. As we know, to access an EC2 instance using SSH, we need to have an SSH key, right? And instead of creating the key manually using the UI of AWS, we can automate the creation of an SSH key pair, AMAZING right?! And this can be done thanks to:

```hcl
resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key-1"
  public_key = file(var.path_to_public_key)
}
```

Explanation:

- Key Pair Name ("server-key-1"): This is just a name you give to your set of keys on AWS. It's like a label.
- Public Key: The actual content of the public key comes from the file specified by `var.path_to_public_key` (in your case, "/home/rym/.ssh/id_rsa.pub"). The public key is a part of the key pair. It's shared with AWS.
- Private Key: The private key is not handled directly by Terraform. It's something you keep secure on your local machine ("/home/rym/.ssh/id_rsa"). It's used for logging into instances.
  - Terraform Apply: When you run `terraform apply`, Terraform tells AWS to create a new key pair named "server-key-1" and associates the specified public key with it.
  - Use with EC2 Instances: When you launch an EC2 instance and specify "server-key-1" as the key pair, AWS puts the associated public key into the instance. You use your private key to securely log in to that EC2 instance.
  - So, "server-key-1" is the name of your key pair on AWS, and the actual public key content comes from the file specified in `var.path_to_public_key`.
  - PS: the key pair must already exist locally on your machine. If this does not apply, don't worry, try:

```bash
ssh-keygen
```

to generate a public/private RSA key pair.

## BEST PRACTISE:

If you are generating your key with the AWS website, don't forget to:

1. Move the .pem file to your .ssh folder.
2. Restrict permissions on the .pem file because AWS rejects SSH requests if permission is not set correctly.

```bash
chmod 400 ~/.ssh/key_name.pem
```

Finally:

```bash
# Define an AWS EC2 instance resource named "demo-app-server"
resource "aws_instance" "demo-app-server" {
  # Specify the Amazon Machine Image (AMI) to use for the instance
  ami = data.aws_ami.latest_linux_image.id

  # Specify the type of EC2 instance to launch, using a variable
  instance_type = var.instance_type

  # Specify the subnet ID where the EC2 instance will be launched
  subnet_id = aws_subnet.demo-app-subnet-1.id

  # Specify the security group(s) associated with the EC2 instance
  vpc_security_group_ids = [aws_security_group.demo-app-aws_security_group.id]

  # Specify the availability zone for the EC2 instance
  availability_zone = var.avail_zone

  # Associate a public IP address with the EC2 instance
  # Because we want to be able to access this from the browser as well as SSH
  associate_public_ip_address = true

  # Specify the key pair to use for SSH authentication
  key_name = aws_key_pair.ssh-key.key_name

  # Commented out: user_data can be used to provide instance configuration scripts
  user_data = file("entry-script.sh")

  # Specify SSH connection details for Terraform to connect to the EC2 instance
  connection {
    type        = "ssh"
    host        = self.public_ip # Use the public IP address of the instance
    user        = "ec2-user"     # SSH username
    private_key = file(var.private_key) # Path to the private key file for authentication
  }
}
```

### Deploy Nginx Docker Container 🐳

Finally, after successfully having the EC2 instance and configuring the network, it's time to have Nginx running on our EC2 instance. To do so, we use:

```hcl
user_data = file("entry-script.sh")
```

So with Terraform, we can run commands on EC2 at the time of creation:

Remember, the entry-script.sh file contains the necessary commands to set up and run Nginx within a Docker container on the EC2 instance.
Make sure that the entry-script.sh file is in the same directory as your Terraform configuration file.

Feel free to explore and tweak the entry-script.sh file to customize the Nginx deployment according to your project requirements
With this final piece, your Terraform project orchestrates the creation of AWS infrastructure, sets up an EC2 instance, and deploys an Nginx Docker container, showcasing the power and flexibility of infrastructure as code with Terraform. 🚀🌐
Feel free to reach out if you have any questions or need further assistance! Happy coding! 😊👩‍💻👨‍💻

# Conclusion

**Terraform Configures Infrastructure, NOT Servers**

| Terraform Configuration Language | Simple Shell Script                   |
| -------------------------------- | ------------------------------------- |
| Manages Infrastructure           | Configures Provisioned Infrastructure |
| Creates AWS Infrastructure       | Installs Docker on Server             |
| Provisions Server                | Deploys an App on Server              |

**Terraform provides the ability to execute scripts using the "USER_DATA" attribute. However, debugging can be challenging.**

[![](https://visitcount.itsvg.in/api?id=rym&label=Profile%20Views&color=10&icon=5&pretty=true)](https://visitcount.itsvg.in)
