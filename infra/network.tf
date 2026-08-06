resource "docker_network" "api_net" {
  name   = "api_network"
  driver = "bridge"
}
