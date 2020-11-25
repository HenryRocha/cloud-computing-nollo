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
  cidr            = "10.20.0.0/16"
  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  public_subnets  = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]

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

  private_route_table_tags = {
    Type = "private"
  }

  public_route_table_tags = {
    Type = "public"
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

#===================================================================================
# Add a new route to the public subnets route table. It should point to the
# wireguard instance. This is needed to provide a end-to-end IP location.
#===================================================================================
data "aws_route_table" "frontend_route_tables" {
  provider   = aws.region_02
  depends_on = [module.frontend_vpc]
  vpc_id     = module.frontend_vpc.vpc_id

  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

resource "aws_route" "frontend_wireguard_gateway_route" {
  provider               = aws.region_02
  depends_on             = [data.aws_route_table.frontend_route_tables, module.frontend_wireguard]
  route_table_id         = data.aws_route_table.frontend_route_tables.id
  destination_cidr_block = "10.10.150.0/24"
  network_interface_id   = module.frontend_wireguard.primary_network_interface_id[0]
}
