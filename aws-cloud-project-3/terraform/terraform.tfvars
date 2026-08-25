//Providing the VPC-created-variables with values

aws_region = "eu-north-1"
vpc_cidr   = "10.0.0.0/16"


//Providing the Public Subnet A created variables with values

public_subnet_cidr_a              = "10.0.1.0/24"
public_subnet_availability_zone_a = "eu-north-1a"

//Providing the Public Subnet B created variables with values

public_subnet_cidr_b              = "10.0.2.0/24"
public_subnet_availability_zone_b = "eu-north-1b"


//Providing the Private Subnet A created variables with values

private_subnet_cidr_a              = "10.0.3.0/24"
private_subnet_availability_zone_a = "eu-north-1a"

//Providing the Private Subnet B created variables with values

private_subnet_cidr_b              = "10.0.4.0/24"
private_subnet_availability_zone_b = "eu-north-1b"


//Providing the RDS created variables with values

db_instance_class = "db.t3.micro"
db_name           = "project3db"
db_username       = "project3user"


//Providing the Auto Scaling Group & Policy with values

asg_min_size         = 2
asg_desired_capacity = 2
asg_max_size         = 4
cpu_target_value     = 50


//Providing the launch template created variables with values
instance_type = "t3.micro"
