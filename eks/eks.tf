resource "aws_eks_cluster" "bootifulmicropizza" {
  name     = "bootifulmicropizza"
  role_arn = aws_iam_role.bootifulmicropizza.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
      aws_subnet.private_subnet_3.id,
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.bootifulmicropizza-AmazonEKSClusterPolicy
  ]
}

resource "aws_iam_role" "bootifulmicropizza" {
  name = "BootifulmicropizzaEKSCluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "bootifulmicropizza-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.bootifulmicropizza.name
}

output "endpoint" {
  value = aws_eks_cluster.bootifulmicropizza.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.bootifulmicropizza.certificate_authority[0].data
}
