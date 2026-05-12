# SPIRIT - PLANO DE IMPLEMENTAÇÃO PRÁTICO
## Do Zero ao MVP em 90 Dias

---

## FASE 0: SETUP INICIAL (Dia 1-2)

### Infraestrutura Base

```bash
# 1. VPS Setup (DigitalOcean/Hetzner - $20/mês)
# Specs mínimas: 4 CPU, 8GB RAM, 100GB SSD

# 2. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 3. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. Clone repos
mkdir -p ~/oracle-ai && cd ~/oracle-ai

git clone https://github.com/openclaw/openclaw.git
git clone https://github.com/NousResearch/hermes-agent.git
git clone https://github.com/666ghj/MiroFish.git
git clone https://github.com/firecrawl/firecrawl.git
git clone https://github.com/langflow-ai/langflow.git
git clone https://github.com/open-webui/open-webui.git

# 5. Environment Setup
cat > .env << 'EOF'
# LLM APIs
ANTHROPIC_API_KEY=your_key_here
OPENAI_API_KEY=your_key_here
GOOGLE_API_KEY=your_key_here

# Firecrawl
FIRECRAWL_API_KEY=your_key_here

# Database
POSTGRES_PASSWORD=your_secure_password
REDIS_PASSWORD=your_secure_password

# OpenClaw
OPENCLAW_PORT=18789

# Domain (para WhatsApp)
DOMAIN=your-domain.com
EOF
```

---

## FASE 1: GATEWAY OPERACIONAL (Dia 3-7)

### Deploy OpenClaw

```bash
cd ~/oracle-ai/openclaw

# 1. Install dependencies
pnpm install

# 2. Configure
cat > .openclaw/config.yaml << 'EOF'
gateway:
  port: 18789
  host: "0.0.0.0"
  
auth:
  enable: true
  providers:
    - google
    - github

channels:
  whatsapp:
    enabled: true
  telegram:
    enabled: true
  slack:
    enabled: true
EOF

# 3. Start Gateway
pnpm dev # Primeiro teste local

# 4. Production (background)
pnpm build
pm2 start dist/gateway.js --name openclaw-gateway

# 5. Setup Nginx reverse proxy
sudo apt install nginx

cat > /etc/nginx/sites-available/oracle-ai << 'EOF'
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/oracle-ai /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 6. SSL (Let's Encrypt)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Conectar WhatsApp

```bash
# 1. Instalar baileys (adaptador WhatsApp)
cd ~/oracle-ai/openclaw
pnpm add @whiskeysockets/baileys

# 2. Scan QR code no primeiro boot
openclaw gateway
# Scaneia QR code com WhatsApp
# Gateway fica conectado
```

**Checkpoint:** Gateway recebe mensagens WhatsApp e responde "OK".

---

## FASE 2: PRIMEIRO AGENTE (Dia 8-14)

### Deploy Hermes Agent

```bash
cd ~/oracle-ai/hermes-agent

# 1. Install
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# 2. Configure
hermes setup

# Wizard pergunta:
# - Provider: Anthropic (Claude Sonnet)
# - API Key: seu ANTHROPIC_API_KEY
# - Profile: production

# 3. Criar primeiro skill: web_research
cat > ~/.hermes/skills/web_research.py << 'EOF'
"""
Skill de pesquisa web usando Firecrawl
"""

import os
import requests

def search_and_analyze(query: str) -> dict:
    """
    Pesquisa web e retorna análise estruturada
    
    Args:
        query: Termo de busca
        
    Returns:
        dict com título, resumo, fontes
    """
    api_key = os.getenv("FIRECRAWL_API_KEY")
    
    # Firecrawl search
    response = requests.post(
        "https://api.firecrawl.dev/v2/search",
        headers={"Authorization": f"Bearer {api_key}"},
        json={"query": query, "limit": 5}
    )
    
    results = response.json()
    
    # Process results
    summary = {
        "query": query,
        "total_results": len(results.get("data", [])),
        "top_sources": [
            {
                "title": r.get("title"),
                "url": r.get("url"),
                "snippet": r.get("description")
            }
            for r in results.get("data", [])[:3]
        ]
    }
    
    return summary

