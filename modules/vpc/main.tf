
module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.7"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_ipv6            = true
  # create_egress_only_igw = true

  enable_dns_hostnames = true
  enable_dns_support   = true


  public_subnet_ipv6_prefixes                    = [0, 1, 2]
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = [3, 4, 5]
  private_subnet_assign_ipv6_address_on_creation = true
  intra_subnet_ipv6_prefixes                     = [6, 7, 8]
  intra_subnet_assign_ipv6_address_on_creation   = true

  map_public_ip_on_launch = true


  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"

  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
  }

  tags = var.tags
}
