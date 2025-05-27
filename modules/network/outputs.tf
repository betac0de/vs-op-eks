output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses of the NAT Gateways."
  value       = [aws_eip.nat.public_ip] # For single NAT
  # For multiple NATs: aws_eip.nat[*].public_ip
}