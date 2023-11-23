# Demo Terraform Project 👷‍♂️

## USER_DATA vs PROVISIONER

In this branch (feature/provisioners), we will delve into the use of provisioners.

### USER_DATA 🚀

Let's begin by understanding how commands are executed when using `user_data`. `user_data` is an attribute called within the EC2 instance resource. Commands specified in `user_data` are executed by AWS during instance creation. However, Terraform has limited control over the execution, and if a command, such as `docker run`, encounters issues like improper Docker installation or permission errors, Terraform remains unaware of the problem until manually inspected through SSH.

This is where "Provisioners" come into play.

### PROVISIONER 🛠️

Provisioners enable executing commands from within Terraform, providing better control over the process.

Let's break down the structure of a provisioner:

1. **Connection:**
   The connection block is specific to provisioners and enables Terraform to connect to the server using SSH. This is crucial for executing provisioner commands.

   ```bash
   connection {
     type        = "ssh"
     host        = self.public_ip
     user        = "ec2-user"
     private_key = file(var.private_key)
   }
   ```

2. **File Provisioner:**
   The `file` provisioner copies files or directories from local to the newly created instances. Specify the source and destination paths.

   ```bash
   provisioner "file" {
     source      = "entry-script.sh"
     destination = "/home/ec2-user/entry-script.sh"
   }
   ```

3. **Remote-Exec Provisioner:**
   The `remote-exec` provisioner invokes a script on the remote resource after it is created. Specify the script file on the server.

   ```bash
   provisioner "remote-exec" {
     script = file("entry-script.sh")
   }
   ```

4. **Local-Exec Provisioner:**
   The `local-exec` provisioner invokes a local executable after a resource is created, executing commands locally.

   ```bash
   provisioner "local-exec" {
     command = "echo ${self.public.ip}> output.txt"
   }
   ```

## SUM UP ☑️

- **USER_DATA:** Passing data to AWS.
- **Remote-Exec:** Connects via SSH using Terraform.

### CONCLUSION 🤔

Provisioners are not recommended by Terraform due to:

- Prefer `user_data` when available.
- Breaks idempotency concept.
- Terraform lacks knowledge of executed scripts.
- Disrupts current-desired state comparison.

### Alternatives to Remote-Exec:

- Use configuration management tools (e.g., Ansible).
- Hand over to these tools after provisioning.

### Alternative to Local-Exec:

- Use the "local" provider.

### Other Alternatives:

- Execute scripts separately from Terraform.
- Utilize CI/CD tools.

### Provisioner Failure ❌

If a provisioner fails, the resource is marked as failed, even if the EC2 instance is created. For instance, an error in copying a script to the remote machine can lead to resource deletion. Exercise caution, and test scenarios like changing the remote file name to understand the implications.

# More details

**- Breaks idempotency concept.**

Suppose you have a Terraform configuration that creates an EC2 instance with the following user_data:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  EOF
}
```

In this example:

First Apply:

You run terraform apply, and an EC2 instance is created with Nginx installed.
The user_data script is executed during instance launch, updating the instance to the desired state.
Subsequent Applies:

If you run terraform apply again, Terraform checks the current state against the desired state.
The user_data script is designed to be idempotent; it checks if Nginx is already installed before attempting to install it again.
Since Nginx is already installed, Terraform determines that no changes are needed, and the instance remains in the desired state.
Example with Provisioners:

Now, let's consider a similar scenario with provisioners:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y nginx",
    ]
  }
}
```

In this example:

First Apply:

You run terraform apply, and an EC2 instance is created.
The remote-exec provisioner runs commands to update and install Nginx.
Subsequent Applies:

If you run terraform apply again, Terraform checks the current state against the desired state.
The remote-exec provisioner runs the same commands again, attempting to update and reinstall Nginx.
However, the remote-exec provisioner might not inherently check whether Nginx is already installed, potentially causing the instance to drift from the desired state.

Conclusion:

The key difference lies in the logic within the scripts. Scripts within user_data can be designed to check and only make changes if necessary, ensuring idempotency.

Provisioners, depending on their design, may lack built-in mechanisms to check and may attempt to reapply changes on every run, potentially causing non-idempotent behavior.

However, keep in mind that the idempotency of user_data depends on how the script within it is written. If the script itself is not idempotent, meaning it makes changes every time it runs regardless of the current state, let's consider an example where the script within user_data is not idempotent, meaning it makes changes every time it runs regardless of the current state. In this example, the script could be designed to always append a line to a file:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    echo "Some unique line" >> /var/log/example.log
  EOF
}
```

In this case:

First Apply:

You run terraform apply, and an EC2 instance is created.
The user_data script appends a line to the /var/log/example.log file.
Subsequent Applies:

If you run terraform apply again, Terraform checks the current state against the desired state.
The user_data script always appends the same line to the file, regardless of whether it's already there.
As a result, every apply will append the same line again, causing a change in the state. This behavior is non-idempotent because the script doesn't check if the change it intends to make has already been made. It appends the line regardless of the current state, leading to repeated and unnecessary changes on each apply.

**- Terraform Lacks Knowledge of Executed Scripts:**

When using provisioners, Terraform itself lacks detailed awareness of what happens inside the scripts executed on the remote machine. This lack of knowledge can lead to several challenges:

Limited Error Handling: If a script encounters an error during

execution, Terraform may not be immediately aware of it. This can result in incomplete or incorrect configurations that may go unnoticed until manual inspection.

Difficulty in Troubleshooting: Debugging becomes more challenging because Terraform doesn't have real-time visibility into the script execution. Users may need to log into the machine manually to diagnose and fix issues.

**- Disrupts the Current-Desired State Comparison**

Terraform relies on the concept of the current state and the desired state. The current state is the actual state of the infrastructure, while the desired state is defined in the Terraform configuration. Terraform aims to make the current state match the desired state.

Provisioners can disrupt this comparison in the following ways:

Uncertain Completion Timing: Provisioners execute after the resource is created, but the timing can be uncertain. Terraform may proceed to the next resource or step before the provisioner completes, leading to a mismatch between current and desired states.

Unpredictable Changes: The changes made by provisioners may not be easily predictable or reflected immediately in Terraform's understanding of the state. This can lead to inconsistencies when trying to understand what Terraform perceives as the current state.
