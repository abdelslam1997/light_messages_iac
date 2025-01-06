### Install AWS Load Balancer controller Helm chart for Kubernetes
### Source: https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  # Add VPC ID configuration
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [module.eks.worker_nodes]
}

### Install ingress-nginx: Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer
### Source: https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
resource "helm_release" "external_nginx" {
  name = "external"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true

  version = "4.12.0"

  values = [file("${path.module}/values/nginx-ingress.yaml")]

  depends_on = [helm_release.aws_lbc]
}


### Install cert-manager: Automatically provision and manage TLS certificates in Kubernetes
### Source: https://artifacthub.io/packages/helm/cert-manager/cert-manager
resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.16.2"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [helm_release.external_nginx]
}