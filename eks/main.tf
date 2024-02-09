locals {
  cluster_name = "hapi-jpa"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_private_access = true
  cluster_ip_family               = "ipv4"

  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  vpc_id                   = var.vpc_id
  control_plane_subnet_ids = var.intra_subnets
  subnet_ids               = var.private_subnets

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = ["t3.medium"]
    iam_role_attach_cni_policy = true

    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = var.sg_ids
    subnet_ids                            = var.private_subnets
  }
  eks_managed_node_groups = {
    hapi-app-wg = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

    }
  }

}


module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
