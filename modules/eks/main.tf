# EKS Cluster Resource
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access ? var.public_access_cidrs : [] # Only apply if public access is true
    # security_group_ids = [] # Optional: Specify custom security groups for the control plane ENIs
  }

  tags = merge(
    {
      "Name" = "${var.cluster_name}-cluster"
    },
    var.tags
  )
}

# IAM OIDC Provider for IRSA (IAM Roles for Service Accounts)
# Fetches the EKS cluster's OIDC provider certificate for thumbprint calculation
data "tls_certificate" "eks_cluster_thumbprint" {
  count = var.enable_irsa ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer # This creates a dependency on the cluster being available
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_thumbprint[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    {
      "Name" = "${var.cluster_name}-oidc-provider"
    },
    var.tags
  )
}

# EKS Managed Node Group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default-ng" # You can make this configurable
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.subnet_ids # These should be the subnets where your worker nodes will reside

  instance_types = var.instance_types
  disk_size      = var.disk_size

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # Define how node group updates are handled
  update_config {
    max_unavailable = 1 # Or use max_unavailable_percentage
  }

  tags = merge(
    {
      "Name"                                          = "${var.cluster_name}-default-nodegroup"
      "eks:cluster-name"                              = var.cluster_name # Useful for some integrations
      "k8s.io/cluster-autoscaler/enabled"             = "true"           # Tag for cluster autoscaler
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"          # Tag for cluster autoscaler
    },
    var.tags
  )

  # Ensure cluster is created before node group
  depends_on = [
    aws_eks_cluster.this,
    aws_iam_openid_connect_provider.this # If IRSA is enabled, ensure OIDC provider is created first
  ]
}

# EKS Addons (VPC CNI, CoreDNS, Kube-proxy are common)
resource "aws_eks_addon" "this" {
  for_each = var.eks_addons

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = each.key
  addon_version            = each.value.addon_version # Ensure this version is compatible with your K8s cluster_version
  resolve_conflicts        = each.value.resolve_conflicts
  service_account_role_arn = each.value.service_account_role_arn # For addons that support custom IAM roles

  tags = merge(
    {
      "Name"             = "${var.cluster_name}-addon-${each.key}"
      "eks:cluster-name" = var.cluster_name
    },
    var.tags
  )

  depends_on = [
    aws_eks_node_group.default # Addons might need nodes to be ready
  ]
}