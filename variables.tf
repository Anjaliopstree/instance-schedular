variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  validation {
    condition     = length(var.azs) > 0
    error_message = "You must provide at least one AZ."
  }
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "vpc_id" {
  description = "fetch vpc id"
  type        = string
}

variable "subnet_id" {
  description = "fetch subnet id"
  type        = list(string)
  default     = []
}