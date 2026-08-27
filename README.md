# Full-Stack Go + Svelte Platform

A containerized full-stack application that proxies the [PokeAPI v2](https://pokeapi.co/docs/v2) through a Go backend, serves a Svelte frontend via NGINX with TLS termination, and orchestrates both services entirely through Terraform using the Docker provider.

**Key architectural decisions:**
- **NGINX as the sole entrypoint** — handles TLS termination, HTTP→HTTPS redirect, static asset caching, security headers, and reverse-proxying API requests to the Go backend.
- **Static-only frontend** — SvelteKit compiles to HTML/JS/CSS via `adapter-static`, eliminating a Node.js runtime in production.
- **Terraform-managed Docker** — no Docker Compose; the entire stack (images, containers, network, TLS certs) is provisioned through `terraform apply`.

## Infrastructure & IaC (Terraform)

### Providers

| Provider | Version | Purpose |
|---|---|---|
| `kreuzwerker/docker` | `~> 4.5.0` | Build images, manage containers and networks |
| `hashicorp/tls` | `~> 4.3.0` | Generate self-signed ECDSA TLS certificates at apply time |

### Resources

| Resource | Type | Description |
|---|---|---|
| `docker_network.api_net` | Bridge | Isolated network for inter-container communication |
| `docker_image.hh_api` | Image | Builds Go API from `api/Dockerfile` |
| `docker_container.hh_api` | Container | Go API — runs as non-root (65532:65532), read-only FS |
| `docker_image.hh_ui` | Image | Builds frontend from `ui/Dockerfile` |
| `docker_container.hh_ui` | Container | NGINX frontend — runs as non-root (101:101), read-only FS |
| `tls_private_key.ingress_private_key` | ECDSA P-256 | TLS private key |
| `tls_self_signed_cert.ingress_cert` | Self-signed | TLS certificate with configurable SANs and validity |

### Configuration Injection

Instead of volume mounts, NGINX config and TLS certificates are injected into the frontend container via Terraform `upload` blocks — ensuring the container runs with a fully read-only filesystem:

```hcl
upload {
  content = templatefile("${path.module}/nginx/nginx.conf.tftpl", { ... })
  file    = "/etc/nginx/conf.d/default.conf"
}
```

### Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `ingress_hostname` | `string` | `localhost` | Hostname for NGINX server_name and TLS cert CN |
| `ingress_http_port` | `number` | `8080` | HTTP listen port (redirects to HTTPS) |
| `ingress_https_port` | `number` | `8443` | HTTPS listen port |
| `ingress_tls_ip_addresses` | `list(string)` | `["127.0.0.1", "::1"]` | TLS certificate SANs |
| `ingress_cert_validity_hours` | `number` | `2160` (90 days) | TLS certificate validity period |
| `ingress_cert_renewal_window_hours` | `number` | `720` (30 days) | Early renewal window |
| `backend_memory_mb` | `number` | `256` | Go API container memory limit |
| `backend_cpu_shares` | `number` | `1024` | Go API CPU share weight |
| `backend_max_processes` | `number` | `1024` | Go API max OS threads (nproc) |
| `backend_max_open_files` | `number` | `65536` | Go API max file descriptors |
| `frontend_memory_mb` | `number` | `128` | NGINX container memory limit |
| `frontend_cpu_shares` | `number` | `512` | NGINX CPU share weight |
| `frontend_max_processes` | `number` | `1024` | NGINX max OS threads (nproc) |
| `frontend_max_open_files` | `number` | `65536` | NGINX max file descriptors |

### Outputs

| Output | Description |
|---|---|
| `https_url` | `https://${ingress_hostname}:${ingress_https_port}` — entrypoint URL after apply |
| `certificate_pem` | Self-signed TLS certificate PEM for client trust import |

## Security & Operational Best Practices

### Container Hardening

Both containers enforce identical security posture:

| Control | Implementation |
|---|---|
| **Non-root execution** | Go: `65532:65532` (distroless nonroot). NGINX: `101:101` (nginx-unprivileged) |
| **Read-only filesystem** | `read_only = true` on both containers. NGINX gets a tmpfs at `/tmp` (rw,noexec,nosuid,32m) |
| **Capability dropping** | `drop = ["ALL"]` — no Linux capabilities retained |
| **No new privileges** | `no-new-privileges:true` security option |
| **Init process** | `init = true` — containers do not run as PID 1 |
| **Resource limits** | Memory caps (256 MB / 128 MB), CPU shares, nproc, and nofile ulimits |
| **Go memory tuning** | `GOMEMLIMIT` set to 85% of container memory (220 MiB) via Terraform locals |

### Build Security

| Practice | Go API | Frontend |
|---|---|---|
| **Multi-stage build** | `golang:1.27rc2-alpine` → `gcr.io/distroless/static-debian13:nonroot` | `oven/bun:1.3.14-debian` → `nginxinc/nginx-unprivileged:1.31.3-alpine` |
| **Static binary** | `CGO_ENABLED=0 GOOS=linux -ldflags="-w -s"` | N/A |
| **Dependency caching** | `go mod download` before source copy | `bun install --frozen-lockfile` before source copy |
| **Minimal runtime** | Distroless — no shell, no package manager | Alpine-based NGINX — minimal footprint |

### TLS & NGINX Security

| Setting | Value | Rationale |
|---|---|---|
| **TLS protocols** | `TLSv1.2 TLSv1.3` only | Rejects deprecated SSLv3/TLSv1.0/1.1 |
| **Cipher suite** | `HIGH:!aNULL:!MD5` with server preference | Strong ciphers, server-selected ordering |
| **Session tickets** | `off` | Prevents session persistence across restarts |
| **HSTS** | `max-age=31536000; includeSubDomains` | Forces HTTPS for 1 year |
| **Security headers** | `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy` | Defense-in-depth against sniffing, clickjacking, data leakage |
| **server_tokens** | `off` | Hides NGINX version |
| **Request limits** | `client_max_body_size 0`, buffer tuning | GET-only API; mitigates slowloris attacks |
| **JSON access logs** | Structured JSON to stdout | Machine-readable logging with request IDs, latency, upstream timing |

## Go API

### Clean Architecture

```
cmd/server/main.go          Entrypoint — wires config, logger, service, handler, router
internal/
  config/                   Environment-based config via Viper + validator
    config.go               Structured config loading with validation
    constants.go            Defaults: PokeAPI URL, timeout, port
  domain/
    pokemon.go              Pokemon data model (stats, sprites, types)
  service/
    pokemon.go              HTTP client → PokeAPI v2, JSON decode, sentinel errors
  handler/
    router.go               Gin engine setup, middleware registration, route groups
    pokemon.go              GET /api/v1/pokemon/:id — param validation, error mapping
  log/
    log.go                  slog JSON logger, configurable level via LOG_LEVEL
    middleware.go            Per-request logger injection, request ID propagation
  middleware/
    recovery.go             Panic recovery with stack trace logging
```

### Key Patterns

- **Sentinel errors** — `ErrNotFound` from the service layer maps cleanly to 404 responses without leaking internal details.
- **Request ID propagation** — NGINX generates `$request_id` and forwards via `X-Request-ID` header; Go extracts it for correlated logging.
- **Middleware chain** — structured logging → panic recovery → route handlers, all wired through Gin's `Use()`.
- **HTTP client timeout** — configurable via `HTTP_CLIENT_TIMEOUT_SECONDS` (default 30s) to prevent hanging connections to PokeAPI.

## Frontend (Svelte)

### Tech Stack

| Layer | Technology |
|---|---|
| Framework | SvelteKit with `@sveltejs/adapter-static` |
| Package manager | Bun (`--frozen-lockfile` for reproducibility) |
| CSS | TailwindCSS v4.3 + Skeleton UI v5 |
| Reactivity | Svelte 5 runes mode (`$state`, `$props`) |
| Dark mode | Class-based toggle (`.dark` on `<html>`), persisted to `localStorage` |

### NGINX Serving Strategy

- **Immutable assets** (`/_app/`) — 1-year cache with `immutable` directive. SvelteKit hashes filenames, so this is safe.
- **SPA fallback** — `try_files $uri $uri/ /index.html` for client-side routing.
- **Gzip** — enabled for text, CSS, JS, JSON, XML, SVG with 1000-byte minimum.
- **Proxy pass** — `/api/v1/*` requests forwarded to the Go backend over the internal Docker network with HTTP/1.1 keepalive (8 persistent connections).

## Quickstart

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (running)
- [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.0)
- [Go](https://go.dev/dl/) (for local development only)
- [Bun](https://bun.sh/) (for local development only)

### Deploy

```bash
cd infra
terraform init
terraform apply
```

Terraform will:
1. Build the Go API Docker image from `api/Dockerfile`
2. Build the Svelte/NGINX Docker image from `ui/Dockerfile`
3. Generate a self-signed ECDSA P-256 TLS certificate
4. Create an isolated bridge network (`api_network`)
5. Start both containers with hardened security settings
6. Output the application URL

### Verify

```bash
# Check Terraform output for the URL
terraform output https_url

# Test the API through NGINX (ignore self-signed cert warning)
curl -k https://localhost:8443/api/v1/pokemon/25

# Open in browser
open https://localhost:8443
```

### Tear Down

```bash
terraform destroy
```

## Repository Layout

```
hh-technical-assignment/
├── api/                          Go API backend
│   ├── Dockerfile                Multi-stage: alpine builder → distroless runtime
│   ├── go.mod / go.sum           Module definition and checksums
│   ├── cmd/server/main.go        Entrypoint
│   └── internal/
│       ├── config/               Env-based config (Viper + validator)
│       ├── domain/               Pokemon data model
│       ├── handler/              Gin HTTP handlers and router
│       ├── log/                  Structured slog logging + middleware
│       ├── middleware/           Panic recovery
│       └── service/              PokeAPI HTTP client
├── ui/                           Svelte frontend
│   ├── Dockerfile                Multi-stage: Bun builder → NGINX runtime
│   ├── src/
│   │   ├── lib/components/       PokemonForm, PokemonCard, Lightswitch
│   │   ├── lib/api.js            API client (relative /api/v1/ calls)
│   │   └── routes/               SvelteKit routes and layouts
│   ├── vite.config.js            Static adapter, Svelte 5 runes mode
│   └── package.json              TailwindCSS, Skeleton UI, Lucide icons
├── infra/                        Terraform IaC
│   ├── backend.tf                Go API image + container resource
│   ├── frontend.tf               NGINX image + container + config injection
│   ├── network.tf                Docker bridge network
│   ├── tls.tf                    Self-signed TLS certificate generation
│   ├── variables.tf              All configurable parameters
│   ├── outputs.tf                Application URL + certificate PEM
│   └── nginx/
│       └── nginx.conf.tftpl      Parameterized NGINX config template
└── notes/                        Development journal
    └── Work Journal.md           Design decisions and implementation notes
```

## Development Journal

See [`notes/Work Journal.md`](notes/Work Journal.md) for a detailed development log covering requirements gathering, architectural decisions, debugging sessions, and trade-off analysis throughout the build process.
