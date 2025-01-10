variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "dev"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "dev-eks-cluster"

}

