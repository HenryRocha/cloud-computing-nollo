resource "aws_network_interface" "backend_database_nic" {
  provider        = aws.region_01
  subnet_id       = aws_subnet.backend_private_subnet.id
  private_ips     = [var.backend_database_private_ip]
  security_groups = [aws_security_group.backend_database_sg.id]

  tags = {
    Name = "henry-backend-database-nic"
  }
}

resource "aws_instance" "backend_database" {
  provider      = aws.region_01
  count         = var.backend_database_count
  ami           = var.backend_database_instance_ami
  instance_type = var.backend_database_instance_type
  key_name      = aws_key_pair.henryrocha_legionY740_manjaro_kp.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.backend_database_nic.id
  }

  user_data = file("./install_docker.sh")

  tags = {
    Name = var.backend_database_instance_name
  }
}
