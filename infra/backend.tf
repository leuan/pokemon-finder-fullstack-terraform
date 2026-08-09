# api container

locals {
  backend_host                           = "hh_api"
  backend_port                           = 8080
  backend_pokeapi_client_timeout_seconds = 30
  backend_pokeapi_base_url               = "https://pokeapi.co"
  backend_build_context                  = "${path.module}/${var.backend_build_context}"
  backend_gomemlimit                     = floor(var.backend_memory_mb * 0.85) # 85% of container memory limit
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

  user = "65532:65532"

  read_only = true
  security_opts = [
    "no-new-privileges:true"
  ]

  capabilities {
    drop = ["ALL"]
  }

  init = true

  memory     = var.backend_memory_mb
  cpu_shares = var.backend_cpu_shares

  ulimit {
    name = "nofile"
    soft = var.backend_max_open_files
    hard = var.backend_max_open_files
  }

  ulimit {
    name = "nproc"
    soft = var.backend_max_processes
    hard = var.backend_max_processes
  }

  env = [
    "GOMEMLIMIT=${local.backend_gomemlimit}MiB",
    "GOGC=100",
    "LOG_LEVEL=json",
    "LISTEN_PORT=${local.backend_port}",
    "HTTP_CLIENT_TIMEOUT_SECONDS=${local.backend_pokeapi_client_timeout_seconds}",
    "POKEAPI_BASE_URL=${local.backend_pokeapi_base_url}"
  ]

  networks_advanced {
    name = docker_network.api_net.name
  }
}
