# VPC variables.
variable "backend_vpc" {
  type = object({
    name         = string,
    cidr         = string,
    gateway_name = string
  })

  default = {
    name         = "henry-backend-vpc"
    cidr         = "10.0.0.0/16"
    gateway_name = "henry-backend-vpc-gateway"
  }
}

# Public Subnet variables.
variable "backend_public_subnet" {
  type = object({
    subnet_name       = string,
    availability_zone = string,
    cidr              = string,
    route_table_name  = string
  })

  default = {
    subnet_name       = "henry-backend-public-subnet"
    availability_zone = "us-east-1a"
    cidr              = "10.0.0.0/24"
    route_table_name  = "henry-backend-public-route-table"
  }
}

# Private Subnet
variable "backend_private_subnet" {
  type = object({
    subnet_name       = string,
    availability_zone = string,
    cidr              = string,
    route_table_name  = string,
    nat_gw_name       = string,
    nat_gw_eip_name   = string
  })

  default = {
    subnet_name       = "henry-backend-private-subnet"
    availability_zone = "us-east-1a"
    cidr              = "10.0.1.0/24"
    route_table_name  = "henry-backend-private-route-table"
    nat_gw_name       = "henry-backend-private-subnet-nat-gw"
    nat_gw_eip_name   = "henry-backend-private-subnet-nat-gw-eip"
  }
}

# Security groups
variable "backend_restapi_sg" {
  type = object({
    name        = string,
    description = string,
    ingress_list = map(object({
      description = string,
      cidr_blocks = list(string),
      protocol    = string
    })),
    egress_list = map(object({
      description = string,
      cidr_blocks = list(string),
      protocol    = string
    }))
  })

  default = {
    name        = "henry-backend-restAPI-sg"
    description = "RestAPI default security group."
    ingress_list = {
      22 = {
        description = "Allow SSH",
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = "tcp"
      }
      80 = {
        description = "Allow HTTP",
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = "tcp"
      }
      81 = {
        description = "Allow NPM Dashboard",
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = "tcp"
      }
      443 = {
        description = "Allow HTTPS",
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = "tcp"
      }
    }
    egress_list = {
      0 = {
        description = "Allow all outgoing traffic.",
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = "-1"
      }
    }
  }
}

variable "backend_database_sg" {
  type = object({
    name        = string,
    description = string,
    ingress_list = map(object({
      description = string,
      cidr_blocks = list(string),
      protocol    = string
    })),
    egress_list = map(object({
      description = string,
      cidr_blocks = list(string),
      protocol    = string
    }))
  })

  default = {
    name        = "henry-backend-database-sg"
    description = "Database default security group."
    ingress_list = {
      22 = {
        description = "Allow SSH",
        cidr_blocks = ["10.0.0.0/16"]
        protocol    = "tcp"
      }
      80 = {
        description = "Allow HTTP",
        cidr_blocks = ["10.0.0.0/16"]
        protocol    = "tcp"
      }
      443 = {
        description = "Allow HTTPS",
        cidr_blocks = ["10.0.0.0/16"]
        protocol    = "tcp"
      }
    }
    egress_list = {
      0 = {
        description = "Allow all outgoing traffic.",
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = "-1"
      }
    }
  }
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
