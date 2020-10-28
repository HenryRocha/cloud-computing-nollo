resource "aws_security_group" "backend_restapi_sg" {
  provider    = aws.region_01
  name        = var.backend_restapi_sg.name
  description = var.backend_restapi_sg.description
  vpc_id      = aws_vpc.backend_vpc.id

  dynamic "ingress" {
    for_each = var.backend_restapi_sg.ingress_list
    content {
      description = ingress.value["description"]
      from_port   = ingress.key
      to_port     = ingress.key
      cidr_blocks = ingress.value["cidr_blocks"]
      protocol    = ingress.value["protocol"]
    }
  }

  dynamic "egress" {
    for_each = var.backend_restapi_sg.egress_list
    content {
      description = egress.value["description"]
      from_port   = egress.key
      to_port     = egress.key
      cidr_blocks = egress.value["cidr_blocks"]
      protocol    = egress.value["protocol"]
    }
  }

  tags = {
    Name = var.backend_restapi_sg.name
  }
}
