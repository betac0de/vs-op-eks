variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # Choose your default region
}

variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
  default     = "eks-prereq"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Example for two AZs
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"] # Example for two AZs
}

variable "availability_zones" {
  description = "A list of availability zones to use."
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "The name for the EKS cluster (used for tagging and IAM role naming)."
  type        = string
  default     = "my-eks-cluster"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing EKS cluster state and other artifacts."
  type        = string
  default     = "972842348930-test" # Ensure this is globally unique
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for EKS state locking."
  type        = string
  default     = "eks-cluster-lock-table"
}