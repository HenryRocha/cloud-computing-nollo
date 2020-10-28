# Create a private subnet, which will only have outgoing access to the internet.
resource "aws_subnet" "backend_private_subnet" {
  provider          = aws.region_01
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.backend_private_subnet.cidr
  availability_zone = var.backend_private_subnet.availability_zone

  tags = {
    Name = var.backend_private_subnet.subnet_name
  }
}

# Create a NAT gateway on the private subnet.
resource "aws_nat_gateway" "backend_private_subnet_nat_gw" {
  provider      = aws.region_01
  allocation_id = aws_eip.backend_private_subnet_gw_eip.id
  subnet_id     = aws_subnet.backend_public_subnet.id

  tags = {
    Name = var.backend_private_subnet.nat_gw_name
  }
}

# Assign an elastic IP to the NAT gateway.
resource "aws_eip" "backend_private_subnet_gw_eip" {
  provider = aws.region_01
  vpc      = true

  tags = {
    Name = var.backend_private_subnet.nat_gw_eip_name
  }
}

# Create a route table for the private subnet.
resource "aws_route_table" "backend_private_route_table" {
  provider = aws.region_01
  vpc_id   = aws_vpc.backend_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.backend_private_subnet_nat_gw.id
  }

  tags = {
    Name = var.backend_private_subnet.route_table_name
  }
}

# Associate the private subnet with it's route table.
resource "aws_route_table_association" "backend_private_route_table_association" {
  provider       = aws.region_01
  subnet_id      = aws_subnet.backend_private_subnet.id
  route_table_id = aws_route_table.backend_private_route_table.id
}
