resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = false # default `false`

  tags = {
    Name = "main"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "s3_storage" {
  source = "./modules/storage"

  region = var.region
}

module "private_instance" {
  source = "./modules/instance"

  region        = var.region
  instance_type = var.min_instance_type
  ami_id        = data.aws_ami.ubuntu.id
  vpc_id        = aws_vpc.main.id
  is_public_ip  = false

  depends_on = [

  ]
}