# Register skill
SKILL_NAME = "web_research"
SKILL_DESCRIPTION = "Search the web and return structured analysis"
SKILL_FUNCTION = search_and_analyze
EOF

# 4. Test skill
hermes chat --message "Use web_research to find latest AI trends"

# 5. Conectar Hermes ao OpenClaw
# Hermes expõe API OpenAI-compatible
hermes api --port 8000

# Em outra terminal:
curl http://localhost:8000/v1/models
```

**Checkpoint:** Hermes responde a requests e usa skill web_research.

---

## FASE 3: WEB SCRAPING (Dia 15-21)

### Setup Firecrawl

```bash
# 1. Signup em firecrawl.dev
# 2. Pegar API key
# 3. Test

curl -X POST 'https://api.firecrawl.dev/v2/scrape' \
  -H 'Authorization: Bearer fc-YOUR-API-KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://techcrunch.com",
    "formats": ["markdown"]
  }'

# 4. Criar data agent skill
cat > ~/.hermes/skills/data_collector.py << 'EOF'
"""
Data collection agent usando Firecrawl
"""

import os
from firecrawl import Firecrawl

def crawl_website(url: str, limit: int = 10) -> dict:
    """
    Crawl website completo
    """
    app = Firecrawl(api_key=os.getenv("FIRECRAWL_API_KEY"))
    
    result = app.crawl(
        url=url,
        limit=limit,
        scrape_options={"formats": ["markdown"]}
    )
    
    return {
        "url": url,
        "pages_crawled": len(result.get("data", [])),
        "content": [
            {
                "url": page.get("url"),
                "title": page.get("metadata", {}).get("title"),
                "markdown": page.get("markdown")[:500]  # Preview
            }
            for page in result.get("data", [])
        ]
    }

def search_web(query: str) -> dict:
    """
    Search web and return results
    """
    app = Firecrawl(api_key=os.getenv("FIRECRAWL_API_KEY"))
    
    result = app.search(query=query)
    
    return {
        "query": query,
        "results": [
            {
                "title": r.get("title"),
                "url": r.get("url"),
                "content": r.get("markdown")[:300]
            }
            for r in result.get("data", [])[:5]
        ]
    }

SKILL_NAME = "data_collector"
SKILL_DESCRIPTION = "Crawl websites and search the web"
SKILL_FUNCTIONS = [crawl_website, search_web]
EOF

# 5. Test
hermes chat --message "Use data_collector to search for 'AI agents market size'"
```

**Checkpoint:** Agent coleta dados web estruturados via Firecrawl.

---

## FASE 4: INTERFACE WEB (Dia 22-30)

### Deploy Open-WebUI

```bash
cd ~/oracle-ai

# 1. Docker run
docker run -d \
  -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ghcr.io/open-webui/open-webui:main

# 2. Access http://your-domain.com:3000
# Create admin account

# 3. Connect to Hermes Agent
# Settings > Connections > Add Connection
# URL: http://host.docker.internal:8000/v1
# Type: OpenAI Compatible

# 4. Nginx proxy para porta 3000
cat >> /etc/nginx/sites-available/oracle-ai << 'EOF'

