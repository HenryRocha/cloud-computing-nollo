#===================================================================================
# Data source to get Ubuntu 18.04 AMI for region 01.
#===================================================================================
data "aws_ami" "ubuntu18_region_01" {
  provider    = aws.region_01
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
# Creating the backend VPC. Uses 3 availability zones, 3 private subnets
# 3 public subnets. Creates only one NAT Gateway, to provide internet connection
# to all private subnets.
#===================================================================================
module "backend_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.region_01
  }

  name            = "backend-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Owner = "henryrocha"
    Name  = "backend-public"
  }

  private_subnet_tags = {
    Owner = "henryrocha"
    Name  = "backend-private"
  }

  private_route_table_tags = {
    Type = "private"
  }

  public_route_table_tags = {
    Type = "public"
  }

  tags = {
    Owner = "henryrocha"
    Name  = "backend-vpc-component"
  }

  vpc_tags = {
    Owner = "henryrocha"
    Name  = "backend-vpc"
  }
}

#===================================================================================
# Add a new route to the private subnet route table. It should point to the
# wireguard instance. This is needed to provide a end-to-end IP location.
#===================================================================================
data "aws_route_table" "backend_route_tables" {
  provider   = aws.region_01
  depends_on = [module.backend_vpc]
  vpc_id     = module.backend_vpc.vpc_id

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

resource "aws_route" "wireguard_gateway_route" {
  provider               = aws.region_01
  depends_on             = [data.aws_route_table.backend_route_tables, module.backend_wireguard]
  route_table_id         = data.aws_route_table.backend_route_tables.id
  destination_cidr_block = "10.10.150.0/24"
  network_interface_id   = module.backend_wireguard.primary_network_interface_id[0]
}
