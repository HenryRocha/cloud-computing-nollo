data "aws_subnet_ids" "backend_all_public_subnets" {
  provider = aws.region_01
  vpc_id   = aws_vpc.backend_vpc.id
  filter {
    name   = "tag:Name"
    values = var.backend_public_subnet.subnet_name
  }
}

resource "aws_lb" "backend_restapi_elb" {
  provider           = aws.region_01
  name               = var.backend_restapi_elb.name
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  subnets            = data.aws_subnet_ids.backend_all_public_subnets.ids

  enable_deletion_protection = true

  tags = {
    Name = var.backend_restapi_elb.name
  }
}

resource "aws_lb_target_group" "backend_restapi_elb_tg" {
  provider = aws.region_01
  vpc_id   = aws_vpc.backend_vpc.id

  name        = var.backend_restapi_elb.tg_name
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}
