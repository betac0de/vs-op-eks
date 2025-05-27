terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify a version constraint
    }
  }

  required_version = ">= 1.0" # Specify Terraform version constraint
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "./modules/network" # Path to the network module

  project_name         = var.project_name
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  eks_cluster_name     = var.eks_cluster_name # Pass cluster name for tagging
}

module "iam_roles" {
  source = "./modules/iam_roles" # Path to the IAM roles module

  eks_cluster_name = var.eks_cluster_name
  project_name     = var.project_name
}