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
