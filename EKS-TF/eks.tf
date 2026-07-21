module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.34"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    mario_nodes = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "production"
    Project     = "mario-v2"
  }
resource "aws_eks_access_entry" "github_deployer_access" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = "arn:aws:iam::823729324830:user/GitHubDeployer"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_deployer_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.github_deployer_access.principal_arn

  access_scope {
    type = "cluster"
  }
}
