//Creation of VPC variables that will be used

variable "aws_region" {
  description = "AWS region where the infrastructure will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}


//Creation of Public Subnet variables that will be used

variable "public_subnet_cidr_a" {
  description = "CIDR block for Public Subnet A"
  type        = string
}

variable "public_subnet_availability_zone_a" {
  description = "The Availability Zone for Public Subnet A"
  type        = string
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for Public Subnet B"
  type        = string
}

variable "public_subnet_availability_zone_b" {
  description = "The Availability Zone for Public Subnet B"
  type        = string
}


//Creation of Private Subnet variables that will be used

variable "private_subnet_cidr_a" {
  description = "CIDR block for Private Subnet A"
  type        = string
}

variable "private_subnet_availability_zone_a" {
  description = "The Availability Zone for Private Subnet A"
  type        = string
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for Private Subnet B"
  type        = string
}

variable "private_subnet_availability_zone_b" {
  description = "The Availability Zone for Private Subnet B"
  type        = string
}


//Creation of database variables that will be used (Password will be created through powershell due to saftey reasons)

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Master database username"
  type        = string
}

variable "db_password" {
  description = "Password for the master database"
  type        = string
  sensitive   = true
}


//Auto Scaling Group & Policy variables that will be used

variable "asg_min_size" {
  description = "Minimum number of EC2 instances"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = string
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances"
  type        = string
}

variable "cpu_target_value" {
  description = "The targeted average CPU utilization for Auto Scaling"
  type        = number
}

//Launch Template variables that will be used

variable "instance_type" {
  description = "EC2 instance type that will be used by the Auto Scaling Group"
  type        = string
}

