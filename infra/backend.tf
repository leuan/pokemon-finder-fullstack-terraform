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
