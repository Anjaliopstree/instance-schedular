# output "ecs_subnet_ids" {
#   description = "Subnet IDs used by the ECS load balancer module"
#   value       = module.ecs-lb-fargate.subnet_ids
# }

# output "ecs_load_balancer_dns" {
#   description = "DNS name of the load balancer"
#   value       = module.ecs-lb-fargate.load_balancer_dns_name
# }

# output "ecs_cluster_arn" {
#   description = "ARN of the ECS cluster"
#   value       = module.ecs-lb-fargate.cluster_arn
# }


output "private_subnets" {
  value = data.aws_subnets.private.ids
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "alb_dns" {
  value = module.ecs-lb-fargate.load_balancer_dns_name
}

output "vpc_id" {
  value = module.ecs-lb-fargate.vpc_id
}

output "ecs_cluster_arn" {
  value = module.ecs-lb-fargate.ecs_cluster_arn
}

output "cloudwatch_log_group_name" {
  value = module.ecs-lb-fargate.cloudwatch_log_group_name
}

output "aws_dynamodb_table_arn" {
  value = module.ecs-lb-fargate.aws_dynamodb_table_arn
}
