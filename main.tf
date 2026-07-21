
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

# nginx container
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}

# api container
resource "docker_image" "hh_api" {
  name         = "hh-api"
  keep_locally = false

  build {
    context = "${path.module}/api"
  }
}

resource "docker_container" "hh_api" {
  image = docker_image.hh_api.image_id
  name  = "hh_api"
}