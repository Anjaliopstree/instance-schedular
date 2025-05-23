# output "vpc_id" {
#   description = "The ID of the VPC"
#   value       = aws_vpc.vpc.id
# }

# output "vpc_cidr_block" {
#   description = "The CIDR block of the VPC"
#   value       = aws_vpc.vpc.cidr_block
# }

# output "igw_id" {
#   value = length(aws_internet_gateway.igw) > 0 ? aws_internet_gateway.igw[0].id : null
#   description = "The ID of the Internet Gateway"
# }


# output "public_route_table_id" {
#   value = length(aws_route_table.public_route_table) > 0 ? aws_route_table.public_route_table[0].id : null
#   description = "The ID of the public route table"
# }


# output "public_subnets" {
#   description = "List of IDs of public subnets"
#   value       = aws_subnet.public_subnet[*].id
# }

# output "public_subnets_cidr_blocks" {
#   description = "List of CIDR blocks of public subnets"
#   value       = compact(aws_subnet.public_subnet[*].cidr_block)
# }

# output "private_subnets" {
#   description = "List of IDs of private subnets"
#   value       = aws_subnet.private_subnet[*].id
# }

# output "private_subnets_cidr_blocks" {
#   description = "List of CIDR blocks of private subnets"
#   value       = compact(aws_subnet.private_subnet[*].cidr_block)
# }

# output "private_route_table_id" {
#   description = "The ID of the private route table"
#   value       = aws_route_table.private_route_table[*].id
# }

# output "nat_gateway_ips" {
#   description = "List of NAT Gateway IPs"
#   value       = aws_eip.nat[*].public_ip
# }

# output "nat_gateway_id" {
#   description = "List of IDs of NAT Gateways"
#   value       = aws_nat_gateway.nat_gateway[*].id
# }

output "load_balancer_dns_name" {
  value = aws_lb.ecs_alb.dns_name
}

output "vpc_id" {
  value = var.vpc_id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.instance_schedular.arn
}

output "cloudwatch_log_group_name" {
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecs_logs[0].name : null
  description = "Name of the created CloudWatch log group"
}

output "aws_dynamodb_table_arn" {
  value = aws_dynamodb_table.config_table.arn
}
