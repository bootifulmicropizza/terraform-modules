data "tls_certificate" "example" {
  url = aws_eks_cluster.bootifulmicropizza.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "bootifulmicropizza_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.example.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.bootifulmicropizza.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "aws_node_service_account_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.bootifulmicropizza_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.bootifulmicropizza_oidc.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.bootifulmicropizza_oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_node_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.aws_node_service_account_policy.json
  name               = "BootifulMicroPizzaAWSNodeServiceAccount"
}

resource "aws_iam_role_policy_attachment" "aws_node_service_account_role_policy_attachment" {
  role       = aws_iam_role.aws_node_service_account_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
