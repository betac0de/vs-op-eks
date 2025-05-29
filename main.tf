terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify a version constraint
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0" # Specify a version constraint
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

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  vpc_id          = module.network.vpc_id

  subnet_ids = module.network.private_subnet_ids # Output from your network module

  eks_cluster_role_arn    = module.iam_roles.eks_cluster_role_arn    # Output from your iam_roles module
  eks_node_group_role_arn = module.iam_roles.eks_node_group_role_arn # Output from your iam_roles module

  instance_types = var.eks_node_instance_types
  desired_size   = var.eks_node_desired_size
  min_size       = var.eks_node_min_size
  max_size       = var.eks_node_max_size
  disk_size      = var.eks_node_disk_size
  enable_irsa    = true # Recommended for secure pod access to AWS services

  endpoint_private_access = var.eks_endpoint_private_access
  endpoint_public_access  = var.eks_endpoint_public_access
  public_access_cidrs     = var.eks_public_access_cidrs
  eks_addons              = var.eks_addons_config

  depends_on = [module.network, module.iam_roles] # Ensure network and IAM roles are ready
}