module "backend_database" {
  source = "terraform-aws-modules/ec2-instance/aws"
  providers = {
    aws = aws.region_01
  }

  depends_on     = [module.backend_database_sg, data.aws_ami.ubuntu18]
  instance_count = 1

  name                        = "backend-database"
  ami                         = data.aws_ami.ubuntu18.id
  instance_type               = "t2.micro"
  subnet_id                   = module.backend_vpc.private_subnets[0]
  private_ips                 = ["10.0.1.5"]
  vpc_security_group_ids      = [module.backend_database_sg.this_security_group_id]
  associate_public_ip_address = false

  user_data = file("./startup-scripts/setup-database.sh")

  tags = {
    "Owner" = "henryrocha"
    "Name"  = "backend-database"
  }
}
