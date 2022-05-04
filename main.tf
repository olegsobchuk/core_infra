data "aws_ami" "web" {
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

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"
  # enable_dns_support = true # default `true`
  enable_dns_hostnames = true # default `false`

  tags = {
    Name = "main"
  }
}

# # PRIVATE INSTANCE
# resource "aws_instance" "private" {
#   count         = 1
#   ami           = data.aws_ami.web.id
#   instance_type = var.min_instance_type

#   associate_public_ip_address = false

#   tags= {
#     Name       = "Private"
#   }
# }

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.16.10.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "CustomMain"
  }
}

resource "aws_network_interface" "main" {
  subnet_id   = aws_subnet.main.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "CustomMain"
  }
}

resource "aws_subnet" "main2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.16.11.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "CustomMain2"
  }
}

resource "aws_network_interface" "main2" {
  subnet_id   = aws_subnet.main2.id
  private_ips = ["172.16.11.100"]

  tags = {
    Name = "CustomMain2"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "RouteMain"
  }
}

resource "aws_eip" "main" {
  # instance = aws_instance.main.id
  network_interface = aws_network_interface.main2.id
  vpc      = true
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.web.id
  instance_type = var.min_instance_type
  # associate_public_ip_address = false

  network_interface {
    network_interface_id = aws_network_interface.main.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.main2.id
    device_index         = 0
  }

  tags = {
    Name = "CustomMain"
  }
}

# PUBLIC INSTANCE
resource "aws_instance" "web" {
  count         = 1
  ami           = data.aws_ami.web.id
  instance_type = var.min_instance_type
  key_name  = aws_key_pair.deploy.key_name
  user_data = file("user_data.sh")

  depends_on = [
    aws_security_group.allow_http_s,
    aws_security_group.allow_tcp,
  ]

  lifecycle {
    create_before_destroy = true
  }

  vpc_security_group_ids = [
    aws_security_group.allow_web.id,
    aws_security_group.allow_tcp.id,
  ]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.deploy_key.private_key_pem  # ".ssh/id_rsa" # file(local_file.private_key)
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install mc nginx libpq-dev -y",
    ]
  }

  provisioner "file" {
    source      = "user_data.sh"
    destination = "user_data.sh"
  }

  tags = {
    Name        = "TestAppService"
    Owner       = "OlehSobchuk"
    Environment = "dev"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_HTTP_S"
  description = "Allow HTTP(S) inbound traffic"
  # vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_tcp" {
  name        = "allow_tcp"
  description = "Allow TCP inbound traffic"
  # vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    prefix_list_ids = []
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] /* Allow from ANY IP */
  }
}

resource "random_uuid" "uuid" {}

resource "aws_s3_bucket" "deploy_bucket" {
  bucket = "deploy-bucket-${random_uuid.uuid.result}"
  acl    = "public-read" # "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_secret.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "Deploy bucket"
    Environment = "dev"
  }
}

resource "aws_kms_key" "kms_secret" {
  description             = "KMS key"
  deletion_window_in_days = 7
}
