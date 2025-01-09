### Instal Metrics Server
### Source: https://artifacthub.io/packages/helm/metrics-server/metrics-server
resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.2"

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [module.eks.worker_nodes]
}

### Install Cluster Autoscaler
### source: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler
resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.45.0"

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  # MUST be updated to match your region 
  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  depends_on = [helm_release.metrics_server]
}

### Install AWS Load Balancer controller Helm chart for Kubernetes to manage AWS Load Balancers (ALB, NLB)
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

### Install ingress-nginx: Ingress controller for Kubernetes - Using NGINX as a reverse proxy
### Source: https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
resource "helm_release" "external_nginx" {
  name = "external"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true

  version = "4.12.0"

  values = [(file("${path.module}/values/nginx-ingress.yaml"))]

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