output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your EKS Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster, used for IAM Roles for Service Accounts (IRSA)."
  value       = module.eks.cluster_oidc_issuer_url
}