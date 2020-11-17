#===================================================================================
# Data sources to get Ubuntu 18.04 AMI for region 02.
#===================================================================================
data "aws_ami" "ubuntu18_region_02" {
  provider    = aws.region_02
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#===================================================================================
# Creating the frontend VPC. Uses 3 availability zones, 3 private subnets
# 3 public subnets
#===================================================================================
module "frontend_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.region_02
  }

  name            = "frontend-vpc"
  cidr            = "20.0.0.0/16"
  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["20.0.1.0/24", "20.0.2.0/24", "20.0.3.0/24"]
  public_subnets  = ["20.0.101.0/24", "20.0.102.0/24", "20.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Owner = "henryrocha"
    Name  = "frontend-public"
  }

  private_subnet_tags = {
    Owner = "henryrocha"
    Name  = "frontend-private"
  }

  tags = {
    Owner = "henryrocha"
    Name  = "frontend-vpc-component"
  }

  vpc_tags = {
    Owner = "henryrocha"
    Name  = "frontend-vpc"
  }
}
