##########################################################################
# In production, you may want to remove the sensitive outputs below
##########################################################################

############################################
# EKS Cluster Outputs
############################################
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "addon_versions" {
  value = {
    coredns                = data.aws_eks_addon_version.coredns.version
    vpc_cni                = data.aws_eks_addon_version.vpc_cni.version
    kube_proxy             = data.aws_eks_addon_version.kube_proxy.version
    eks_pod_identity_agent = data.aws_eks_addon_version.eks_pod_identity_agent.version
  }
}


############################################
# ArgoCD Outputs (Sensitive) (Password)
############################################
data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}


output "argocd_secret_initial_admin_password" {
  value     = data.kubernetes_secret.argocd_initial_admin_secret.data["password"]
  sensitive = true
}


############################################
# S3 Bucket Outputs (Sensitive)
############################################
output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.django_storage.id
}

output "s3_user_access_key" {
  description = "Access key for the Django S3 user"
  value       = aws_iam_access_key.django_s3_user.id
  sensitive   = true
}

output "s3_user_secret_key" {
  description = "Secret key for the Django S3 user"
  value       = aws_iam_access_key.django_s3_user.secret
  sensitive   = true
}


############################################################
# Output aws secrets (Sensitive)
############################################################
output "secrets-value" {
  value     = local.ssh_private_key
  sensitive = true
}

output "light-messages-secrets" {
  value     = local.light_messages_secrets
  sensitive = true
}