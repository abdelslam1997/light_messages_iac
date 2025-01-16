#! /bin/sh

### Auto Approve ?
if [ "$1" = "-auto-approve" ]; then
  AUTO_APPROVE="-auto-approve"
else
  AUTO_APPROVE=""
fi

### Ask for Confirmation ?
if [ -z "$AUTO_APPROVE" ]; then
  echo "Are you sure you want to apply the infrastructure changes? (yes/no): "
  read CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Destroy cancelled"
    exit 1
  fi
fi

#################################################
### STEP 01: Apply EKS Cluster & Infrastructure
#################################################
# Change Directory
cd eks_cluster
# Run Terraform init
terraform init
# Run Terraform Refresh
terraform refresh
# Apply The Changes
terraform apply -auto-approve
# Refresh & Apply one more time (Some-times S3 Policy is not applied in first run)
terraform refresh
terraform apply -auto-approve
# Change Directory
cd ..

#################################################
### STEP 02: Apply ArgoCD Root Application #####
#################################################
# Change Directory
cd argocd_root_app
# Run Terraform init
terraform init
# Run Terraform Refresh
terraform refresh
# Apply The Changes
terraform apply -auto-approve
# Change Directory
cd ..
#################################################

echo -e "\033[32mInfrastructure Changes Applied Successfully\033[0m"

