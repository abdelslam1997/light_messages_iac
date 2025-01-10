resource "kubernetes_manifest" "argocd_root_app" {
  manifest = yamldecode(file("./manifests/argocd_root_app.yaml"))
}
