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

# Production stage
FROM node:22-slim

WORKDIR /app

# Install serve globally (lightweight static file server for production)
RUN npm install -g serve

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# Expose port
EXPOSE 3000

# Start serve (production static file server)
CMD ["serve", "-s", "dist", "-l", "3000"] 