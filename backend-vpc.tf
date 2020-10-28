# Create a VPC in which the backend and database will reside.
resource "aws_vpc" "backend_vpc" {
  provider             = aws.region_01
  cidr_block           = var.backend_vpc.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.backend_vpc.name
  }
}

# Create an internet gateway for the VPC, so it can access the internet.
resource "aws_internet_gateway" "backend_vpc_gateway" {
  provider = aws.region_01
  vpc_id   = aws_vpc.backend_vpc.id

  tags = {
    Name = var.backend_vpc.gateway_name
  }
}
