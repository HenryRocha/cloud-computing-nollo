module "backend_database_sg" {
  source = "terraform-aws-modules/security-group/aws"
  providers = {
    aws = aws.region_01
  }
  depends_on = [module.backend_vpc]

  name        = "backend-database-sg"
  description = "Default database security group."
  vpc_id      = module.backend_vpc.vpc_id

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
