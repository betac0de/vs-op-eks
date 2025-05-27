terraform {
  backend "s3" {
    bucket         = "972842348930-test"
    key            = "terraform/state/eks-cluster.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-cluster-lock-table"
  }
}