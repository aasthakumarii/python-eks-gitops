# --------------------------------------------------
# General Configuration
# --------------------------------------------------

variable "aws_region" {
  description = "AWS region used for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used for tagging AWS resources"
  type        = string
  default     = "python-eks-gitops"
}


# --------------------------------------------------
# VPC Configuration
# --------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the VPC"
  type        = list(string)

  default = [
    "ap-south-1a",
    "ap-south-1b"
  ]
}


# --------------------------------------------------
# EKS Configuration
# --------------------------------------------------

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "python-eks-gitops"
}

variable "kubernetes_version" {
  description = "Kubernetes version used by EKS"
  type        = string
  default     = "1.33"
}


# --------------------------------------------------
# Security
# --------------------------------------------------

variable "admin_cidr" {
  description = "Personal public IP allowed to access the EKS API endpoint"
  type        = string
}

variable "admin_principal_arn" {
  description = "IAM principal granted EKS administrator access"
  type        = string
}


# --------------------------------------------------
# Node Group Configuration
# --------------------------------------------------

variable "node_group_name" {
  description = "EKS managed node group name"
  type        = string
  default     = "default"
}

variable "node_instance_type" {
  description = "EKS worker node EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "capacity_type" {
  description = "EKS node capacity type"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "Desired EKS worker node count"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum EKS worker node count"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum EKS worker node count"
  type        = number
  default     = 2
}