# Build stage
FROM node:22.14.0-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package manifests and lockfile
COPY package.json package-lock.json ./

# Install dependencies deterministically from lockfile
RUN npm ci --include=optional --legacy-peer-deps

# Copy source code
COPY . .

# Build the application
RUN npm run build-only

# Production stage - unprivileged lightweight nginx
FROM nginxinc/nginx-unprivileged:1.27.4-alpine

# Copy built static files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

USER 101

CMD ["nginx", "-g", "daemon off;"]
