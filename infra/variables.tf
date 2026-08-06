locals {
  nginx_config                 = file("${path.module}/nginx/nginx.conf")
  nginx_config_mount_path      = "/etc/nginx/conf.d/default.conf"
  hh_ui_build_context          = "${path.module}/../ui"
  hh_api_build_context         = "${path.module}/../api"
  ingress_cert_validtity_hours = 2160 # valid for 90 days
  ingress_early_renewal_hours  = 720  # window for renewal
}
