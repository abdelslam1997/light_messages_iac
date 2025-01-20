# Deploy EKS Cluster using Terraform and ArgoCD

## Overview
This repository contains the terraform code to deploy EKS cluster, S3, RDS and ArgoCD App for (Light Messages Demo). 

- Backend Repository: [Light Messages Backend](https://github.com/abdelslam1997/light_messages_backend)
- Frontend Repository: [Light Messages Frontend](https://github.com/abdelslam1997/light_messages_frontend)

`We are using ArgoCD to deploy the backend and frontend applications to the EKS cluster. this repository contains IaC and ArgoCD App for the backend and frontend applications.`

**`Feel free to clone the repository and modified it to match your needs`**

### Terraform Architecture Overview
![img](./images/004_terraform_arch.png)
- **`Terraform`** is used to deploy the resources on the diagram above
- **`Terraform`** will manage secrets using AWS Secret Manager
- **`Terraform`** will upload the secrets to the EKS cluster and ArgoCD will use it to deploy the applications

### AWS Architecture Overview
![img](./images/005_AWS_Arcitecture.png)
- **`NLB (Network Load Balancer)`** is used to route the traffic to the EKS cluster. it will route the traffic to nginx-ingress-controller pods.

- **`ALB (Application Load Balancer)`** nginx-ingress-controller pods will apply the ingress rules and route the traffic to the backend and frontend services.

### Cluster Architecture Overview
![img](./images/006_cluster_arch.png)
- **`ArgoCD`** Reponsible to observe the IaC repository and deploy the applications to the EKS cluster to match desired state.

## Prerequisites
- WSL terminal (if you are using windows)
- AWS IAM User Account
- AWS CLI
- kubectl
- Terraform
- **If you wish to try the deployment of (Light Messages Demo) you need to have the following:**
  - Clone the `backend` and `frontend` and `IaC` repositories
  - `If you want to keep your IaC repo private`, you need to create `ssh key` and add it to your github IaC repo in Deploy Keys section (Settings > Deploy Keys)
  - Upload your ssh key to AWS Secret Manager and Add secret_arn to .env file variable `TF_VAR_ssh_server_key_secret_arn` Terraform will upload the secret to the EKS cluster and argocd will use it to access the IaC repository.
  - Add backend environment variables to secrets in AWS Secret Manager and add the secret_arn to .env file variable `TF_VAR_backend_secrets_secret_arn` Terraform will upload the secret to the EKS cluster and argocd will use it to deploy the backend application.
  - Create a docker images (Backend, Frontend) and push it into your docker hub account
  - Update repoURL in `./apps/` directory to match your repositories
  - Update the `./k8s/production` images to match your docker images


## Deploy EKS Cluster using Terraform and ArgoCD

### 1. Make sure you make `.env` file as `.env.example` and update the values

### 2. Set environment variables
```bash
cd terraform
source .env
```

### 3. Check your aws credentials is valid
```bash
aws sts get-caller-identity
```

### 4. Deploy Infrastructure using Terraform (VPC + EKS Cluster + ArgoCD + S3 + RDS)
```bash
./apply.sh
```

### 5. Connect to aws eks cluster using kubectl
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
- Using Terraform Output
```bash
cd eks_cluster
terraform output argocd_secret_initial_admin_password
````
- Or using kubectl command
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

### 5. Check if the applications are deployed
- you should see something like this in the argocd dashboard
![img](./images/007_argocd_admin.png)

### 6. Get the ingress endpoint
```bash
kubectl get svc -n ingress
```

### 7. Access the applications
- Frontend URL: http://<ingress_endpoint>
- Backend URL: http://<ingress_endpoint>/api/v1/

### 8. Check the load balancer routing to different pods
```bash
http://<ingress_endpoint>/api/v1/health/
```
- On refresh you should see the `pod name` changing like this
![img](./images/_health_check.png)
![img](./images/_health_check_2.png)

### 9. Test the ArgoCD Sync
- Update the frontend `Dockerfile` to use backend endpoint
- Push the docker image to docker hub
- Update the `./k8s/production/reactapp/deployment.yaml` to use the new docker image version
- Commit the changes to the IaC repository and Wait for the ArgoCD to sync the changes

### 10. Destroy
- To destroy the infrastructure Run the following command
```bash
# Make sure to login to your AWS account and empty the S3 bucket
cd terraform
./destroy.sh
```
- **Note:** Make sure your infrastructure is destroyed to avoid any charges on your AWS account Final output should be like this:

![img](./images/destroy.png)



**Thank you for reading this readme file. I hope you find it useful.**