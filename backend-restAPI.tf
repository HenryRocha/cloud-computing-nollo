#===================================================================================
# Data sources to get Ubuntu 18.04 AMI for each zone
#===================================================================================
data "aws_ami" "ubuntu18" {
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
# Launch configuration and autoscaling group
#===================================================================================
resource "aws_launch_configuration" "backend_restAPI_lc" {
  provider   = aws.region_01
  depends_on = [module.backend_restAPI_sg, data.aws_ami.ubuntu18]

  name_prefix     = "backend-restAPI-lc-"
  image_id        = data.aws_ami.ubuntu18.id
  instance_type   = "t2.micro"
  security_groups = [module.backend_restAPI_sg.this_security_group_id]
  key_name        = aws_key_pair.henryrocha_legionY740_manjaro_kp.key_name

  user_data = file("./install_docker.sh")

  lifecycle {
    create_before_destroy = true
  }
}

module "backend_restAPI_asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  providers = {
    aws = aws.region_01
  }
  depends_on = [module.backend_vpc, module.backend_restAPI_sg, module.backend_restAPI_elb, data.aws_ami.ubuntu18]

  name = "backend-restAPI-asg"

  launch_configuration         = aws_launch_configuration.backend_restAPI_lc.name
  create_lc                    = false
  recreate_asg_when_lc_changes = true

  security_groups = [module.backend_restAPI_sg.this_security_group_id]
  load_balancers  = [module.backend_restAPI_elb.this_elb_id]

  # Auto scaling group
  asg_name                  = "backend-restAPI-asg"
  vpc_zone_identifier       = module.backend_vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = null
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Owner"
      value               = "henryrocha"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "backend-restAPI-asg-component"
      propagate_at_launch = true
    },
  ]
}

#===================================================================================
# Elastic Load Balancer
#===================================================================================
module "backend_restAPI_elb" {
  source = "terraform-aws-modules/elb/aws"
  providers = {
    aws = aws.region_01
  }
  depends_on = [module.backend_vpc, module.backend_restAPI_sg]

  name = "backend-restAPI-elb"

  subnets         = module.backend_vpc.public_subnets
  security_groups = [module.backend_restAPI_sg.this_security_group_id]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 15
  }

  tags = {
    Owner = "henryrocha"
    Name  = "backend-restAPI-elb"
  }
}
