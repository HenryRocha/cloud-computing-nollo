#===================================================================================
# Template file and User Data for Nollo API
#===================================================================================
data "template_file" "nollo_site_user_data" {
  depends_on = [module.backend_restAPI_elb, module.frontend_nolloSite_elb]
  template   = file("./startup-scripts/setup-nollo-site.sh")
  vars = {
    NOLLO_API_LB_DNS  = module.backend_restAPI_elb.this_elb_dns_name
    NOLLO_SITE_LB_DNS = module.frontend_nolloSite_elb.this_elb_dns_name
  }
}

output "nollo_site_script" {
  value = data.template_file.nollo_site_user_data.rendered
}

#===================================================================================
# Autoscaling group security group
#===================================================================================
module "frontend_nolloSite_sg" {
  source = "terraform-aws-modules/security-group/aws"
  providers = {
    aws = aws.region_02
  }
  depends_on = [module.frontend_vpc]

  name        = "frontend-nolloSite-sg"
  description = "Default nolloSite security group."
  vpc_id      = module.frontend_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outgoing traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Owner = "henryrocha"
    Name  = "frontend-nolloSite-sg-component"
  }
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
# Scaling Policies for the Autoscaling Group
#===================================================================================
# Scale up settings.
resource "aws_autoscaling_policy" "nolloSite_up" {
  provider               = aws.region_02
  depends_on             = [module.frontend_nolloSite_asg]
  name                   = "nolloSite_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = module.frontend_nolloSite_asg.this_autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "nolloSite_cpu_alarm_up" {
  provider            = aws.region_02
  depends_on          = [module.frontend_nolloSite_asg, aws_autoscaling_policy.nolloSite_up]
  alarm_name          = "nolloSite_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = module.frontend_nolloSite_asg.this_autoscaling_group_name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.nolloSite_up.arn]
}

# Scale down settings.
resource "aws_autoscaling_policy" "nolloSite_down" {
  provider               = aws.region_02
  depends_on             = [module.frontend_nolloSite_asg]
  name                   = "nolloSite_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = module.frontend_nolloSite_asg.this_autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "nolloSite_cpu_alarm_down" {
  provider            = aws.region_02
  depends_on          = [module.frontend_nolloSite_asg, aws_autoscaling_policy.nolloSite_down]
  alarm_name          = "nolloSite_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = module.frontend_nolloSite_asg.this_autoscaling_group_name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.nolloSite_down.arn]
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
