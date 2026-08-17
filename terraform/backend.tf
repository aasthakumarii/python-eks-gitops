terraform {
  backend "s3" {
    bucket = "s3-backend-aastha"
    key    = "python-eks-gitops/terraform.tfstate"
    region = "ap-south-1"
  }
}