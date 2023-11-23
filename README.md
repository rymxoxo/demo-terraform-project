**HELLO** 🌟

Welcome to the demo project! In this branch, we'll explore the essential modules. Let's dive in:

1. **Without Modules:**

   - Complex configuration
   - Huge file
   - No overview

2. **What is a Module?**
   A module is a container for multiple resources used together. Think of it like a function. Customize the configuration with variables:

   - Input variables: Similar to arguments
   - Output values: Resemble function return values

3. **Why Modules?**

   - Organize and group configurations
   - Encapsulate into distinct logical components
   - Re-use

   * Create our modules OR
   * Use existing modules created by Terraform or other companies
     - To be reused
     - For different technologies/cloud providers

## Modularize Our Project

It's a bad practice to have many resources/code in just one `main.tf` file. It lacks overview.

## Project Structure

- `main.tf`
- `variables.tf`
- `outputs.tf`
- `providers.tf`

The GOOD thing is that we don't have to link these files together because Terraform knows they belong together.

**1. Create Module**

- Root module
- `/modules` = "child modules" (a module called by another config)

### Subnet Module

This module comprises 3 resources:

- Subnet
- Internet Gateway
- Default Route Table + Association

Remember to change everything not called in `main.tf` inside this module, e.g., update `vpc_id`:

```bash
vpc_id = var.vpc_id
```

Every associated variable should be declared in the `variables.tf` of this module.

**2. Use the Module Now:**

In `main.tf`:

```bash
module "demo-app-subnet-module" {
  source                 = "./modules/subnet"
  subnet_cidr_block      = var.subnet_cidr_block
  avail_zone             = var.avail_zone
  env_prefix             = var.env_prefix
  vpc_id                 = aws_vpc.demo-app-vpc.id
  default_route_table_id = aws_vpc.demo-app-vpc.default_route_table_id
}
```

You can choose any name for your module, e.g., "demo-app-subnet-module".

### Webserver Module

This module includes:

- Default Security Group
- AWS AMI
- AWS Key Pair
- AWS Instance

Don't forget to set `vpc_id` and `subnet_id`.

**How Do We Access the Resource of a Child?**
Use output values to expose or export resource attributes to the parent module for use by other modules.

In every module (subnet or webserver), we have a file named `outputs.tf`. For example:

```bash
output "subnet" {
  value = aws_subnet.demo-app-subnet-1
}
```

or

```bash
output "ec2-instance" {
  value = aws_instance.demo-app-server
}
```

Now, the module can be accessed by its name, "subnet" or "ec2-instance".

**How to Refer to a Module?**
`subnet_id = module.demo-app-subnet-module.subnet.id`

[![Profile Views](https://visitcount.itsvg.in/api?id=moduleTF&label=Profile%20Views&color=11&icon=5&pretty=true)](https://visitcount.itsvg.in)
