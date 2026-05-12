# SPIRIT - Quick Start Guide

## Instalação em 5 Minutos

### 1. Clone o Repositório

```bash
git clone https://github.com/SEU_USERNAME/SPIRIT.git
cd SPIRIT
```

### 2. Configure Environment

```bash
# Copie o template
cp .env.example .env

# Edite com suas keys
nano .env
```

**Mínimo necessário:**
```bash
ANTHROPIC_API_KEY=sk-ant-...
POSTGRES_PASSWORD=secure-password
REDIS_PASSWORD=secure-password
JWT_SECRET=random-64-char-string
```

### 3. Execute Setup

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Isso vai:
- Instalar Docker (se necessário)
- Criar diretórios
- Gerar SSL
- Build images
- Start services

### 4. Acesse

- **Web UI:** http://localhost:3000
- **Gateway:** ws://localhost:18789
- **Langflow:** http://localhost:7860
- **Grafana:** http://localhost:3001

## Primeiro Uso

1. Abra http://localhost:3000
2. Crie conta admin
3. Configure modelo (Claude Sonnet)
4. Faça primeira pergunta!

## Conectar WhatsApp

```bash
# Ver logs do gateway
docker-compose logs -f gateway

# Escanear QR code que aparece
# Use WhatsApp no celular
```

## Testar Decision

Via Web UI:
```
"Devo lançar meu produto em Q3 2026?"
```

Resposta em ~30 segundos com:
- Análise de mercado
- Recomendação
- Confidence level
- Riscos principais

## Comandos Úteis

```bash
# Ver todos os logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop tudo
docker-compose down

# Update e restart
git pull
docker-compose up -d --build

# Backup database
docker exec spirit-postgres pg_dump -U spirit spirit > backup.sql

# Ver status
docker-compose ps
```

## Troubleshooting

### Gateway não conecta
```bash
docker-compose logs gateway
docker-compose restart gateway
```

### Agents não respondem
```bash
docker-compose logs orchestrator
# Check API keys no .env
```

### Sem espaço em disco
```bash
docker system prune -a
docker volume prune
```

### Port já em uso
```bash
# Mude ports no docker-compose.yml
# Ex: "3001:8080" para Web UI
```

## Próximos Passos

1. Configure Firecrawl API key
2. Explore Langflow workflows
3. Customize agents em `/agents/skills`
4. Deploy em produção (VPS)

## Suporte

- Docs: `/docs`
- Issues: GitHub Issues
- Discord: (link)
