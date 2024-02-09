provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.aws_eks_cluster_auth)
  token                  = module.eks.cluster_token
}

locals {
  engine         = "postgres"
  engine_version = "14"
  instance_class = "db.t3.micro"
  db_name        = "hapi"
  db_username    = "admin"
  password       = "admin"

}

module "vpc" {
  source = "./vpc"
  region = var.region

  providers = {
    aws = aws
  }
}

module "sg" {
  depends_on      = [module.vpc]
  source          = "./sg"
  private_sb_cidr = module.vpc.private_subnets_cidr_blocks
  vpc_id          = module.vpc.vpc_id

  providers = {
    aws = aws
  }
}

module "rds" {
  source         = "./rds"
  depends_on     = [module.sg, module.vpc]
  vpc_sg_ids     = module.sg.rds_sg_id
  storage        = 10
  engine         = local.engine
  engine_version = local.engine_version
  instance_class = local.instance_class
  db_name        = local.db_name
  db_username    = local.db_username
  password       = local.password

  providers = {
    aws = aws
  }
}

module "eks" {
  depends_on = [module.vpc, module.sg, module.rds]
  source     = "./eks"

  private_subnets = module.vpc.private_subnets
  sg_ids          = module.sg.eks_sg_id
  intra_subnets   = module.vpc.intra_subnets
  vpc_id          = module.vpc.vpc_id

  providers = {
    aws = aws
  }
}

module "k8s" {
  depends_on  = [module.eks]
  source      = "./k8s"
  db_host     = module.rds.db_host
  db_name     = local.db_name
  db_username = local.db_username
  db_engine   = local.engine
  db_port     = "5432"
  db_password = local.password

  providers = {
    kubernetes = kubernetes
  }
}
