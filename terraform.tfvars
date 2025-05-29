aws_region   = "us-east-1"
project_name = "my-eks-project" # You can use this to derive other names or in tags

# VPC & Network
vpc_name             = "my-eks-project-vpc" # Derived from project_name for example
vpc_cidr_block       = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.101.0/24", "10.10.102.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"] # Ensure this matches the number and region of your subnets
enable_nat_gateway   = true

# EKS Cluster
eks_cluster_name            = "production-cluster" # You had this
eks_cluster_version         = "1.29"
eks_endpoint_private_access = false
eks_endpoint_public_access  = true
eks_public_access_cidrs     = ["0.0.0.0/0"] # For testing; restrict in production

# EKS Node Group
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 2
eks_node_min_size       = 1
eks_node_max_size       = 3
eks_node_disk_size      = 20

# Common Tags
common_tags = {
  Environment = "production" # As your cluster name suggests
  Project     = "my-eks-project"
  Terraform   = "true"
}

# Optional: EKS Addon Configuration (uncomment and customize if needed)
# eks_addons = {
#   "vpc-cni" = { addon_version = "v1.18.1-eksbuild.1" },
#   "coredns" = { addon_version = "v1.11.1-eksbuild.9" },
#   "kube-proxy" = { addon_version = "v1.29.3-eksbuild.2" }
# }