**HELLO!**
Welcome to the journey I've embarked on over the past few days, exploring and learning from a demo Terraform project. This project is divided into different branches, each addressing specific needs or exploring distinct features. Let's dive into the details of the `feature/deploy-ec2-default-component` branch, where we have a monolithic code structure with all the resources consolidated in one file, `main.tf`.

## Let's Get Started

### Goals

By the end of this demo project, you will:

1. Provision an EC2 instance on AWS infrastructure.
2. Run an Nginx Docker container on the EC2 instance.

### I. Provision AWS Infrastructure

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

## BEST PRACTICES

Throughout each part, I'll highlight the best practices learned from the demo project.

```bash
# Create infrastructure from scratch
terraform apply
```

Leave the defaults created by AWS as they are.

```bash
# 1. VPC & Subnet:
terraform apply
```

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

Now that we have created our VPC and our SUBNET
we need to move on and created our route table and intenet gateway right ?
**route table**
Before we start i want to mention the follownig notes :
-When we have created ou subnet ,a default route table have been created by AWS and the question is that you want to work on this default created route table or create you own table ?
there is no correct answer for this question
and on this demo project i have done both to explore more about them
-How do we know the default route table from the defailt one ?:
-WHile we create our table it's among best practise to tag the resource as followinf:

```hcl

            tags = {
     Name : "${var.env_prefix}-route-table"

}

```

     -We can verify on the aws ui web site before the route table if the attribut main is set to no or yes
         if it's NO : this means that this table is nt the default one
                 YES: the default route

let's break and understand what is writen down here
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

cidr_block is set to "0.0.0.0/0", which represents all possible IP addresses (IPv4).
gateway_id is set to the ID of an Internet Gateway (aws_internet_gateway.demo-app-internet-gateway.id).
PS : if we re changing the defaut route table you dont need to mention the vpc id brcause this resorce is not created by us
PS:By default the router for internal routes is automatically created thats why we only mention the internet route 0.0.0.0/0
**internet gateway**
resource "aws_internet_gateway" "demo-app-internet-gateway" {
vpc_id = aws_vpc.demo-app-vpc.id
tags = {
Name : "${var.env_prefix}-internet-gateway"
}

}
ps: Important thing you need to know all, that terraform knows in which sequence the componenets must be created for example you can have the code of subnets before the one of the vpc
**Subnet Association with route table**
As i mentioned before route table is for a subnet
BUTTTT !!! subnet association must be done only with the route table you create and not with the default one.
Association happen by default with the existion resource ( not created by us)

``````bash
 resource "aws_route_table_association" "demo-app-association-route-table" {
   subnet_id      = aws_subnet.demo-app-subnet-1.id
   route_table_id = aws_route_table.demo-app-route_table.id

 }```
4.Security Group:
within the security group resource we are going to tell the ec2 instance what rules you need to follow. let me clarify more within the securoty group we ar going to specify the incoming traffinc :
        -ssh into EC2
        -access from the browser
(to the instace )and outgoing (from the instance)
        -installation
        -fetch docker image

        let's break this and understand it :
        ```bash
         from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    ````
    from_port to_port : is to specify a range of port
    cidr_blocks=who is allowed to access resource on port 22 ( generally is your pc adresse right ? you can check you ip @ by visinth this website:https://www.wizcase.com/tools/whats-my-ip/?gad_source=1&gclid=Cj0KCQiApOyqBhDlARIsAGfnyMqi8sbo2iEsbaESg9knQsP7YyAuUJCcXS9iB30AGaks5d8IKzjO9nIaApdzEALw_wcB)
    ps: if you want to have only one address accesible don't forget to put the mask as /32 on yout adresse

      ```bash
      from_port       = 0 /**to match any port
    to_port         = 0
    protocol        = "-1" /**any traffic
    cidr_blocks     = ["0.0.0.0/0"]
    `````

6.Create EC2 instance
Best Practise:
the image wichi the ec2 instance will be base should NOT be hard coded, because the image id can change
so query the latest image from aws instead of being hard coded
```bash
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
``````

"aws_ami" id data and not resource as we can see so the question is now what is data and what is resource ?
**DATA VS RESOURCE**
-Data: id used to query info about sexisting resource or external resource
-Resource: is used to define , manage infra specifing how they should be created configured and maintened

**THe creation of ec2 instace must be passed by other steps before**
as we know to access en ec2 instance using ssh we need to have ssh key right?
and instead to create manually the key using the ui of aws we can automate the creaton of ssh key pair, AMAZING right ?!and this can be done thanks to

    ```````bash
    resource "aws_key_pair" "ssh-key" {
    key_name   = "server-key-1"
    public_key = file(var.path_to_public_key)

}``````
explantion:
Key Pair Name ("server-key-1"):

This is just a name you give to your set of keys on AWS. It's like a label.
Public Key:

The actual content of the public key comes from the file specified by var.path_to_public_key (in your case, "/home/rym/.ssh/id_rsa.pub").
The public key is a part of the key pair. It's shared with AWS.
Private Key:

The private key is not handled directly by Terraform. It's something you keep secure on your local machine ("/home/rym/.ssh/id_rsa"). It's used for logging into instances.
Terraform Apply:

When you run terraform apply, Terraform tells AWS to create a new key pair named "server-key-1" and associates the specified public key with it.
Use with EC2 Instances:

When you launch an EC2 instance and specify "server-key-1" as the key pair, AWS puts the associated public key into the instance.
You use your private key to securely log in to that EC2 instance.
So, "server-key-1" is the name of your key pair on AWS, and the actual public key content comes from the file specified in var.path_to_public_key.
PS: key pair must already exist locally on your machine. if this does not apply dont worry trype

```bash
ssh-keygen
```

to generatee public/private rsa key pair

##BEST PRACTISE:
if you are generating your key with aws web site don't forget to :
1.Move .pem file to your .ssh folder
2.Restrict permissions on .pem file because aws rejects ssh request if permision is not set correctly

```bash
chmod 400 ~/.ssh/key_name.pem
```

FInally
``bash

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

# Associate a public IP address with the EC2 instance+Because we want to be able to access this from browser as well as ssh

associate_public_ip_address = true

# Specify the key pair to use for SSH authentication

key_name = aws_key_pair.ssh-key.key_name

# Commented out: user_data can be used to provide instance configuration scripts

user_data = file("entry-script.sh")

# Specify SSH connection details for Terraform to connect to the EC2 instance

connection {
type = "ssh"
host = self.public_ip # Use the public IP address of the instance
user = "ec2-user" # SSH username
private_key = file(var.private_key) # Path to the private key file for authentication
}
}

``
8.Deploy nginx docker container
Finally after succelut having the ec2 and configure the network
its time to have nginx running on our ec2 instace
to do so we use
user_data = file("entry-script.sh")
so with terrafrom we can run command on ec2 at the time of creation

### Note

Ensure to follow the best practices mentioned in each section for an optimized and secure setup.

````

```

```
````

```

```

```

```
