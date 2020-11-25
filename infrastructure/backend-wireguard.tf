#===================================================================================
# Template file and User Data for backend Wireguard.
#===================================================================================
data "template_file" "backend_wireguard_user_data" {
  # Uses the "setup-backend-wireguard.sh" script as a base, while passing
  # variables to it.
  template = file("./startup-scripts/setup-backend-wireguard.sh")
  vars = {
    WG_BE_SERVER_PVK = var.WG_BE_SERVER_PVK
    WG_FE_SERVER_PBK = var.WG_FE_SERVER_PBK
    WG_ADMIN_PBK     = var.WG_ADMIN_PBK
  }
}

output "backend_wireguard_user_data_script" {
  # Outputs the complete user data.
  value = data.template_file.backend_wireguard_user_data.rendered
}

#===================================================================================
# The default security group for backend Wireguard.
#===================================================================================
module "backend_wireguard_sg" {
  source = "terraform-aws-modules/security-group/aws"
  providers = {
    aws = aws.region_01
  }
  depends_on = [module.backend_vpc]

  name        = "backend-wireguard-sg"
  description = "Default wireguard security group."
  vpc_id      = module.backend_vpc.vpc_id

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
    Name  = "backend-wireguard-sg-component"
  }
}

#===================================================================================
# Backend Wireguad instance configuration.
#===================================================================================
module "backend_wireguard" {
  source = "terraform-aws-modules/ec2-instance/aws"
  providers = {
    aws = aws.region_01
  }

  depends_on     = [module.backend_wireguard_sg, data.aws_ami.ubuntu18_region_01]
  instance_count = 1

  name                        = "backend-wireguard"
  ami                         = data.aws_ami.ubuntu18_region_01.id
  instance_type               = "t2.micro"
  subnet_id                   = module.backend_vpc.public_subnets[0]
  private_ips                 = ["10.0.101.9"]
  vpc_security_group_ids      = [module.backend_wireguard_sg.this_security_group_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.henryrocha_legionY740_manjaro_kp_region_01.key_name
  source_dest_check           = false

  user_data = data.template_file.backend_wireguard_user_data.rendered

  tags = {
    "Owner" = "henryrocha"
    "Name"  = "backend-wireguard"
  }
}
