# provider "aws" {
#   region = "us-east-2"
# }

# # Resource block for creation of VPC
# resource "aws_vpc" "vpc" {
#   cidr_block                           = var.cidr_block
#   enable_dns_hostnames                 = true
#   enable_dns_support                   = true
#   instance_tenancy                     = var.instance_tenancy
#   enable_network_address_usage_metrics = var.enable_network_address_usage_metrics
#   tags = merge(
#     { "Name" = format("%s-vpc", var.name) },
#     var.tags,
#     var.vpc_tags
#   )
# }

# # Resource block for internet gateway setup
# resource "aws_internet_gateway" "igw" {
#   count  = var.create_igw ? 1 : 0
#   vpc_id = aws_vpc.vpc.id
#   tags = merge(
#     { "Name" = format("%s-igw", var.name) },
#     var.tags
#   )
# }

# # Public route table creation (based on create_public_route_table)
# resource "aws_route_table" "public_route_table" {
#   count  = var.create_public_route_table ? 1 : 0
#   vpc_id = aws_vpc.vpc.id
#   tags = merge(
#     { "Name" = format("%s-public-rt", var.name) },
#     var.tags
#   )
# }

# # Default route for public route table (if public route table exists)
# resource "aws_route" "default_public_route" {
#   count                   = var.create_igw && var.create_public_route_table ? 1 : 0
#   route_table_id         = aws_route_table.public_route_table[0].id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw[0].id
# }

# # Updating main route table to public route table (based on create_public_route_table)
# resource "aws_main_route_table_association" "default_public_route" {
#   count          = var.create_public_route_table ? 1 : 0
#   route_table_id = aws_route_table.public_route_table[0].id
#   vpc_id         = aws_vpc.vpc.id
# }


# # Public Subnets creation (based on create_private_subnets)
# resource "aws_subnet" "public_subnet" {
#   count                   = var.create_public_subnets ? length(var.public_subnets) : 0
#   vpc_id                  = aws_vpc.vpc.id
#   availability_zone       = element(var.azs, count.index)
#   cidr_block              = var.public_subnets[count.index]
#   map_public_ip_on_launch = true
#   tags = merge(
#     { "Name" = format("${var.name}-public-%s", element(var.azs, count.index)) },
#     var.tags,
#     var.public_subnets_tags
#   )
# }

# # Private Subnets creation (based on create_private_subnets)
# resource "aws_subnet" "private_subnet" {
#   count                   = var.create_private_subnets ? length(var.private_subnets) : 0
#   vpc_id                  = aws_vpc.vpc.id
#   availability_zone       = element(var.azs, count.index)
#   cidr_block              = var.private_subnets[count.index]
#   map_public_ip_on_launch = true
#   tags = merge(
#     { "Name" = format("${var.name}-private-%s", element(var.azs, count.index)) },
#     var.tags,
#     var.private_subnets_tags
#   )
# }

# # Private route table creation (based on create_private_route_table)
# resource "aws_route_table" "private_route_table" {
#   count  = var.create_private_route_table ? length(var.azs) : 0
#   vpc_id = aws_vpc.vpc.id
#   tags = merge(
#     { "Name" = format("%s-private-rt-%s", var.name, element(var.azs, count.index)) },
#     var.tags
#   )
# }

# # Private route table association (based on create_private_route_table)
# resource "aws_route_table_association" "private_route_table_association" {
#   count          = var.create_private_route_table && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
#   subnet_id      = aws_subnet.private_subnet[count.index].id
#   route_table_id = aws_route_table.private_route_table[0].id
# }

# # Nat gateway elastic ip (condition on create_nacl)
# resource "aws_eip" "nat" {
#   count  = var.create_nacl && var.create_nat_gateway ? length(var.azs) : 0
#   domain = "vpc"

#   tags = merge(
#     { "Name" = format("%s-eip-%s", var.name, element(var.azs, count.index)) },
#     var.tags
#   )

#   depends_on = [aws_internet_gateway.igw]
# }

# # NAT Gateway Creation (condition on create_nacl)
# resource "aws_nat_gateway" "nat_gateway" {
#   count         = var.create_nat_gateway && length(aws_subnet.public_subnet) > 0 ? 1 : 0
#   subnet_id     = aws_subnet.public_subnet[0].id
#   allocation_id = aws_eip.nat[count.index].id

