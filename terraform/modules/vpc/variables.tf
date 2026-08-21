variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name used for resource naming"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones used for public and private subnets"
  type        = list(string)
}