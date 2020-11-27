#===================================================================================
# Template file and User Data for Nollo API.
#===================================================================================
data "template_file" "nollo_api_user_data" {
  # Uses the "setup-nollo-api.sh" script as a base, while passing
  # variables to it.
  template = file("./startup-scripts/setup-nollo-api.sh")
  vars = {
    NOLLO_API_DSN = var.NOLLO_API_DSN
  }
}

output "nollo_api_script" {
  # Outputs the complete user data.
  value = data.template_file.nollo_api_user_data.rendered
}

#===================================================================================
# The default security group for Nollo API. This is the security group used by
# every instance created by the autoscaling group.
#===================================================================================
module "backend_restAPI_sg" {
  source = "terraform-aws-modules/security-group/aws"
  providers = {
    aws = aws.region_01
  }
  depends_on = [module.backend_vpc]

  name        = "backend-restAPI-sg"
  description = "Default restAPI security group."
  vpc_id      = module.backend_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH"
      cidr_blocks = "10.0.0.0/16,10.10.150.0/24,192.168.15.0/24"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP"
      cidr_blocks = "10.0.0.0/16,10.10.150.0/24,192.168.15.0/24"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS"
      cidr_blocks = "10.0.0.0/16,10.10.150.0/24,192.168.15.0/24"
    },
    {
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      description = "Allow Ping from anywhere"
      cidr_blocks = "10.0.0.0/16,10.10.150.0/24,192.168.15.0/24"
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
    Name  = "backend-restAPI-sg-component"
  }
}

#===================================================================================
# Nollo API launch configuration. This is how the instances inside the autoscaling
# group will be based on.
#===================================================================================
resource "aws_launch_configuration" "backend_restAPI_lc" {
  provider   = aws.region_01
  depends_on = [module.backend_restAPI_sg, data.aws_ami.ubuntu18_region_01]

  name_prefix                 = "backend-restAPI-lc-"
  image_id                    = data.aws_ami.ubuntu18_region_01.id
  instance_type               = "t2.micro"
  security_groups             = [module.backend_restAPI_sg.this_security_group_id]
  key_name                    = aws_key_pair.henryrocha_legionY740_manjaro_kp_region_01.key_name
  associate_public_ip_address = false

  user_data = data.template_file.nollo_api_user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

#===================================================================================
# Nollo API autoscaling group.
#===================================================================================
module "backend_restAPI_asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  providers = {
    aws = aws.region_01
  }
  depends_on = [module.backend_vpc, module.backend_restAPI_sg, module.backend_restAPI_elb, data.aws_ami.ubuntu18_region_01]

  name = "backend-restAPI-asg"

  launch_configuration         = aws_launch_configuration.backend_restAPI_lc.name
  create_lc                    = false
  recreate_asg_when_lc_changes = true
  associate_public_ip_address  = false

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
# Scaling Policies for the autoscaling group.
#===================================================================================
resource "aws_autoscaling_policy" "restAPI_up" {
  # Scale up settings. This policy creates an addional instance.
  provider               = aws.region_01
  depends_on             = [module.backend_restAPI_asg]
  name                   = "restAPI_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = module.backend_restAPI_asg.this_autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "restAPI_cpu_alarm_up" {
  # Cloudwatch Alarm. Sets off an alarm when an instance's CPU stays at or above
  # 50% load for at least 120 seconds.
  provider            = aws.region_01
  depends_on          = [module.backend_restAPI_asg, aws_autoscaling_policy.restAPI_up]
  alarm_name          = "restAPI_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = module.backend_restAPI_asg.this_autoscaling_group_name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.restAPI_up.arn]
}

resource "aws_autoscaling_policy" "restAPI_down" {
  # Scale down settings. This policy deletes one instance.
  provider               = aws.region_01
  depends_on             = [module.backend_restAPI_asg]
  name                   = "restAPI_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = module.backend_restAPI_asg.this_autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "restAPI_cpu_alarm_down" {
  # Cloudwatch Alarm. Sets off an alarm when an instance's CPU stays below 10%
  # load for at least 120 seconds.
  provider            = aws.region_01
  depends_on          = [module.backend_restAPI_asg, aws_autoscaling_policy.restAPI_down]
  alarm_name          = "restAPI_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = module.backend_restAPI_asg.this_autoscaling_group_name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.restAPI_down.arn]
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
  internal        = true

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/api/v1/ping"
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

output "restAPI_elb_dns_name" {
  value = module.backend_restAPI_elb.this_elb_dns_name
}
