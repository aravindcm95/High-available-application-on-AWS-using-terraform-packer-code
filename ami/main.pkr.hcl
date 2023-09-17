packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "linux" {
  source_ami    = var.ami
  ami_name      = local.image-name
  instance_type = "t2.micro"
  region        = var.region
  ssh_username  = "ec2-user"
  tags = {
    Name        = local.image-name
    project     = var.project
    enviornment = var.env
  }
}

build {
  sources = [
    "source.amazon-ebs.linux"
  ]
  provisioner "shell" {
    script          = "./script.sh"
    execute_command = "sudo  {{.Path}}"
  }
}