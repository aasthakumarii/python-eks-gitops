# --------------------------------------------------
# VPC Module
# --------------------------------------------------

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  cluster_name = var.cluster_name
  project_name = var.project_name
}


# --------------------------------------------------
# EKS Module
# --------------------------------------------------

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  project_name       = var.project_name
  kubernetes_version = var.kubernetes_version

  private_subnet_ids = module.vpc.private_subnet_ids

  admin_cidr          = var.admin_cidr
  admin_principal_arn = var.admin_principal_arn

  node_group_name    = var.node_group_name
  node_instance_type = var.node_instance_type
  capacity_type      = var.capacity_type

  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
}