location /app {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
EOF

sudo nginx -t
sudo systemctl reload nginx
```

**Checkpoint:** Dashboard web funcional conectado aos agentes.

---

## FASE 5: SIMULAÇÃO (Dia 31-45)

### Setup MiroFish (Simplified)

```bash
cd ~/oracle-ai/MiroFish

# 1. Install
pip install -r requirements.txt

# 2. Configure
cat > config.yaml << 'EOF'
llm:
  provider: anthropic
  model: claude-sonnet-4-20250514
  api_key: ${ANTHROPIC_API_KEY}

simulation:
  max_agents: 100  # Start small
  max_turns: 50
  temperature: 0.7
EOF

# 3. Create simple simulation skill
cat > ~/.hermes/skills/scenario_simulator.py << 'EOF'
"""
Scenario simulation usando MiroFish simplificado
"""

import subprocess
import json

def simulate_decision(
    scenario: str,
    num_agents: int = 50,
    num_scenarios: int = 10
) -> dict:
    """
    Simula cenários de decisão
    
    Args:
        scenario: Descrição do cenário
        num_agents: Número de agentes simulados
        num_scenarios: Número de variações
        
    Returns:
        Predições e probabilidades
    """
    
    # Simplified simulation (sem MiroFish completo)
    # Use LLM direto para MVP
    
    from anthropic import Anthropic
    
    client = Anthropic()
    
    prompt = f"""
    Você é um motor de simulação preditiva.
    
    Cenário: {scenario}
    
    Simule {num_scenarios} cenários diferentes considerando:
    - Diferentes comportamentos de mercado
    - Reações de competidores
    - Mudanças regulatórias
    - Variáveis econômicas
    
    Para cada cenário, forneça:
    1. Probabilidade (0-100%)
    2. Outcome esperado
    3. Principais riscos
    4. Oportunidades
    
    Retorne JSON estruturado.
    """
    
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=4000,
        messages=[{"role": "user", "content": prompt}]
    )
    
    # Parse response
    try:
        result = json.loads(response.content[0].text)
    except:
        result = {"raw": response.content[0].text}
    
    return {
        "scenario": scenario,
        "num_scenarios": num_scenarios,
        "predictions": result
    }

SKILL_NAME = "scenario_simulator"
SKILL_DESCRIPTION = "Simulate decision scenarios with probabilistic outcomes"
SKILL_FUNCTION = simulate_decision
EOF

# 4. Test
hermes chat --message "Simulate: Should we launch product X in Q3?"
```

**Checkpoint:** Simulações básicas funcionando (LLM-based).

---

## FASE 6: WORKFLOWS VISUAIS (Dia 46-60)

### Deploy Langflow

```bash
cd ~/oracle-ai

# 1. Install
pip install langflow

# 2. Run
langflow run --host 0.0.0.0 --port 7860

# 3. Access http://your-domain.com:7860

# 4. Criar workflow: "Decision Pipeline"
# - Input: User question
# - Step 1: Research Agent (web search)
# - Step 2: Data extraction
# - Step 3: Simulation
# - Step 4: Report generation
# - Output: Formatted report

# 5. Export workflow as API
# Settings > Export > Python API

# 6. Integrate no Hermes
cat > ~/.hermes/skills/workflow_executor.py << 'EOF'
"""
Execute Langflow workflows
"""

import requests

def run_decision_pipeline(query: str) -> dict:
    """
    Execute decision pipeline workflow
    """
    
    response = requests.post(
        "http://localhost:7860/api/v1/run/decision-pipeline",
        json={"input": query}
    )
    
    return response.json()

SKILL_NAME = "workflow_executor"
SKILL_DESCRIPTION = "Execute Langflow decision workflows"
SKILL_FUNCTION = run_decision_pipeline
EOF
```

**Checkpoint:** Workflows visuais executáveis via agentes.

---

## FASE 7: ORCHESTRAÇÃO (Dia 61-75)

### Orquestração Multi-Agent

```bash
# 1. Criar Orchestrator Agent
cat > ~/.hermes/agents/orchestrator.yaml << 'EOF'
name: orchestrator
description: Main decision orchestrator
model: claude-opus-4-20250514

system_prompt: |
  You are the Orchestrator Agent for SPIRIT.
  
  Your job is to coordinate multiple specialist agents to make data-driven decisions.
  
  Available agents:
  - research_agent: Web research and analysis
  - data_agent: Data collection via Firecrawl
  - simulation_agent: Scenario simulation
  - report_agent: Report generation
  
  When a user asks for a decision:
  1. Break down into sub-tasks
  2. Delegate to specialist agents
  3. Synthesize results
  4. Provide clear recommendation
  
  Always include:
  - Confidence level (%)
  - Key assumptions
  - Main risks
  - Recommended action

tools:
  - web_research
  - data_collector
  - scenario_simulator
  - workflow_executor

