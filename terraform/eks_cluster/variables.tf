variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "dev"
}