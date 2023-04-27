terraform {
  required_version = "~> 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_eks_cluster" "cluster" {
  name = "dev-cluster"
}

data "aws_eks_cluster_auth" "this" {
  name = "dev-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.certificate_authority.data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.certificate_authority.data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
