#===================================================================================
# Data sources to get Ubuntu 18.04 AMI for each zone
#===================================================================================
data "aws_ami" "ubuntu18_region_02" {
  provider    = aws.region_02
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
resource "aws_launch_configuration" "frontend_nolloSite_lc" {
  provider   = aws.region_02
  depends_on = [module.frontend_nolloSite_sg, data.aws_ami.ubuntu18_region_02, module.backend_restAPI_elb]

  name_prefix     = "frontend-nolloSite-lc-"
  image_id        = data.aws_ami.ubuntu18_region_02.id
  instance_type   = "t2.micro"
  security_groups = [module.frontend_nolloSite_sg.this_security_group_id]
  key_name        = aws_key_pair.henryrocha_legionY740_manjaro_kp_region_02.key_name

  user_data = data.template_file.nollo_site_user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

module "frontend_nolloSite_asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  providers = {
    aws = aws.region_02
  }
  depends_on = [module.frontend_vpc, module.frontend_nolloSite_sg, module.frontend_nolloSite_elb, data.aws_ami.ubuntu18_region_02]

  name = "frontend-nolloSite-asg"

  launch_configuration         = aws_launch_configuration.frontend_nolloSite_lc.name
  create_lc                    = false
  recreate_asg_when_lc_changes = true

  security_groups = [module.frontend_nolloSite_sg.this_security_group_id]
  load_balancers  = [module.frontend_nolloSite_elb.this_elb_id]

  # Auto scaling group
  asg_name                  = "frontend-nolloSite-asg"
  vpc_zone_identifier       = module.frontend_vpc.public_subnets
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
      value               = "frontend-nolloSite-asg-component"
      propagate_at_launch = true
    },
  ]
}

#===================================================================================
# Elastic Load Balancer
#===================================================================================
module "frontend_nolloSite_elb" {
  source = "terraform-aws-modules/elb/aws"
  providers = {
    aws = aws.region_02
  }
  depends_on = [module.frontend_vpc, module.frontend_nolloSite_sg]

  name = "frontend-nolloSite-elb"

  subnets         = module.frontend_vpc.public_subnets
  security_groups = [module.frontend_nolloSite_sg.this_security_group_id]
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
    Name  = "frontend-nolloSite-elb"
  }
}

output "nolloSite_elb_dns_name" {
  value = module.frontend_nolloSite_elb.this_elb_dns_name
}
