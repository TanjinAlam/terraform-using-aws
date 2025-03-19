provider "aws" {
  region = "ap-southeast-1"
}
module "vpc" {
  source = "./modules/vpc/v1"

  vpc_name             = "my-vpc"
  cidr_block           = "10.0.0.0/16"
  nat_gateway          = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_count  = 2
  private_subnet_count = 2
  public_subnet_tags = {
    "my-pub-sub" = "1"
  }

  private_subnet_tags = {
    "my-priv-subnet" = "1"
  }
}

