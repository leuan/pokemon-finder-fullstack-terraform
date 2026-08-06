# ui container
resource "docker_image" "hh_ui" {
  name         = "hh-ui"
  keep_locally = false

  build {
    context = local.hh_ui_build_context
  }
}

resource "docker_container" "hh_ui" {
  image = docker_image.hh_ui.image_id
  name  = "hh_ui"

  ports {
    internal = 80
    external = 8080
  }

  ports {
    internal = 443
    external = 8443
  }

  # inject nginx config
  upload {
    content = local.nginx_config
    file    = local.nginx_config_mount_path
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
