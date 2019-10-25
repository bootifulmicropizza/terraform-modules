resource "aws_eks_node_group" "bootifulmicropizza-eks-node-group" {
  cluster_name    = aws_eks_cluster.bootifulmicropizza.name
  node_group_name = "bootifulmicropizza-eks-node-group"
  node_role_arn   = aws_iam_role.bootifulmicropizza-eks-node-group-iam-role.arn
  subnet_ids      = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
      aws_subnet.private_subnet_3.id,
  ]
  capacity_type   = "SPOT"
  instance_types  = ["m1.large"] 

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  labels = {
      node = "ec2"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "bootifulmicropizza-eks-node-group-iam-role" {
  name = "BootifulMicroPizzaEKSNodeGroup"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.bootifulmicropizza-eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.bootifulmicropizza-eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.bootifulmicropizza-eks-node-group-iam-role.name
}
