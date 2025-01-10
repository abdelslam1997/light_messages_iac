########################################################
# 1) Retrieve the Secret from AWS Secrets Manager
########################################################
locals {
  ssh_private_key = replace(data.aws_secretsmanager_secret_version.ssh_private_key.secret_string, "\r\n", "\n")
}

data "aws_secretsmanager_secret" "ssh_private_key" {
  arn = var.ssh_server_key_secret_arn
}

data "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id = data.aws_secretsmanager_secret.ssh_private_key.id
}

########################################################
# 2) Create the K8s Secret in the ArgoCD namespace
########################################################
resource "kubernetes_secret" "argocd_git_repo" {
  metadata {
    name      = "git-repo-secrets"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url           = "git@github.com:abdelslam1997/light_messages_iac.git"
    sshPrivateKey = local.ssh_private_key
    insecure      = "false"
    enableLfs     = "true"
  }


  type = "Opaque"

  depends_on = [helm_release.argocd]
}


##########################################################################################
# 3) Retrieve light-messages secrets from AWS Secrets Manager as JSON object
##########################################################################################
locals {
  light_messages_secrets = jsondecode(data.aws_secretsmanager_secret_version.light_messages_secrets.secret_string)
}
data "aws_secretsmanager_secret" "light_messages_secrets" {
  arn = var.light_messages_secrets_arn
}

data "aws_secretsmanager_secret_version" "light_messages_secrets" {
  secret_id = data.aws_secretsmanager_secret.light_messages_secrets.id
}

resource "kubernetes_secret" "light_messages_secrets" {
  metadata {
    name      = "light-messages-secrets"
    namespace = "default"
  }

  data = local.light_messages_secrets
  type = "Opaque"

  depends_on = [helm_release.argocd]

}

##########################################################################################
# 4) Output the secrets to the console `Debugging purpose` Don't do this in production
##########################################################################################
output "secrets-value" {
  value     = local.ssh_private_key
  sensitive = true
}

output "light-messages-secrets" {
  value     = local.light_messages_secrets
  sensitive = true
}