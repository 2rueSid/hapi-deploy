locals {
  azs  = formatlist("${var.region}%s", ["a", "b"])
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  vpc_name = "hapi-test"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = local.vpc_name
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

resource "aws_default_subnet" "default_az1" {
  availability_zone = local.azs[0]
}
