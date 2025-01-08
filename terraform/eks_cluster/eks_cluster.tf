module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.eks_cluster_name
  cluster_version = "1.31"

  # EKS Addons
  cluster_addons = {
    # Provides DNS-based service discovery for the cluster
    coredns                = {}
    # Enables IAM roles for service accounts (IRSA)
    eks-pod-identity-agent = {}
    # Handles network routing and load-balancing for Kubernetes Services
    kube-proxy             = {}
    # AWS VPC CNI (Container Networking Interface) plugin manages Pod networking
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
  # Optional: Enable public access to the kubernetes API server
  cluster_endpoint_public_access = true


  self_managed_node_groups = {
    worker_nodes = {
      ### Worker nodes configuration
      ami_type      = "AL2_x86_64"
      instance_type = "t2.micro"
      capacity_type = "ON_DEMAND"
      ### Scaling configuration
      min_size     = 2
      max_size     = 5
      desired_size = 3
    }
  }

  tags = local.tags

}