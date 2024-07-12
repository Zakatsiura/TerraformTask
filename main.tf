provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

locals {
  name_prefix = "${var.project_name}-${var.environment_name}"
  common_tags = {
    Managed_by  = "terraform"
    Project     = var.project_name
    Environment = var.environment_name
  }
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.10.0.0/16"

  tags = merge({
    Name = "${local.name_prefix}-vpc"
  }, local.common_tags)
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.subnet_zones)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = lookup(var.subnets_cidr, var.subnet_zones[count.index])
  availability_zone       = var.subnet_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${local.name_prefix}-${var.subnet_zones[count.index]}-public-subnet"
  }, local.common_tags)
}

resource "aws_internet_gateway" "main_ig" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge({
    Name = "${local.name_prefix}-ig"
  }, local.common_tags)
}

resource "aws_route_table" "main_ig_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_ig.id
  }

  tags = merge({
    Name = "${local.name_prefix}-rt"
  }, local.common_tags)
}

resource "aws_route_table_association" "main_rta" {
  count          = length(var.subnet_zones)
  route_table_id = aws_route_table.main_ig_rt.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${local.name_prefix}-sg"
  }, local.common_tags)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }
}

resource "aws_instance" "example" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  monitoring    = var.monitoring

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  root_block_device {
    volume_size = var.root_block_device_size
    volume_type = "gp2"
  }

  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = var.ebs_size
    volume_type = "gp2"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1.12 -y
    systemctl start nginx
    systemctl enable nginx
    EOF

  vpc_security_group_ids = [aws_security_group.main_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id

  tags = merge({
    Name = "${local.name_prefix}-instance",
    Owner = var.environment_owner,
  }, local.common_tags)

  lifecycle {
    create_before_destroy = true

    postcondition {
      condition     = can(regex("^${local.name_prefix}-instance$", self.tags["Name"]))
      error_message = "Instance name does not follow the naming convention with prefix '${local.name_prefix}'"
    }

    postcondition {
      condition     = var.monitoring == true
      error_message = "Monitoring must be enabled."
    }

    postcondition {
      condition     = self.tags["Owner"] != ""
      error_message = "Instance must have an 'Owner' tag."
    }
  }
}



check "nginx_health_check" {
  data "http" "nginx_check" {
    url = "http://${aws_instance.example.public_ip}"
  }

  assert {
    condition     = data.http.nginx_check.status_code == 200
    error_message = "Nginx on http://${aws_instance.example.public_ip} did not return HTTP 200"
  }
}