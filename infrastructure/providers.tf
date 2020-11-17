variable "region_01" {
  default = "us-east-1"
}

variable "region_02" {
  default = "us-east-2"
}

provider "aws" {
  alias      = "region_01"
  region     = var.region_01
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "aws" {
  alias      = "region_02"
  region     = var.region_02
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
