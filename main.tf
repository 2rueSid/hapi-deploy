provider "aws" {
  region = var.region
}

locals {
  azs = formatlist("${var.region}%s", ["a", "b"])
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name    = var.name
  version = "5.5.1"
  cidr    = "10.0.0.0/16"

  azs                     = local.azs
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  map_public_ip_on_launch = true

  enable_nat_gateway   = true
  create_igw           = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Hapi = true
    Test = true
  }
}
