#!/bin/bash

# ============================================
# SPIRIT Setup Script
# ============================================

set -e

echo "============================================"
echo "SPIRIT - Setup Starting"
echo "============================================"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📋 Creating .env from template..."
    cp .env.example .env
    echo "✅ .env created. Please edit it with your API keys."
    echo ""
    read -p "Press Enter after editing .env to continue..."
fi

# Check required tools
echo "🔍 Checking required tools..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker found"
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found. Installing..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose found"
fi

echo ""

# Create required directories
echo "📁 Creating directories..."
mkdir -p infra/nginx/ssl
mkdir -p infra/postgres
mkdir -p infra/prometheus
mkdir -p infra/grafana/{dashboards,datasources}
echo "✅ Directories created"
echo ""

# Generate SSL (self-signed for development)
if [ ! -f infra/nginx/ssl/cert.pem ]; then
    echo "🔐 Generating self-signed SSL certificate..."
    openssl req -x509 -newkey rsa:4096 -nodes \
        -keyout infra/nginx/ssl/key.pem \
        -out infra/nginx/ssl/cert.pem \
        -days 365 \
        -subj "/C=US/ST=State/L=City/O=SPIRIT/CN=localhost"
    echo "✅ SSL certificate generated"
else
    echo "✅ SSL certificate exists"
fi

echo ""

# Build and start
echo "🐳 Building Docker images..."
docker-compose build

echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "============================================"
echo "✅ SPIRIT Setup Complete!"
echo "============================================"
echo ""
echo "Access points:"
echo "  • Web UI:     http://localhost:3000"
echo "  • Gateway:    ws://localhost:18789"
echo "  • Langflow:   http://localhost:7860"
echo "  • Grafana:    http://localhost:3001"
echo "  • Prometheus: http://localhost:9090"
echo ""
echo "Next steps:"
echo "  1. Open Web UI and create admin account"
echo "  2. Configure WhatsApp (scan QR code in logs)"
echo "  3. Test with a decision request"
echo ""
echo "View logs:"
echo "  docker-compose logs -f"
echo ""
echo "Stop services:"
echo "  docker-compose down"
echo ""
