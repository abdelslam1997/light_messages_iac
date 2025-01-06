locals {
  eks_cluster_name = "${var.environment}-eks-cluster"
  vpc_name         = "${var.environment}-main-vpc"
  vpc_cidr         = var.vpc_cidr
  azs              = slice(data.aws_availability_zones.azs.names, 0, 2)

  tags = {
    "ManagedBy"   = "Terraform"
    "Environment" = var.environment
  }

}


# Get the availability zones for the region
data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = local.vpc_name

  cidr = local.vpc_cidr

  azs = local.azs

  # 10.0.0.0/24, 10.0.1.0/24 for eu-west-2a, eu-west-2b
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  # 10.0.4.0/24, 10.0.5.0/24 for eu-west-2a, eu-west-2b
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = merge(local.tags, {
    # kubernetes.io/role/elb is required for the external ALB to work
    "kubernetes.io/role/elb"                          = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  })

  private_subnet_tags = merge(local.tags, {
    # internal-elb is required for the internal ALB to work
    "kubernetes.io/role/internal-elb"                 = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  })

  tags = local.tags
}