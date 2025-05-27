resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-${var.eks_cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-${var.eks_cluster_name}-cluster-role"
    Project = var.project_name
    Cluster = var.eks_cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS requires VPC CNI plugin to have permissions to manage network interfaces and other resources.
# This is often attached to the EKS Node Group Role, but sometimes a specific service account role.
# For simplicity, we'll attach AmazonEKS_CNI_Policy to the cluster role as well,
# though in more complex setups, this might be handled differently (e.g., IRSA for aws-node).
# AmazonEKSVPCResourceController is also needed for security groups for pods.
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" # Allows EKS to manage ENIs for pods
  role       = aws_iam_role.eks_cluster_role.name
}