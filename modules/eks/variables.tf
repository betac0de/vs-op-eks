variable "cluster_name" {
  description = "The name for the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29" # Or your desired version
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster and nodes will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster and worker nodes. These should typically be private subnets if using a NAT Gateway, or public if not."
  type        = list(string)
}

variable "eks_cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster."
  type        = string
}

variable "eks_node_group_role_arn" {
  description = "The ARN of the IAM role for the EKS worker nodes."
  type        = string
}

variable "instance_types" {
  description = "A list of instance types for the EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes."
  type        = number
  default     = 20
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

variable "enable_irsa" {
  description = "Boolean to enable IAM Roles for Service Accounts (IRSA) by creating an OIDC provider."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false # Set to true if you need to access the API server from within the VPC only
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true # Set to false if you only want private access
}

variable "public_access_cidrs" {
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint. Required if endpoint_public_access is true."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this for production
}

variable "eks_addons" {
  description = "Map of EKS addons to install (e.g., vpc-cni, coredns, kube-proxy)."
  type = map(object({
    addon_version            = optional(string)
    resolve_conflicts        = optional(string, "OVERWRITE") # Other options: NONE, PRESERVE
    service_account_role_arn = optional(string)
  }))
  default = {
    # It's highly recommended to manage vpc-cni, coredns, and kube-proxy via EKS Addons.
    # Check AWS documentation for the latest compatible versions for your chosen Kubernetes version.
    "vpc-cni" = {
      # addon_version = "v1.18.1-eksbuild.1" # Example, find current version for your K8s cluster version
    }
    "coredns" = {
      # addon_version = "v1.11.1-eksbuild.9" # Example
    }
    "kube-proxy" = {
      # addon_version = "v1.29.3-eksbuild.2" # Example
    }
  }
}