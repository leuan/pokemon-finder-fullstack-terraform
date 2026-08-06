
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      # use ~> to allow minor patch updates
      version = "~> 4.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3.0"
    }
  }
}

locals {
  nginx_config                 = file("${path.module}/nginx/nginx.conf")
  nginx_config_mount_path      = "/etc/nginx/conf.d/default.conf"
  nginx_image_tag              = "nginx:1.31.3"
  hh_ui_build_context          = "${path.module}/ui"
  hh_api_build_context         = "${path.module}/api"
  ingress_cert_validtity_hours = 2160 # valid for 90 days
  ingress_early_renewal_hours  = 720 # window for renewal
}

provider "docker" {}

# nginx TLS
resource "tls_private_key" "ingress_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ingress_cert" {
  private_key_pem = tls_private_key.ingress_private_key

  subject {
    common_name  = "localhost"
    organization = "Pokemon Finder"
  }

  validity_period_hours = local.ingress_cert_validtity_hours
  early_renewal_hours = local.ingress_early_renewal_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names    = ["localhost"]
  ip_addresses = ["127.0.0.1"]
}

resource "docker_network" "api_net" {
  name   = "api_network"
  driver = "bridge"
}

# # nginx container
# resource "docker_image" "nginx" {
#   name         = local.nginx_image_tag
#   keep_locally = false
# }

# resource "docker_container" "nginx" {
#   image = docker_image.nginx.image_id
#   name  = "nginx"

#   ports {
#     internal = 80
#     external = 8000
#   }

#   upload {
#     content = local.nginx_config
#     file    = local.nginx_config_mount_path
#   }

#   networks_advanced {
#     name = docker_network.api_net.name
#   }

#   depends_on = [docker_container.hh_api]
# }

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
    external = 8000
  }

  upload {
    content = local.nginx_config
    file    = local.nginx_config_mount_path
  }

  networks_advanced {
    name = docker_network.api_net.name
  }

  depends_on = [docker_container.hh_api]
}

# api container
resource "docker_image" "hh_api" {
  name         = "hh-api"
  keep_locally = false

  build {
    context = local.hh_api_build_context
  }
}

resource "docker_container" "hh_api" {
  image = docker_image.hh_api.image_id
  name  = "hh_api"

  env = [
    "LOG_LEVEL=json",
    "LISTEN_PORT=8080",
    "HTTP_CLIENT_TIMEOUT=30",
    "POKEAPI_BASE_URL=https://pokeapi.co"
  ]

  networks_advanced {
    name = docker_network.api_net.name
  }
}
