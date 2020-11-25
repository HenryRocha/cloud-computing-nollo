#===================================================================================
# Template file and User Data for frontend Wireguard.
#===================================================================================
data "template_file" "frontend_wireguard_user_data" {
  # Uses the "setup-frontend-wireguard.sh" script as a base, while passing
  # variables to it.
  template   = file("./startup-scripts/setup-frontend-wireguard.sh")
  depends_on = [module.backend_wireguard]
  vars = {
    WG_FE_SERVER_PVK = var.WG_FE_SERVER_PVK
    WG_BE_SERVER_PBK = var.WG_BE_SERVER_PBK
    WG_BE_SERVER_IP  = module.backend_wireguard.public_ip[0]
  }
}

output "frontend_wireguard_user_data_script" {
  # Outputs the complete user data.
  value = data.template_file.frontend_wireguard_user_data.rendered
}

#===================================================================================
# The default security group for frontend Wireguard.
#===================================================================================
module "frontend_wireguard_sg" {
  source = "terraform-aws-modules/security-group/aws"
  providers = {
    aws = aws.region_02
  }
  depends_on = [module.frontend_vpc]

  name        = "frontend-wireguard-sg"
  description = "Default wireguard security group."
  vpc_id      = module.frontend_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 51820
      to_port     = 51820
      protocol    = "udp"
      description = "Allow Wireguard from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      description = "Allow Ping from anywhere"
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
    Name  = "frontend-wireguard-sg-component"
  }
}

#===================================================================================
# Frontend Wireguad instance configuration.
#===================================================================================
module "frontend_wireguard" {
  source = "terraform-aws-modules/ec2-instance/aws"
  providers = {
    aws = aws.region_02
  }

  depends_on     = [module.frontend_wireguard_sg, data.aws_ami.ubuntu18_region_02, module.backend_wireguard]
  instance_count = 1

  name                        = "frontend-wireguard"
  ami                         = data.aws_ami.ubuntu18_region_02.id
  instance_type               = "t2.micro"
  subnet_id                   = module.frontend_vpc.public_subnets[0]
  vpc_security_group_ids      = [module.frontend_wireguard_sg.this_security_group_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.henryrocha_legionY740_manjaro_kp_region_02.key_name
  source_dest_check           = false

  user_data = data.template_file.frontend_wireguard_user_data.rendered

  tags = {
    "Owner" = "henryrocha"
    "Name"  = "frontend-wireguard"
  }
}
