# # Flags for resource creation
# variable "create_igw" {
#   description = "Whether to create an Internet Gateway"
#   type        = bool
# }

# variable "create_nat_gateway" {
#   description = "Whether to create NAT Gateways"
#   type        = bool
# }

# variable "create_database_subnets" {
#   description = "Whether to create database subnets"
#   type        = bool
# }

# variable "create_public_subnets" {
#   description = "Whether to create public subnets"
#   type        = bool
# }

# variable "create_private_subnets" {
#   description = "Whether to create private subnets"
#   type        = bool
# }

# variable "create_public_route_table" {
#   description = "Whether to create public route table"
#   type        = bool
# }

# variable "create_private_route_table" {
#   description = "Whether to create private route table"
#   type        = bool
# }

# variable "create_nacl" {
#   description = "Whether to create Network ACLs"
#   type        = bool

# }

# variable "create_route53" {
#   description = "Whether to create private Route53 zone"
#   type        = bool
# }


# ####################### VPC variables #####################
variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  validation {
    condition     = length(var.azs) > 0
    error_message = "You must provide at least one AZ."
  }
}

# variable "cidr_block" {
#   description = "The IPv4 CIDR block for the VPC."
#   type        = string
#   default     = "10.0.0.0/16"
# }

# variable "instance_tenancy" {
#   description = "A tenancy option for instances launched into the VPC"
#   type        = string
#   default     = "default"
# }

# variable "enable_network_address_usage_metrics" {
#   description = "Determines whether network address usage metrics are enabled for the VPC"
#   type        = bool
#   default     = false
# }

# variable "name" {
#   description = "Name to be used on all the resources as identifier"
#   type        = string
# }


# variable "tags" {
#   description = "A map of tags to add to all resources"
#   type        = map(string)
#   default     = {}
# }

# variable "vpc_tags" {
#   description = "Additional tags for the VPC"
#   type        = map(string)
#   default     = {}
# }

# ###################### Subnets variables #####################


# variable "public_subnets" {
#   description = "A list of public subnets inside the VPC"
#   type        = list(string)
#   default     = []
# }

# variable "public_subnets_tags" {
#   description = "Additional tags for the public subnets"
#   type        = map(string)
#   default     = {}
# }

# variable "private_subnets" {
#   description = "A list of private subnets inside the VPC"
#   type        = list(string)
#   default     = []
# }

# variable "private_subnets_tags" {
#   description = "Additional tags for the private subnets"
#   type        = map(string)
#   default     = {}
# }
#--------------------------------------

variable "vpc_id" {
  description = "fetch vpc id"
  type        = string
}

variable "subnet_id" {
  description = "fetch subnet id"
  type        = list(string)
  default     = []
}
