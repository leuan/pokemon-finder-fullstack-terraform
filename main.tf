
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      # use ~> to allow minor patch updates
      version = "~> 4.5.0"
    }
  }
}

provider "docker" {}

locals {
  nginx_config            = file("${path.module}/nginx/nginx.conf")
  nginx_config_mount_path = "/etc/nginx/conf.d/default.conf"
  nginx_image_tag         = "nginx:1.31.3"
  hh_api_build_context    = "${path.module}/api"
}

resource "docker_network" "api_net" {
  name   = "api_network"
  driver = "bridge"
}

# nginx container
resource "docker_image" "nginx" {
  name         = local.nginx_image_tag
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx"

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

  depends_on = [ docker_container.hh_api ]
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

  networks_advanced {
    name = docker_network.api_net.name
  }
}
