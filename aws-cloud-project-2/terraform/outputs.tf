//VPC output
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}


//Public Subnet output

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}


//Private Subnet output

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}


//Internet Gateway

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.main.id
}


//Security Group

output "security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web_sg.id
}


//EC2

output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "URL of the web server"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "amazon_linux_ami_id" {
  description = "Amazon Linux 2023 AMI selected by Terraform"
  value       = data.aws_ami.amazon_linux.id
}