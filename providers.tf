# Declaring all the providers used for this project.
# To specify which region to use, edit 'providers.tfvars'.
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
