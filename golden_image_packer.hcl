packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Using a Rocky Linux AMI as the base
source "amazon-ebs" "rocky-linux" {
  region          = "ap-south-1"  # Mumbai region
  ami_name        = "rocky-ami-version-1-{{timestamp}}"
  instance_type   = "t2.micro"    # Instance type (can adjust as needed)
  source_ami      = "ami-0a1b1c2d3e4f5g6h7"  # Replace with the correct Rocky Linux AMI ID
  ssh_username    = "rocky"  # Default SSH username for Rocky Linux
  ami_regions     = [
    "ap-south-1"
  ]
}

# Build configuration to install, configure, and provision
build {
  name = "rocky-packer"
  sources = [
    "source.amazon-ebs.rocky-linux"
  ]

  # Copy the provisioner script to the instance
  provisioner "file" {
    source      = "provisioner.sh"   # Local script to copy
    destination = "/tmp/provisioner.sh"
  }

  # Change permissions to make the script executable
  provisioner "shell" {
    inline = ["chmod a+x /tmp/provisioner.sh"]
  }
  
  # Verify the presence of the provisioner script
  provisioner "shell" {
    inline = ["ls -la /tmp"]
  }
  
  # Show current working directory (for debugging)
  provisioner "shell" {
    inline = ["pwd"]
  }
  
  # Display the content of the provisioner script (optional for debugging)
  provisioner "shell" {
    inline = ["cat /tmp/provisioner.sh"]
  }

  # Execute the provisioner script
  provisioner "shell" {
    inline = ["/bin/bash -x /tmp/provisioner.sh"]
  }
}
