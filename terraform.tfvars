aws_region           = "us-east-1" # Choose your desired AWS region
project_name         = "my-eks-project"
vpc_cidr_block       = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.101.0/24", "10.10.102.0/24"]
# For availability_zones, it's better to let the root main.tf fetch them dynamically.
# If you want to specify them manually, uncomment and set:
availability_zones = ["us-east-1a", "us-east-1b"] # Ensure these match your region and number of subnets
eks_cluster_name   = "production-cluster"