# Create a public subnet, which will have access to the internet.
resource "aws_subnet" "backend_public_subnet" {
  provider          = aws.region_01
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.backend_public_subnet.cidr
  availability_zone = var.backend_public_subnet.availability_zone

  tags = {
    Name = var.backend_public_subnet.subnet_name
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
    Name = var.backend_public_subnet.route_table_name
  }
}

# Associate the public route table with the public subnet.
resource "aws_route_table_association" "backend_public_route_table_association" {
  provider       = aws.region_01
  subnet_id      = aws_subnet.backend_public_subnet.id
  route_table_id = aws_route_table.backend_public_route_table.id
}
