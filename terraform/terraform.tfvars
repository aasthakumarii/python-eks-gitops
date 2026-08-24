aws_region   = "ap-south-1"
project_name = "python-eks-gitops"

cluster_name       = "python-eks-gitops"
kubernetes_version = "1.33"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

node_group_name    = "default"
node_instance_type = "t3.small"
capacity_type      = "ON_DEMAND"

node_desired_size = 2
node_min_size     = 1
node_max_size     = 2

admin_cidr          = "122.181.102.43/32"
admin_principal_arn = "arn:aws:iam::755729228993:user/Aastha"