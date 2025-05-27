variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of availability zones to use for subnets."
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster, used for tagging resources."
  type        = string
}