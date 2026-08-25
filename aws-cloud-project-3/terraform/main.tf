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


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "project-3-vpc"
  }
}


//Public Subnet A

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = var.public_subnet_availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name = "project-3-public-subnet-a"
  }
}


//Public Subnet B

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.public_subnet_availability_zone_b
  map_public_ip_on_launch = true

  tags = {
    Name = "project-3-public-subnet-b"
  }
}


//Private Subnet A

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = var.private_subnet_availability_zone_a

  tags = {
    Name = "project-3-private-subnet-a"
  }
}

//Private Subnet B

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = var.private_subnet_availability_zone_b

  tags = {
    Name = "project-3-private-subnet-b"
  }
}


//Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "project-3-internet-gateway"
  }
}


//Public Route Table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "project-3-public-route-table"
  }
}


//Connect the Public Subnet A with the Route Table

resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}


//Connect the Public Subnet B with the Route Table

resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}


//DB Subnet Group for the RDS

resource "aws_db_subnet_group" "main" {
  name = "project-3-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]

  tags = {
    Name = "project-3-db-subnet-group"
  }
}


//Security Group for EC2

resource "aws_security_group" "web_sg" {
  name        = "project-3-web-sg"
  description = "Allows HTTP traffic from the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP traffic"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-3-web-sg"
  }
}


//Security Group for the RDS

resource "aws_security_group" "rds_sg" {
  name        = "project-3-rds-sg"
  description = "Allows PostgreSQL traffic from the EC2 web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allows PostgreSQL from the EC2 security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    description = "Allow for all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-3-rds-sg"
  }
}


//PostgreSQL RDS Database
resource "aws_db_instance" "project_db" {
  identifier = "project-3-db"

  engine         = "postgres"
  engine_version = "17"

  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password


  //Places the RDS in the private subnet and forces the database to only recieve traffic from the rds-sg
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]


  //No public endpoint allowed
  publicly_accessible = false

  multi_az = false

  skip_final_snapshot = true

  tags = {
    Name = "project-3-rds"
  }
}


//Security Group for the Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "project-3-alb-sg"
  description = "Allows HTTP traffic"
  vpc_id      = aws_vpc.main.id

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
    Name = "project-3-alb-sg"
  }
}


// Application Load Balancer
resource "aws_lb" "application_lb" {
  name               = "project-3-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "project-3-alb"
  }
}


//Target Group for the EC2 Instances
resource "aws_lb_target_group" "web_target_group" {
  name     = "project-3-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "project-3-web-target-group"
  }
}

//HTTP Listener for the Load Balancer
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn

  }
}


//Secret for the RDS password
resource "aws_secretsmanager_secret" "db_password" {
  name = "project-3-db-password"

  tags = {
    Name = "project-3-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}


//IAM Role, allows EC2 to use this role
resource "aws_iam_role" "ec2_role" {
  name = "project-3-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

//Makes EC2 able to access the previously created secret
resource "aws_iam_role_policy" "secret_access" {
  name = "project-3-secret-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_secretsmanager_secret.db_password.arn
      }
    ]
  })
}

//Instance Profile, for providing the EC2 resource with the opportunity to interact with IAM roles
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "project-3-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

// Allows EC2 instances to use AWS Systems Manager
resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


//Launch template for EC2 Instances
resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "project-3-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
set -euxo pipefail

# Install Apache, Python and pip
dnf install -y httpd python3 python3-pip

# Install Python packages
python3 -m pip install flask boto3 psycopg2-binary

# Create directory for the Flask application
mkdir -p /opt/project3

# Create Flask application
cat > /opt/project3/app.py <<'PYTHON'
from flask import Flask
import boto3
import psycopg2
import socket

app = Flask(__name__)


def get_db_password():
    client = boto3.client(
        "secretsmanager",
        region_name="${var.aws_region}"
    )

    response = client.get_secret_value(
        SecretId="${aws_secretsmanager_secret.db_password.name}"
    )

    return response["SecretString"]


DB_PASSWORD = get_db_password()


@app.route("/")
def home():
    conn = psycopg2.connect(
        host="${aws_db_instance.project_db.address}",
        port=5432,
        database="${var.db_name}",
        user="${var.db_username}",
        password=DB_PASSWORD
    )

    cursor = conn.cursor()
    cursor.execute("SELECT name FROM servers WHERE id = 1;")
    row = cursor.fetchone()

    cursor.close()
    conn.close()

    hostname = socket.gethostname()

    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS Terraform Project 3</title>
</head>

<body>
    <h1>AWS Terraform Project 3</h1>

    <p>Data retrieved from Amazon RDS:</p>
    <h2>{row[0]}</h2>

    <p>Hostname: {hostname}</p>

    <p>
        Database credentials retrieved securely
        from AWS Secrets Manager.
    </p>
</body>
</html>
"""


app.run(
    host="127.0.0.1",
    port=8080
)
PYTHON

# Create systemd service for Flask
cat > /etc/systemd/system/project3-flask.service <<'SERVICE'
[Unit]
Description=Project 3 Flask Application
After=network.target

[Service]
User=root
WorkingDirectory=/opt/project3
ExecStart=/usr/bin/python3 /opt/project3/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

# Configure Apache as reverse proxy to Flask
cat > /etc/httpd/conf.d/flask-proxy.conf <<'APACHE'
ProxyPreserveHost On
ProxyPass / http://127.0.0.1:8080/
ProxyPassReverse / http://127.0.0.1:8080/
APACHE

# Start Flask
systemctl daemon-reload
systemctl enable --now project3-flask

# Start Apache
systemctl enable --now httpd

EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "project-3-web-server"
    }
  }
}

//Auto Scaling Group for the web servers

resource "aws_autoscaling_group" "web_asg" {
  name = "project-3-web-asg"

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size

  vpc_zone_identifier = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]

  target_group_arns = [
    aws_lb_target_group.web_target_group.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "project-3-web-server"
    propagate_at_launch = true
  }
}


//Scaling policy based on average CPU usage
resource "aws_autoscaling_policy" "cpu_scaling_policy" {
  name                   = "project-3-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.cpu_target_value
  }
}