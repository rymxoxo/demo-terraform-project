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

### Note

Ensure to follow the best practices mentioned in each section for an optimized and secure setup.
