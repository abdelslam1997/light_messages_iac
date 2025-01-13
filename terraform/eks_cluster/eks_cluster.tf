module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.eks_cluster_name
  cluster_version = var.eks_cluster_version

  # EKS Addons
  bootstrap_self_managed_addons = true
  cluster_addons = {
    # Provides DNS-based service discovery for the cluster
    coredns = {
      addon_version = data.aws_eks_addon_version.coredns.version
    }
    # Enables IAM roles for service accounts (IRSA)
    eks-pod-identity-agent = {
      addon_version = data.aws_eks_addon_version.eks_pod_identity_agent.version
    }
    # Handles network routing and load-balancing for Kubernetes Services
    kube-proxy = {
      addon_version = data.aws_eks_addon_version.kube_proxy.version
    }
    # AWS VPC CNI (Container Networking Interface) plugin manages Pod networking
    vpc-cni = {
      addon_version = data.aws_eks_addon_version.vpc_cni.version
    }
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
      instance_type = "t3.medium"
      capacity_type = "ON_DEMAND"
      ### Scaling configuration
      min_size = 2
      max_size = 5
      # This value is ignored after the initial creation
      desired_size = 2
    }
  }

  tags = merge(local.tags, {
    "k8s.io/cluster-autoscaler/enabled"                   = "true"
    "k8s.io/cluster-autoscaler/${local.eks_cluster_name}" = "owned"
  })

  depends_on = [module.vpc]

}

##################################################
# Grab the latest addons version
##################################################
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.eks_cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.eks_cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.eks_cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "eks_pod_identity_agent" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = var.eks_cluster_version
  most_recent        = true
}

output "addon_versions" {
  value = {
    coredns                = data.aws_eks_addon_version.coredns.version
    vpc_cni                = data.aws_eks_addon_version.vpc_cni.version
    kube_proxy             = data.aws_eks_addon_version.kube_proxy.version
    eks_pod_identity_agent = data.aws_eks_addon_version.eks_pod_identity_agent.version
  }
}