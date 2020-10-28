# Create a public subnet, so the backend can have access to the internet.
resource "aws_subnet" "backend_public_subnet" {
  provider          = aws.region_01
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.backend_public_subnet_cidr
  availability_zone = var.backend_public_subnet_az

  tags = {
    Name = "henry-backend-public-subnet"
  }
}

# Create a route table for the public subnet.
resource "aws_route_table" "backend_public_route_table" {
  provider = aws.region_01
  vpc_id   = aws_vpc.backend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.backend_vpc_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.backend_vpc_gateway.id
  }

  tags = {
    Name = "henry-backend-public-route-table"
  }
}

# Associate the public route table with the public subnet.
resource "aws_route_table_association" "backend_public_route_table_association" {
  provider       = aws.region_01
  subnet_id      = aws_subnet.backend_public_subnet.id
  route_table_id = aws_route_table.backend_public_route_table.id
}

# Create a private NAT-ed subnet, in which the backend database will reside.
resource "aws_subnet" "backend_private_subnet" {
  provider          = aws.region_01
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.backend_private_subnet_cidr
  availability_zone = var.backend_private_subnet_az

  tags = {
    Name = "henry-backend-private-subnet"
  }
}

# Create a NAT gateway on the public subnet.
resource "aws_nat_gateway" "backend_private_subnet_nat_gw" {
  provider      = aws.region_01
  allocation_id = aws_eip.backend_private_subnet_gw_eip.id
  subnet_id     = aws_subnet.backend_public_subnet.id

  tags = {
    Name = "henry-backend-private-subnet-nat-gw"
  }
}

# Assign the NAT gateway an elastic IP.
resource "aws_eip" "backend_private_subnet_gw_eip" {
  provider = aws.region_01
  vpc      = true

  tags = {
    Name = "henry-backend-private-subnet-nat-gw-eip"
  }
}

# Create a route table for the private subnet.
resource "aws_route_table" "backend_private_route_table" {
  provider   = aws.region_01
  vpc_id     = aws_vpc.backend_vpc.id
  depends_on = [aws_eip.backend_private_subnet_gw_eip]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.backend_private_subnet_nat_gw.id
  }

  tags = {
    Name = "henry-backend-private-route-table"
  }
}

# Associate the private subnet with it's route table.
resource "aws_route_table_association" "backend_private_route_table_association" {
  provider       = aws.region_01
  subnet_id      = aws_subnet.backend_private_subnet.id
  route_table_id = aws_route_table.backend_private_route_table.id
}
