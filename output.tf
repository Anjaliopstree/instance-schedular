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
