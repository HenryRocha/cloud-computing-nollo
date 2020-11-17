#===================================================================================
# Template file and User Data for Nollo DB.
#===================================================================================
data "template_file" "db_user_data" {
  # Uses the "setup-database.sh" script as a base, while passing
  # variables to it.
  template = file("./startup-scripts/setup-database.sh")
  vars = {
    NOLLO_DB_ROOT_PW  = var.NOLLO_DB_ROOT_PW
    NOLLO_DB_ADMIN_PW = var.NOLLO_DB_ADMIN_PW
    NOLLO_DB_API_PW   = var.NOLLO_DB_API_PW
  }
}

output "db_user_data_script" {
  # Outputs the complete user data.
  value = data.template_file.db_user_data.rendered
}

#===================================================================================
# The default security group for Nollo DB. This is the security group used by
# the database instance.
#===================================================================================
module "backend_database_sg" {
  source = "terraform-aws-modules/security-group/aws"
  providers = {
    aws = aws.region_01
  }
  depends_on = [module.backend_vpc]

  name        = "backend-database-sg"
  description = "Default database security group."
  vpc_id      = module.backend_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      description = "Allow Ping from within VPC"
      cidr_blocks = "10.0.0.0/16"
    },
  ]

  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from public subnets"
      cidr_blocks = join(",", module.backend_vpc.public_subnets_cidr_blocks)
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP from public subnets"
      cidr_blocks = join(",", module.backend_vpc.public_subnets_cidr_blocks)
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS from public subnets"
      cidr_blocks = join(",", module.backend_vpc.public_subnets_cidr_blocks)
    },
  ]
  number_of_computed_ingress_with_cidr_blocks = 3

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
    Name  = "backend-database-sg-component"
  }
}

#===================================================================================
# Nollo DB instance configuration.
#===================================================================================
module "backend_database" {
  source = "terraform-aws-modules/ec2-instance/aws"
  providers = {
    aws = aws.region_01
  }

  depends_on     = [module.backend_database_sg, data.aws_ami.ubuntu18_region_01]
  instance_count = 1

  name                        = "backend-database"
  ami                         = data.aws_ami.ubuntu18_region_01.id
  instance_type               = "t2.micro"
  subnet_id                   = module.backend_vpc.private_subnets[0]
  private_ips                 = ["10.0.1.5"]
  vpc_security_group_ids      = [module.backend_database_sg.this_security_group_id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.henryrocha_legionY740_manjaro_kp_region_01.key_name

  user_data = data.template_file.db_user_data.rendered

  tags = {
    "Owner" = "henryrocha"
    "Name"  = "backend-database"
  }
}
