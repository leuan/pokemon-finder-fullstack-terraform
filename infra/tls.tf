# nginx TLS
resource "tls_private_key" "ingress_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ingress_cert" {
  private_key_pem = tls_private_key.ingress_private_key.private_key_pem

  subject {
    common_name  = "localhost"
    organization = "Pokemon Finder"
  }

  validity_period_hours = local.ingress_cert_validtity_hours
  early_renewal_hours   = local.ingress_early_renewal_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names    = ["localhost"]
  ip_addresses = ["127.0.0.1"]
}
