variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "production"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "production-eks-cluster"

}

