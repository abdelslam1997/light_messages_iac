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

variable "eks_cluster_version" {
  type        = string
  description = "EKS cluster version"
  default     = "1.31"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "iac_repo_url" {
  type        = string
  description = "IaC repository URL"
  default     = "git@github.com:abdelslam1997/light_messages_iac.git"
  
}

variable "ssh_server_key_secret_arn" {
  type        = string
  description = "SSH private key secret ARN to access the IaC Git repository"
  sensitive   = true
  # Set By Env Var
}

variable "light_messages_secrets_arn" {
  type        = string
  description = "Light messages secrets ARN"
  sensitive   = true
  # Set By Env Var
}