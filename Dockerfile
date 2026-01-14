# Build stage
FROM node:22-alpine AS builder

# Install dependencies
RUN apk add --no-cache libc6-compat python3 make g++

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies with optional dependencies
# The --include=optional flag ensures rollup native binaries are installed
RUN npm install --include=optional || (rm -f package-lock.json && npm install --include=optional)

# Copy source code
COPY . .

# Build the application
RUN npm run build-only

# Production stage
FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 