resource "aws_launch_configuration" "backend_restapi_launch_config" {
  provider        = aws.region_01
  ami             = var.backend_restapi_instance_ami
  instance_type   = var.backend_restapi_instance_type
  security_groups = [aws_security_group.backend_restapi_sg.id]
  key_name        = aws_key_pair.henryrocha_legionY740_manjaro_kp.key_name

  lifecycle {
    create_before_destroy = true
  }

  user_data = file("./install_docker.sh")

  tags = {
    Name = var.backend_restapi_instance_name
  }
}

data "aws_availability_zones" "all" {
  resource "aws_autoscaling_group" "test-asg" {
    launch_configuration = aws_launch_configuration.backend_restapi_launch_config.id
    availability_zones   = [data.aws_availability_zones.all.names
    target_group_arns    = ["${var.target_group_arn}"]
    health_check_type    = "ELB"
    min_size             = "1"
    max_size             = "2"
    tag {
      key                 = "Name"
      propagate_at_launch = true
      value               = "my-terraform-asg-example"
    }
  }
}
