FROM golang:1.27rc2-alpine3.24 as builder
WORKDIR /app

# first, download the dependencies, so this build step will be cached
COPY go.mod ./
RUN go mod download

# then, copy the source code and build the binary
COPY . .

# to use a debugger, use without -ldflags
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o ./server

# I will use a distroless image to minimize attack surface
# if I need a shell or unix utils, I can use this alpine image instead
# FROM alpine:3.24
FROM gcr.io/distroless/static-debian13:latest
WORKDIR /app

COPY --from=builder /app/server .

EXPOSE 8080

ENTRYPOINT [ "/app/server" ]
