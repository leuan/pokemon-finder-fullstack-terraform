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

provider "docker" {}
