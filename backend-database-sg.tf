resource "aws_security_group" "backend_database_sg" {
  provider    = aws.region_01
  name        = var.backend_database_sg_name
  description = var.backend_database_sg_description
  vpc_id      = aws_vpc.backend_vpc.id

  tags = {
    Name = var.backend_database_sg_name
  }
}

resource "aws_security_group_rule" "backend_database_allow_all_outgoing" {
  provider          = aws.region_01
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend_database_sg.id
}

resource "aws_security_group_rule" "backend_database_allow_http" {
  provider          = aws.region_01
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.backend_vpc_cidr]
  security_group_id = aws_security_group.backend_database_sg.id
}

resource "aws_security_group_rule" "backend_database_allow_https" {
  provider          = aws.region_01
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.backend_vpc_cidr]
  security_group_id = aws_security_group.backend_database_sg.id
}

resource "aws_security_group_rule" "backend_database_allow_ssh" {
  provider          = aws.region_01
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.backend_vpc_cidr]
  security_group_id = aws_security_group.backend_database_sg.id
}
