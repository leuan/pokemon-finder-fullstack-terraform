locals {
  nginx_config                = file("${path.module}/nginx/nginx.conf")
  nginx_config_mount_path     = "/etc/nginx/conf.d/default.conf"
  hh_ui_build_context         = "${path.module}/../ui"
  hh_api_build_context        = "${path.module}/../api"
  ingress_early_renewal_hours = 720 # window for renewal
}

variable "ingress_hostname" {
  type        = string
  description = "Public facing hostname or IP for the Nginx ingress and self-signed TLS certificate"
  default     = "localhost"
}

variable "ingress_http_port" {
  type        = number
  description = "HTTP listen port for the Nginx ingress"
  default     = 8080
}

variable "ingress_https_port" {
  type        = number
  description = "HTTPS listen port for the Nginx ingress"
  default     = 8443
}

variable "ingress_tls_ip_addresses" {
  type        = list(string)
  description = "List of IP addresses to include in the TLS certificate Subject Alternative Names (SANs)"
  default     = ["127.0.0.1", "::1"]
}

variable "ingress_cert_validity_hours" {
  type        = number
  default     = 2160 # 90 days
  description = "Length of ingress TLS certificate validity, in hours"
}

variable "ingress_cert_renewal_window_hours" {
  type        = number
  default     = 720 # 30 days
  description = "Length of ingress TLS certificate renewal window, in hours"
}
