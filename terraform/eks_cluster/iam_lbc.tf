# AWS Load Balancer Controller IAM Configuration
#
# This configuration sets up the necessary IAM roles and policies for the AWS Load Balancer Controller
# to function properly in an EKS cluster.
#
# Resources created:
# - IAM role with trust policy allowing EKS pods to assume the role
# - IAM policy with permissions required by AWS Load Balancer Controller
# - Role-policy attachment
# - EKS Pod Identity Association for the Load Balancer Controller service account
#
# The Load Balancer Controller runs in the kube-system namespace and requires specific IAM permissions
# to create and manage AWS Application Load Balancers (ALB) and Network Load Balancers (NLB).
#
# Dependencies:
# - Requires an existing EKS cluster
# - Requires the AWSLoadBalancerController.json policy file in the ./policies directory
# - Requires the aws-load-balancer-controller service account to exist in kube-system namespace

data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "aws_lbc" {
  name               = "${module.eks.cluster_name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

resource "aws_iam_policy" "aws_lbc" {
  policy = file("./policies/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc.arn
}