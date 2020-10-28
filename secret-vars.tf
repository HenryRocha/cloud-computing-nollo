# Declaring the secret variables. Do not place their real value here,
# instead, create a 'secrets.tfvars' file and append all Terraform
# commands with '-var-file=./secrets.tfvars'.
variable "AWS_ACCESS_KEY_ID" {
  default = "placeholder"
}

variable "AWS_SECRET_ACCESS_KEY" {
  default = "placeholder"
}