memory:
  enabled: true
  max_tokens: 100000
EOF

# 2. Criar agent workers
for agent in research data simulation report; do
cat > ~/.hermes/agents/${agent}_agent.yaml << EOF
name: ${agent}_agent
description: Specialist ${agent} agent
model: claude-sonnet-4-20250514

system_prompt: |
  You are a specialist ${agent} agent.
  Execute your tasks efficiently and return structured results.

tools:
  - ${agent}_*
EOF
done

# 3. Test orchestration
hermes chat --agent orchestrator --message "Should we expand to Brazil market?"
```

**Checkpoint:** Multi-agent orchestration operacional.

---

## FASE 8: INTEGRAÇÃO COMPLETA (Dia 76-90)

### Docker Compose Stack Completo

```yaml
# docker-compose.yml
version: '3.8'

services:
  # Gateway
  openclaw:
    build: ./openclaw
    ports:
      - "18789:18789"
    environment:
      - NODE_ENV=production
    volumes:
      - openclaw-data:/app/data
    restart: always

  # Orchestrator
  hermes-orchestrator:
    build: ./hermes-agent
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - HERMES_PROFILE=orchestrator
    volumes:
      - hermes-data:/root/.hermes
    restart: always

  # Worker Pool (3 instances)
  hermes-worker:
    build: ./hermes-agent
    deploy:
      replicas: 3
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - HERMES_PROFILE=worker
    restart: always

  # Langflow
  langflow:
    image: langflowai/langflow:latest
    ports:
      - "7860:7860"
    environment:
      - LANGFLOW_DATABASE_URL=postgresql://user:pass@postgres:5432/langflow
    restart: always

  # Open-WebUI
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "3000:8080"
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    volumes:
      - open-webui-data:/app/backend/data
    restart: always

  # PostgreSQL
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: always

  # Redis
  redis:
    image: redis:7
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
    restart: always

  # Vector DB (Qdrant)
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant-data:/qdrant/storage
    restart: always

  # Nginx
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - openclaw
      - open-webui
      - langflow
    restart: always

volumes:
  openclaw-data:
  hermes-data:
  postgres-data:
  redis-data:
  qdrant-data:
  open-webui-data:
```

### Deploy Stack

```bash
# 1. Build and start
docker-compose up -d

# 2. Health check
docker-compose ps

# 3. Logs
docker-compose logs -f

