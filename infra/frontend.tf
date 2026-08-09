locals {
  frontend_build_context  = "${path.module}/${var.frontend_build_context}"
  nginx_config_mount_path = "/etc/nginx/conf.d/default.conf"
}

# ui container
resource "docker_image" "hh_ui" {
  name         = "hh-ui"
  keep_locally = false

  build {
    context    = local.frontend_build_context
    dockerfile = var.frontend_dockerfile
  }
}

resource "docker_container" "hh_ui" {
  image = docker_image.hh_ui.image_id
  name  = "hh_ui"

  user = "101:101" # nginx-unprivileged user

  read_only = true

  // allow write to /tmp
  tmpfs = {
    "/tmp" = "rw,noexec,nosuid,size=32m"
  }

  capabilities {
    drop = ["ALL"]
  }

  security_opts = ["no-new-privileges:true"]

  init = true

  memory     = var.frontend_memory_mb
  cpu_shares = var.frontend_cpu_shares

  ports {
    internal = 8080
    external = var.ingress_http_port
  }

  ports {
    internal = 8443
    external = var.ingress_https_port
  }

  # inject nginx config
  upload {
    content = templatefile("${path.module}/nginx/nginx.conf.tftpl", {
      ingress_hostname   = var.ingress_hostname
      ingress_https_port = var.ingress_https_port
      backend_host       = local.backend_host
      backend_port       = local.backend_port
    })
    file = local.nginx_config_mount_path
  }

  # inject certificate and key
  upload {
    content = tls_self_signed_cert.ingress_cert.cert_pem
    file    = "/etc/nginx/certs/cert.pem"
  }

  upload {
    content = tls_private_key.ingress_private_key.private_key_pem
    file    = "/etc/nginx/certs/key.pem"
  }

  networks_advanced {
    name = docker_network.api_net.name
  }

  depends_on = [docker_container.hh_api]
}
