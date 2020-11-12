data "template_file" "db_user_data" {
  template = file("./startup-scripts/setup-database.sh")
  vars = {
    NOLLO_DB_ADMIN_PW = var.NOLLO_DB_ADMIN_PW
    NOLLO_DB_API_PW   = var.NOLLO_DB_API_PW
  }
}

data "template_file" "nollo_api_user_data" {
  template = file("./startup-scripts/setup-nollo-api.sh")
  vars = {
    NOLLO_API_DSN = var.NOLLO_API_DSN
  }
}

data "template_file" "nollo_site_user_data" {
  template = file("./startup-scripts/setup-nollo-site.sh")
  vars = {
    NOLLO_API_LB_DNS = module.backend_restAPI_elb.this_elb_dns_name
  }
}

output "db_script" {
  value = data.template_file.db_user_data.rendered
}

output "nollo_api_script" {
  value = data.template_file.nollo_api_user_data.rendered
}

output "nollo_site_script" {
  value = data.template_file.nollo_site_user_data.rendered
}
