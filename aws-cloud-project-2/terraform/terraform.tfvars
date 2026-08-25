//Providing the VPC-created-variables with values

aws_region = "eu-north-1"
vpc_cidr   = "10.0.0.0/16"


//Providing the Public Subnet created variables with values

public_subnet_cidr              = "10.0.1.0/24"
public_subnet_availability_zone = "eu-north-1a"


//Providing the Private Subnet created variables with values

private_subnet_cidr              = "10.0.2.0/24"
private_subnet_availability_zone = "eu-north-1a"


//Providing the EC2 created variables with values

instance_type = "t3.micro"
key_pair_name = "project-2-key-pair"