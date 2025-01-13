locals {
  eks_cluster_name = "${var.environment}-eks-cluster"
  vpc_name         = "${var.environment}-main-vpc"
  common_tags = {
    "ManagedBy"   = "Terraform"
    "Environment" = var.environment
  }
}