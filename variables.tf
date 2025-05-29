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

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29" # Ensure this matches or is compatible with addon versions
}

variable "eks_node_instance_types" {
  description = "List of instance types for EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "eks_node_disk_size" {
  description = "Disk size (GiB) for EKS worker nodes."
  type        = number
  default     = 20
}

variable "eks_endpoint_private_access" {
  description = "Enable private access to EKS API server."
  type        = bool
  default     = false
}

variable "eks_endpoint_public_access" {
  description = "Enable public access to EKS API server."
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production!
}

variable "eks_addons_config" {
  description = "Configuration for EKS addons."
  type = map(object({
    addon_version            = optional(string)
    resolve_conflicts        = optional(string)
    service_account_role_arn = optional(string)
  }))
  default = {
    "vpc-cni" = {
      # addon_version = "v1.18.1-eksbuild.1" # Specify or leave empty to use default/latest compatible
    }
    "coredns" = {
      # addon_version = "v1.11.1-eksbuild.9"
    }
    "kube-proxy" = {
      # addon_version = "v1.29.3-eksbuild.2"
    }
    # Example: Add aws-ebs-csi-driver if you need it
    # "aws-ebs-csi-driver" = {}
  }
  # Note: Ensure these addon versions are compatible with your var.eks_cluster_version.
  # Check AWS documentation for the latest recommended versions.
}

# You should already have variables for aws_region, network (vpc_id, subnet_ids), common_tags etc.
# Also, ensure you have 'enable_nat_gateway' if your network module uses it.
variable "enable_nat_gateway" {
  description = "Set to false if NAT Gateway is not needed. If false and nodes need internet, place them in public subnets."
  type        = bool
  default     = true
}