#   tags = merge(
#     { "Name" = format("%s-nat-%s", var.name, element(var.azs, count.index)) },
#     var.tags
#   )

#   depends_on = [aws_internet_gateway.igw]
# }

#-----------------------------------------------------
# Create IAM role for ECS
data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}


# Attach AWS managed execution role policy
resource "aws_iam_role_policy_attachment" "execution_attach" {
  role       = data.aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------------------
# IAM Policy + Role for Scheduler
# ---------------------------
resource "aws_iam_policy" "instance_scheduler_policy" {
  name        = "InstanceSchedulerAppPolicy_v2"
  description = "Policy for Instance Scheduler application"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:UpdateItem", "dynamodb:DeleteItem"
        ],
        Resource = [aws_dynamodb_table.config_table.arn]
      },
      {
        Effect = "Allow",
        Action = ["ec2:DescribeInstances", "ec2:CreateTags", "ec2:DeleteTags"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "instance_scheduler_temp_role" {
  name = "InstanceSchedulerTempRole_v2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { AWS = "arn:aws:iam::370389955750:user/Mehul" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "instance_scheduler_attachment" {
  role       = aws_iam_role.instance_scheduler_temp_role.name
  policy_arn = aws_iam_policy.instance_scheduler_policy.arn
}
# ---------------------------
# DynamoDB Table
# ---------------------------
resource "aws_dynamodb_table" "config_table" {
  name         = "instance-scheduler-ConfigTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "name"

  attribute {
    name = "id"
    type = "S"
  }
  
  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "start_time"
    type = "S"
  }

  attribute {
    name = "stop_time"
    type = "S"
  }

  attribute {
    name = "time_zone"
    type = "S"
  }


  attribute {
    name = "initiate_date"
    type = "S"
  }

  attribute {
    name = "end_date"
    type = "S"
  }

  attribute {
    name = "frequency"
    type = "S"
  }

  attribute {
    name = "week_days"
    type = "S"
  }

  attribute {
    name = "dates"
    type = "S"
  }

  global_secondary_index {
    name = "startTimeIndex"
    hash_key = "start_time"
    projection_type = "ALL"
  }

 global_secondary_index {
    name            = "stopTimeIndex"
    hash_key        = "stop_time"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "timeZoneIndex"
    hash_key        = "time_zone"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "initiateDateIndex"
    hash_key        = "initiate_date"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "endDateIndex"
    hash_key        = "end_date"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "frequencyIndex"
    hash_key        = "frequency"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "weekDaysIndex"
    hash_key        = "week_days"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "DaysIndex"
    hash_key        = "dates"
    projection_type = "ALL"
  }

}

# ECS Cluster
resource "aws_ecs_cluster" "instance_schedular" {
  name = "instance-schedular-fargate-ec2"
}

# Load Balancer
resource "aws_lb" "ecs_alb" {
  name               = "fargate-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.fargate_lb_sg.id]
  subnets            = var.subnet_id
  enable_deletion_protection = false
}

# Target Group for Fargate (must use target_type = "ip")
resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for awsvpc mode

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Listener
resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# Security Group for ALB
resource "aws_security_group" "fargate_lb_sg" {
  name        = "ecs-lb-sg-fargate"
  description = "Allow HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs-task-sg"
  description = "Allow traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.fargate_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# creating Cloud watch for ecs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  count = var.create_cloudwatch_log_group ? 1 : 0
  name  = "/ecs/fargate-task"
  retention_in_days = 7
}


# Task Definition
resource "aws_ecs_task_definition" "web" {
  family                   = "fargate-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "web-app"
      image = "public.ecr.aws/nginx/nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
        logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecs_logs[0].name : "/ecs/fargate-task"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }

    }
  ])
}

# ECS Service
resource "aws_ecs_service" "web" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.instance_schedular.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_id
    security_groups = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "web-app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.ecs_listener]
}

resource "aws_lb_target_group_attachment" "fargate_target_ip" {
  target_group_arn = aws_lb_target_group.ecs_tg.arn
  target_id        = "10.1.12.34" 
  port             = 80
}
