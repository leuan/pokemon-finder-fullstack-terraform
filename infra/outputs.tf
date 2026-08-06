output "https_url" {
  value       = "https://${var.ingress_hostname}:${var.ingress_http_port}"
  description = "Public entrypoint URL for the Nginx ingress"
}

output "certificate_pem" {
  value       = tls_self_signed_cert.ingress_cert.cert_pem
  description = "Public certificate PEM for client trust verification"
}
