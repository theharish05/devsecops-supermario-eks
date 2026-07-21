# Fetch available availability zones in us-east-1
data "aws_availability_zones" "available" {}

# 1. Build the Virtual Private Cloud (VPC) Network
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Tags required by Kubernetes to discover the subnets for LoadBalancers
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# 2. Build the EKS Cluster and Worker Nodes
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Deploy the worker nodes using the instance type from your variables
  eks_managed_node_groups = {
    mario_nodes = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Grants admin access to the IAM entity that creates the cluster
  enable_cluster_creator_admin_permissions = true
}
