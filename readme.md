# Deploy EKS Cluster using Terraform and ArgoCD

## Prerequisites
- AWS CLI
- AWS IAM User with Admin Access
- Terraform

## Deploy EKS Cluster using Terraform and ArgoCD

### 1. Make sure you make `.env` file as `.env.example` and update the values

### 2. Set environment variables
```bash
source .env
```

### 3. Check your aws credentials is valid
```bash
aws sts get-caller-identity
```

### 4. Deploy EKS Cluster using Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 5. Connect to aws eks cluster
```bash
aws eks --region <aws_region> update-kubeconfig --name <eks_cluster_name>
```

## Connect to ArgoCD

### 1. Check if argocd is running
```bash
# Check if argocd namespace exists
kubectl get namespace argocd
# Check if argocd pods are running
kubectl get pods -n argocd  
```

### 2. Get ArgoCD Login Password
```bash
# Get argocd password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```
### 3. Port forward to argocd server
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80 &
```
### 4. Access argocd server
- URL: http://localhost:8080
- **Username:** admin
- **Password:** `From step above: 2. Get ArgoCD Login Password `