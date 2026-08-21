variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version used by EKS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where EKS and worker nodes will run"
  type        = list(string)
}

variable "admin_cidr" {
  description = "Public CIDR allowed to access the EKS API endpoint"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid CIDR, for example 203.0.113.10/32."
  }
}

variable "admin_principal_arn" {
  description = "IAM principal that receives EKS cluster administrator access"
  type        = string
}

variable "node_group_name" {
  description = "EKS managed node group name"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type used by EKS worker nodes"
  type        = string
}

variable "capacity_type" {
  description = "EKS node group capacity type"
  type        = string

  validation {
    condition = contains(
      ["ON_DEMAND", "SPOT"],
      var.capacity_type
    )

    error_message = "capacity_type must be either ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
}