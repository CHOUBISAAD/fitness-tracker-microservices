terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # Uncomment for remote state storage
  # backend "s3" {
  #   bucket         = "fitness-tracker-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "eu-west-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Configure Kubernetes provider after EKS cluster is created
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

# Local variables
locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
  
  common_tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}"
    }
  )
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name         = var.project_name
  environment          = var.environment
  cluster_version      = var.eks_cluster_version
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  node_instance_type   = var.eks_node_instance_type
  desired_capacity     = var.eks_desired_capacity
  min_capacity         = var.eks_min_capacity
  max_capacity         = var.eks_max_capacity
  tags                 = local.common_tags
}

# ECR Repositories
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  
  repositories = [
    "eureka-server",
    "config-server",
    "api-gateway",
    "user-service",
    "activity-service",
    "ai-service",
    "frontend"
  ]
  
  tags = local.common_tags
}

# RDS PostgreSQL
module "rds" {
  source = "./modules/rds"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  engine_version      = var.rds_engine_version
  database_name       = var.rds_db_name
  master_username     = var.rds_username
  backup_retention_period = 1
  node_security_group_id = module.eks.node_security_group_id
  tags                = local.common_tags
}

# DocumentDB (MongoDB compatible) - NOT FREE TIER ELIGIBLE
# Self-hosting MongoDB on EKS instead (see Phase 3: Kubernetes manifests)
# module "documentdb" {
#   source = "./modules/documentdb"
#
#   project_name        = var.project_name
#   environment         = var.environment
#   vpc_id              = module.vpc.vpc_id
#   private_subnet_ids  = module.vpc.private_subnet_ids
#   instance_class      = var.docdb_instance_class
#   instance_count      = var.docdb_cluster_size
#   engine_version      = "5.0"
#   master_username     = "docdbadmin"
#   backup_retention_period = 1
#   node_security_group_id = module.eks.node_security_group_id
#   tags                = local.common_tags
# }

# Amazon MQ (RabbitMQ)
module "mq" {
  source = "./modules/mq"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  instance_type       = var.mq_instance_type
  engine_version      = "3.13"
  admin_username      = "mqadmin"
  node_security_group_id = module.eks.node_security_group_id
  tags                = local.common_tags
}
