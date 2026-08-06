# api container

locals {
  backend_host                           = "hh_api"
  backend_port                           = 8080
  backend_pokeapi_client_timeout_seconds = 30
  backend_pokeapi_base_url               = "https://pokeapi.co"
  backend_build_context                  = "${path.module}/${var.backend_build_context}"
}

resource "docker_image" "hh_api" {
  name         = "hh-api"
  keep_locally = false

  build {
    context    = local.backend_build_context
    dockerfile = var.backend_dockerfile
  }
}

resource "docker_container" "hh_api" {
  image = docker_image.hh_api.image_id
  name  = local.backend_host

  env = [
    "LOG_LEVEL=json",
    "LISTEN_PORT=${local.backend_port}",
    "HTTP_CLIENT_TIMEOUT_SECONDS=${local.backend_pokeapi_client_timeout_seconds}",
    "POKEAPI_BASE_URL=${local.backend_pokeapi_base_url}"
  ]

  networks_advanced {
    name = docker_network.api_net.name
  }
}
