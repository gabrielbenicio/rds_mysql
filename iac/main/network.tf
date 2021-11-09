module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name                 = "${var.project}-documents"
  cidr                 = "10.99.0.0/18"
  enable_dns_hostnames = true

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  create_database_subnet_group = true

  tags = var.tags
}