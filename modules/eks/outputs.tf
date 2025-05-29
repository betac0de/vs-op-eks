output "cluster_endpoint" {
  description = "Endpoint for your EKS Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster. Needed for IAM Roles for Service Accounts (IRSA)."
  value       = var.enable_irsa && length(aws_eks_cluster.this.identity) > 0 ? aws_eks_cluster.this.identity[0].oidc[0].issuer : null
}

output "node_group_name" {
  description = "The name of the default EKS node group."
  value       = aws_eks_node_group.default.node_group_name
}

output "node_group_role_arn" {
  description = "The ARN of the IAM role used by the EKS worker nodes."
  value       = aws_eks_node_group.default.node_role_arn
}