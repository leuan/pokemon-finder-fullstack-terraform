
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