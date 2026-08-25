output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.application_lb.dns_name
}

output "website_url" {
  description = "URL:"
  value       = "http://${aws_lb.application_lb.dns_name}"
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "target_group_arn" {
  description = "ARN of the web Target Group"
  value       = aws_lb_target_group.web_target_group.arn
}

output "private_subnet_a_id" {
  description = "ID of Private Subnet A"
  value       = aws_subnet.private_subnet_a.id
}

output "private_subnet_b_id" {
  description = "ID of Private Subnet B"
  value       = aws_subnet.private_subnet_b.id
}

output "rds_endpoint" {
  description = "Endpoint of the PostgreSQL database"
  value       = aws_db_instance.project_db.endpoint
}