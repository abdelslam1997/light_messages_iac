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

output "cluster_name" {
  value = module.eks.cluster_name
}