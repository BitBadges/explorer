# Build stage
FROM node:22-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package.json ./

# Remove package-lock.json and node_modules as suggested by the error message
# This fixes npm's bug with optional dependencies
RUN rm -rf package-lock.json node_modules 2>/dev/null || true

# Install dependencies fresh (this ensures rollup native binaries are properly installed)
RUN npm install --include=optional

# Copy source code
COPY . .

# Build the application
RUN npm run build-only

# Production stage - lightweight nginx
FROM nginx:alpine

# Copy built static files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

# Override default nginx port to 3000
RUN sed -i 's/listen       80;/listen       3000;/' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
