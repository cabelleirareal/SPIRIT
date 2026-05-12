FROM node:18-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git python3 make g++

# Copy package files
COPY package*.json ./

# Install packages
RUN npm ci --only=production

# Copy source
COPY . .

# Expose port
EXPOSE 18789

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Start gateway
CMD ["node", "src/index.js"]