# 4. Scale workers
docker-compose up -d --scale hermes-worker=5
```

**Checkpoint:** Sistema completo rodando em produção.

---

## FASE 9: PRIMEIRO CLIENTE (Dia 90+)

### Landing Page

```bash
# 1. Simple landing (HTML/CSS/JS)
cat > ~/oracle-ai/landing/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>SPIRIT - Decisions at the Speed of Thought</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .hero {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 2rem;
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        .tagline {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .cta {
            background: white;
            color: #667eea;
            padding: 1rem 2rem;
            font-size: 1.2rem;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            font-weight: bold;
            text-decoration: none;
            display: inline-block;
        }
        .cta:hover {
            transform: scale(1.05);
            transition: all 0.2s;
        }
    </style>
</head>
<body>
    <div class="hero">
        <h1>SPIRIT</h1>
        <p class="tagline">Decisions at the Speed of Thought</p>
        <p>Transform data into decisions through AI-powered predictive simulations.</p>
        <br>
        <a href="https://wa.me/seu-numero?text=Hi%20SPIRIT" class="cta">
            Start Free Trial via WhatsApp
        </a>
    </div>
</body>
</html>
EOF

# 2. Deploy landing
# Vercel/Netlify free tier

# 3. Setup analytics
# Google Analytics + Plausible
```

### Onboarding Flow

```bash
# WhatsApp Onboarding
# User: "Hi"
# Bot: "👋 Welcome to SPIRIT! I help you make data-driven decisions.
#      
#      Quick setup (30 seconds):
#      1. What's your biggest business challenge right now?
#      2. What industry are you in?
#      
#      Then I'll show you how I can help."

# Criar onboarding agent
cat > ~/.hermes/agents/onboarding.yaml << 'EOF'
name: onboarding
description: User onboarding agent
model: claude-sonnet-4-20250514

system_prompt: |
  You are the onboarding agent for SPIRIT.
  
  Your goal: Get user to first "aha" moment in < 5 minutes.
  
  Flow:
  1. Welcome + explain value prop (1 line)
  2. Ask industry + main challenge
  3. Offer relevant demo decision
  4. Execute demo (research + simulation)
  5. Show results
  6. Upsell to paid plan
  
  Be concise, friendly, fast.
EOF
```

**Checkpoint:** Primeiro usuário completa onboarding e vê valor.

---

## CUSTOS ESTIMADOS

### Infrastructure (Mensal)

- VPS (4 CPU, 8GB RAM): $20/mês
- Domain + SSL: $15/ano = $1.25/mês
- Backups: $5/mês
- **Total infra:** ~$25/mês

### APIs (por 1000 decisões)

- Claude API (Sonnet): $15/1k decisions
- Firecrawl: $10/1k decisions
- Total: $25/1k decisions

### Free Tier Limits

- Firecrawl: 500 páginas/mês free
- Anthropic: $5 crédito inicial
- Supabase: 500MB DB free

**Total MVP:** $50/mês até atingir 1000 decisões/mês.

---

## MÉTRICAS DE SUCESSO (Primeiros 90 Dias)

### Technical Metrics
- [ ] Uptime > 99%
- [ ] Response time < 3s
- [ ] Error rate < 1%

### Product Metrics
- [ ] 100 signups
- [ ] 50 active users (7 dias)
- [ ] 10 paying users
- [ ] $500 MRR

### Quality Metrics
- [ ] NPS > 40
- [ ] Time-to-value < 5 min
- [ ] Churn < 10%

---

## TROUBLESHOOTING COMUM

### OpenClaw não conecta WhatsApp
```bash
# Check baileys version
pnpm list @whiskeysockets/baileys

# Re-pair
rm -rf .openclaw/whatsapp-session
openclaw gateway
# Scan QR again
```

### Hermes agent timeout
```bash
# Increase timeout
export HERMES_TIMEOUT=300

# Check logs
hermes logs --tail 100
```

### Firecrawl rate limit
```bash
# Add retry logic
cat > ~/.hermes/skills/firecrawl_with_retry.py << 'EOF'
import time
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def crawl_with_retry(url):
    # Your firecrawl call here
    pass
EOF
```

### Out of memory
```bash
# Increase swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## PRÓXIMOS PASSOS APÓS MVP

1. **Add payment** (Stripe integration)
2. **Analytics** (Mixpanel/PostHog)
3. **Better UI** (React dashboard)
4. **Email notifications**
5. **Slack integration**
6. **API documentation**
7. **Customer support** (Intercom)
8. **Scale infrastructure** (Kubernetes)
9. **Add more agents** (vertical specialists)
10. **Fundraise** (Seed round)

---

## COMANDOS ÚTEIS

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# Logs
docker-compose logs -f [service_name]

# Restart service
docker-compose restart [service_name]

# Update images
docker-compose pull
docker-compose up -d

# Database backup
docker exec postgres pg_dump -U user dbname > backup.sql

# Restore
docker exec -i postgres psql -U user dbname < backup.sql

# Check disk space
df -h

# Check memory
free -h

# Process list
docker-compose ps
```

---

## SUPPORT RESOURCES

- OpenClaw: https://docs.openclaw.ai
- Hermes: https://hermes-agent.nousresearch.com/docs
- Firecrawl: https://docs.firecrawl.dev
- Langflow: https://docs.langflow.org
- Open-WebUI: https://docs.openwebui.com

---

**AGORA É SÓ EXECUTAR.**

**Dia 1: Setup infra**
**Dia 7: Gateway rodando**
**Dia 14: Primeiro agente**
**Dia 30: Interface web**
**Dia 60: Workflows**
**Dia 90: Primeiro cliente pagando**

**LET'S BUILD.**
