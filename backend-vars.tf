# VPC variables
variable "backend_vpc_name" {
  default = "henry-backend-vpc"
}

variable "backend_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "backend_vpc_gateway_name" {
  default = "henry-backend-vpc-gateway"
}

# Public Subnet
variable "backend_public_subnet_az" {
  default = "us-east-1a"
}

variable "backend_public_subnet_cidr" {
  default = "10.0.0.0/24"
}
# Private NAT-ed Subnet
variable "backend_private_subnet_az" {
  default = "us-east-1a"
}

variable "backend_private_subnet_cidr" {
  default = "10.0.1.0/24"
}

# Security groups
variable "backend_restapi_sg_name" {
  default = "backend-restapi-sg"
}

variable "backend_restapi_sg_description" {
  default = "Allow HTTP, HTTPS, SSH and all outgoing."
}

variable "backend_database_sg_name" {
  default = "backend-default-sg"
}

variable "backend_database_sg_description" {
  default = "Allow HTTP, HTTPS, SSH only from VPC and all outgoing."
}

# RestAPI instance
variable "backend_restapi_private_ip" {
  default = "10.0.0.10"
}

variable "backend_restapi_instance_name" {
  default = "henry-backend-restapi"
}

variable "backend_restapi_instance_type" {
  default = "t2.micro"
}

variable "backend_restapi_instance_ami" {
  default = "ami-0817d428a6fb68645"
}

variable "backend_restapi_count" {
  default = 1
}

# Database instance
variable "backend_database_private_ip" {
  default = "10.0.1.10"
}

variable "backend_database_instance_name" {
  default = "henry-backend-database"
}

variable "backend_database_instance_type" {
  default = "t2.micro"
}

variable "backend_database_instance_ami" {
  default = "ami-0817d428a6fb68645"
}

variable "backend_database_count" {
  default = 1
}
