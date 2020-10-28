resource "aws_network_interface" "backend_restapi_nic" {
  provider        = aws.region_01
  subnet_id       = aws_subnet.backend_public_subnet.id
  private_ips     = [var.backend_restapi_private_ip]
  security_groups = [aws_security_group.backend_restapi_sg.id]

  tags = {
    Name = "henry-backend-restapi-nic"
  }
}

resource "aws_eip" "backend_restapi_elasticip" {
  provider                  = aws.region_01
  vpc                       = true
  network_interface         = aws_network_interface.backend_restapi_nic.id
  associate_with_private_ip = var.backend_restapi_private_ip
  depends_on                = [aws_internet_gateway.backend_vpc_gateway, aws_instance.backend_restapi]

  tags = {
    Name = "henry-backend-restapi-eip"
  }
}

resource "aws_instance" "backend_restapi" {
  provider      = aws.region_01
  count         = var.backend_restapi_count
  ami           = var.backend_restapi_instance_ami
  instance_type = var.backend_restapi_instance_type
  key_name      = aws_key_pair.henryrocha_legionY740_manjaro_kp.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.backend_restapi_nic.id
  }

  user_data = file("./install_docker.sh")

  tags = {
    Name = var.backend_restapi_instance_name
  }
}
