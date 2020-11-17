# Declaring the secret variables. Do not place their real value here,
# instead, create a 'secrets.tfvars' file and append all Terraform
# commands with '-var-file=./secrets.tfvars'.
variable "AWS_ACCESS_KEY_ID" {
  default = "placeholder"
}

variable "AWS_SECRET_ACCESS_KEY" {
  default = "placeholder"
}

variable "NOLLO_DB_ROOT_PW" {
  type    = string
  default = "placeholder"
}

variable "NOLLO_DB_ADMIN_PW" {
  type    = string
  default = "placeholder"
}

variable "NOLLO_DB_API_PW" {
  type    = string
  default = "placeholder"
}

variable "NOLLO_API_DSN" {
  type    = string
  default = "placeholder"
}
