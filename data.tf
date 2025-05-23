data "aws_vpc" "fetch-vpc" {
  filter {
    name   = "tag:Name"
    values = ["fargate-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.fetch-vpc.id]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Tier"
    values = ["application"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.fetch-vpc.id]
  }
}
