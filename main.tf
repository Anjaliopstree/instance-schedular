module "ecs-lb-fargate" {
  source    = "./module"
  azs       = var.azs
  vpc_id    = data.aws_vpc.fetch-vpc.id
  subnet_id = var.subnet_id
 # subnet_id = concat(data.aws_subnets.public.ids, [data.aws_subnets.private.ids[0]])
}
