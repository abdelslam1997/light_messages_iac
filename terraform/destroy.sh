#! /bin/sh

### Auto Approve ?
if [ "$1" = "-auto-approve" ]; then
  AUTO_APPROVE="-auto-approve"
else
  AUTO_APPROVE=""
fi

### Ask for Confirmation ?
if [ -z "$AUTO_APPROVE" ]; then
  echo "Are you sure you want to destroy the infrastructure? (yes/no): "
  read CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Destroy cancelled"
    exit 1
  fi
fi

#################################################
### STEP 01: Destroy ArgoCD Root Application ####
#################################################

# Change Directory
cd argocd_root_app

# Run Terraform Refresh
terraform refresh

# Destroy ArgoCD Root Application
terraform destroy -auto-approve


#################################################
### STEP 02: Destroy EKS Cluster & Infrastructure
#################################################

# Change Directory
cd eks_cluster

# Run Terraform Refresh
terraform refresh

# 1. Destroy External Nginx
terraform destroy -target=helm_release.external_nginx -auto-approve

# 2. Destroy AWS Load Balancer Controller
terraform destroy -target=helm_release.aws_lbc -auto-

# 3. Destroy EKS Cluster
terraform destroy -target=module.eks_cluster -auto-approve

# 4. Destroy The Rest
terraform destroy -auto-approve