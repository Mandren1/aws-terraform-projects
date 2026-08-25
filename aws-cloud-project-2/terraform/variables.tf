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

variable "public_subnet_cidr" {
  description = "CIDR block for the Public Subnet"
  type        = string
}

variable "public_subnet_availability_zone" {
  description = "The Availability Zone for the Public Subnet"
  type        = string
}


//Creation of Private Subnet variables that will be used

variable "private_subnet_cidr" {
  description = "CIDR block for the Private Subnet"
  type        = string
}

variable "private_subnet_availability_zone" {
  description = "The Availability Zone for the Private Subnet"
  type        = string
}


////Creation of EC2 variables that will be used

variable "instance_type" {
  description = "An EC2 instance type"
  type        = string
}

variable "key_pair_name" {
  description = "Existing AWS key pair"
  type        = string
}