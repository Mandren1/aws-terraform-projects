terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "project-2-vpc"
  }
}

//Public Subnet 

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "project-2-public-subnet"
  }
}

//Private Subnet

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_subnet_availability_zone

  tags = {
    Name = "project-2-private-subnet"
  }
}

//Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "project-2-internet-gateway"
  }
}

//Route Table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "project-2-public-route-table"
  }
}

//Connect the Public Subnet with the Route Table

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


//Security Group

resource "aws_security_group" "web_sg" {
  name        = "project-2-web-sg"
  description = "Allows HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-2-web-sg"
  }
}


//Gather the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


//EC2 Web Server

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id //Collects the ID for the latest AMI
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id    //Places my EC2 in the public subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id] //Connects my firewall to the EC2 Web Server instance
  key_name               = var.key_pair_name              //Uses the Key Pair I created in AWS Console

  // Script that automatically runs the first time the EC2 instance is launched
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd

    systemctl enable httpd
    systemctl start httpd

    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>AWS Terraform Project 2</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: #f4f6f8;
          margin: 0;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
        }

        .card {
          background: white;
          padding: 40px;
          border-radius: 12px;
          border-top: 6px solid #FF9900;
          box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
          max-width: 650px;
          width: 90%;
        }

        h1 {
          margin-top: 0;
          color: #FF9900;
        }

        h2 {
          color: #FF9900;
        }

        li {
          margin: 10px 0;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>AWS Terraform Project 2</h1>
        <p>This web server was deployed with Terraform.</p>

        <h2>Created infrastructure:</h2>
        <ul>
          <li>Custom VPC</li>
          <li>Public and private subnets</li>
          <li>Internet Gateway</li>
          <li>Route tables</li>
          <li>Security Group</li>
          <li>Amazon EC2</li>
        </ul>

        <p><strong>Created by Martin</strong></p>
      </div>
    </body>
    </html>
    HTML
  EOF

  tags = {
    Name = "project-2-web-server"
  }
}