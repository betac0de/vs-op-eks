variable "eks_cluster_name" {
  description = "Name of the EKS cluster for role naming and tagging."
  type        = string
}

variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
}