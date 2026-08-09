# ingress
variable "ingress_hostname" {
  type        = string
  description = "Public facing hostname or IP for the Nginx ingress and self-signed TLS certificate"
  default     = "localhost"
}

variable "ingress_http_port" {
  type        = number
  description = "HTTP listen port for the Nginx ingress"
  default     = 8080
}

variable "ingress_https_port" {
  type        = number
  description = "HTTPS listen port for the Nginx ingress"
  default     = 8443
}

variable "ingress_tls_ip_addresses" {
  type        = list(string)
  description = "List of IP addresses to include in the TLS certificate Subject Alternative Names (SANs)"
  default     = ["127.0.0.1", "::1"]
}

variable "ingress_cert_validity_hours" {
  type        = number
  default     = 2160 # 90 days
  description = "Length of ingress TLS certificate validity, in hours"
}

variable "ingress_cert_renewal_window_hours" {
  type        = number
  default     = 720 # 30 days
  description = "Length of ingress TLS certificate renewal window, in hours"
}

# backend
variable "backend_build_context" {
  type        = string
  description = "Path to the backend build context relative to the root module"
  default     = "../api"
}

variable "backend_dockerfile" {
  type        = string
  description = "Name or relative path of the Dockerfile within the build context"
  default     = "Dockerfile"
}

variable "backend_memory_mb" {
  description = "Hard memory limit for the backend API container in MB"
  type        = number
  default     = 256
}

variable "backend_cpu_shares" {
  description = "Relative CPU share priority for the backend API container."
  type        = number
  default     = 1024
}

# frontend
variable "frontend_build_context" {
  type        = string
  description = "Path to the backend build context relative to the root module"
  default     = "../ui"
}

variable "frontend_dockerfile" {
  type        = string
  description = "Name or relative path of the Dockerfile within the build context"
  default     = "Dockerfile"
}

variable "frontend_memory_mb" {
  description = "Hard memory limit for the frontend API container in MB"
  type        = number
  default     = 128
}

variable "frontend_cpu_shares" {
  description = "Relative CPU share priority for the frontend API container."
  type        = number
  default     = 512
}
