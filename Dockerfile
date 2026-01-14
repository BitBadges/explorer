FROM node:22-slim

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

# Expose Vite preview port
EXPOSE 4173

# Start Vite preview server
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4173"] 