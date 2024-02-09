provider "aws" {
  region = var.region
}

locals {
  azs  = formatlist("${var.region}%s", ["a", "b"])
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  cluster_name = "hapi-jpa"

  namespace = "hapi-app"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.name
  version         = "5.5.1"
  cidr            = local.cidr
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  create_igw              = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = {
    Hapi = true
    Test = true
  }
}

module "eks" {
  source                   = "terraform-aws-modules/eks/aws"
  version                  = "20.2.0"
  cluster_name             = local.cluster_name
  cluster_version          = "1.27"
  control_plane_subnet_ids = module.vpc.intra_subnets
  subnet_ids               = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    attach_cluster_primary_security_group = true
    capacity_type                         = "SPOT"
  }
  eks_managed_node_groups = {
    hapi-app-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"

    }

    hapi-db-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"

    }
  }

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id

}
#
# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }
#
# resource "kubernetes_deployment" "db" {
#   metadata {
#     name = "db"
#   }
#
#   spec {
#     replicas = 1
#
#     selector {
#       match_labels = {
#         app = "db"
#       }
#     }
#
#     template {
#       metadata {
#         labels = {
#           app = "db"
#         }
#       }
#
#       spec {
#         container {
#           name              = "db"
#           image             = "postgres"
#           image_pull_policy = "IfNotPresent"
#
#           env {
#             name  = "POSTGRES_PASSWORD"
#             value = "admin"
#           }
#
#           env {
#             name  = "POSTGRES_USER"
#             value = "admin"
#           }
#
#           env {
#             name  = "POSTGRES_DB"
#             value = "hapi"
#           }
#
#           volume_mount {
#             mount_path = "/var/lib/postgresql/data"
#             name       = "db-data"
#           }
#         }
#
#         volume {
#           name = "db-data"
#
#           persistent_volume_claim {
#             claim_name = "db-pvc"
#           }
#         }
#       }
#     }
#   }
# }
#
# resource "kubernetes_service" "db" {
#   metadata {
#     name = "db"
#   }
#
#   spec {
#     type = "LoadBalancer"
#     port {
#       port        = 5432
#       target_port = 5432
#     }
#
#     selector = {
#       app = "db"
#     }
#   }
#
# }
#
# resource "kubernetes_persistent_volume_claim" "db_pvc" {
#   metadata {
#     name = "db-pvc"
#   }
#
#   spec {
#     access_modes = ["ReadWriteOnce"]
#
#     resources {
#       requests = {
#         storage = "1Gi"
#       }
#     }
#   }
# }


# resource "kubernetes_config_map" "hapi_config" {
#   metadata {
#     name      = "hapi-config"
#     namespace = kubernetes_namespace.hapi-app.metadata[0].name
#   }
#
#   data = {
#     "application.yaml" = <<EOF
# spring:
#   datasource:
#     url: 'jdbc:postgresql://db:5432/hapi'
#     username: admin
#     password: admin
#     driverClassName: org.postgresql.Driver
#   jpa:
#     properties:
#       hibernate.dialect: ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgres94Dialect
# EOF
#   }
# }
#
#
# resource "kubernetes_service" "fhir_service" {
#   metadata {
#     name      = "fhir-service"
#     namespace = kubernetes_namespace.hapi-app.metadata[0].name
#   }
#
#   spec {
#     selector = {
#       app = "fhir"
#     }
#
#     type = "NodePort"
#
#     port {
#       port        = 8080
#       target_port = 8080
#       node_port   = 30080
#     }
#   }
# }
# resource "kubernetes_deployment" "fhir" {
#   metadata {
#     name      = "fhir"
#     namespace = kubernetes_namespace.hapi-app.metadata[0].name
#   }
#
#   spec {
#     replicas = 1
#
#     selector {
#       match_labels = {
#         app = "fhir"
#       }
#     }
#
#     template {
#       metadata {
#         labels = {
#           app = "fhir"
#         }
#       }
#
#       spec {
#         container {
#           name  = "fhir"
#           image = "hapiproject/hapi:latest"
#           port {
#             container_port = 8080
#           }
#
#           volume_mount {
#             mount_path = "/app/config/application.yaml"
#             name       = "hapi-config"
#             sub_path   = "application.yaml"
#           }
#         }
#
#         volume {
#           name = "hapi-config"
#
#           config_map {
#             name = kubernetes_config_map.hapi_config.metadata[0].name
#           }
#         }
#       }
#     }
#   }
# }
