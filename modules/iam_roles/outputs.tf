output "eks_cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster."
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_cluster_role_name" {
  description = "The Name of the IAM role for the EKS cluster."
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_node_group_role_arn" {
  description = "The ARN of the IAM role for the EKS worker nodes."
  value       = aws_iam_role.eks_node_group_role.arn
}