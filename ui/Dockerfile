FROM oven/bun:1.3.14-debian as builder

WORKDIR /app

COPY package.json .
COPY bun.lock .

RUN bun install --frozen-lockfile

COPY . .

RUN bun run build

FROM nginx:1.31.3-alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
EXPOSE 443
