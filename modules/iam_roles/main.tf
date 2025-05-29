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

# This role will be assumed by the EC2 instances in your EKS Node Group.
resource "aws_iam_role" "eks_node_group_role" {
  # Use a variable for prefix if you have one, e.g., from var.cluster_name_prefix
  # name = "${var.cluster_name_prefix}-eks-nodegroup-role"
  name_prefix = "eks-nodegroup-role-" # Or use a dynamic name_prefix

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com" # Nodes are EC2 instances
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

}

# Attach required policies for EKS worker nodes
resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # Allows nodes to pull images from ECR
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  # This policy allows the VPC CNI plugin (running on nodes) to manage network interfaces.
  # Ensure the version of this policy you're using or the permissions within it are
  # compatible with your CNI requirements.
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}