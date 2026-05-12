# SPIRIT 🔮
**Strategic Predictive Intelligence & Research Intelligence Technology**

> Plataforma de Decisão Aumentada por IA que simula o futuro antes de você decidir.

---

## O QUE É SPIRIT

SPIRIT combina 7 tecnologias open-source em uma plataforma única:

- **OpenClaw** - Gateway orquestrador multi-canal
- **Hermes Agent** - Agentes autônomos com learning loop
- **MiroFish** - Simulação multi-agente para predição
- **Firecrawl** - Web scraping LLM-ready
- **Langflow** - Visual workflow builder
- **Open-WebUI** - Interface web para LLMs
- **Supabase** - Backend + Database

**Resultado:** Sistema que pesquisa web, simula cenários futuros, e recomenda decisões baseadas em dados.

---

## QUICK START

```bash
# 1. Clone
git clone https://github.com/SEU_USERNAME/SPIRIT.git
cd SPIRIT

# 2. Configure
cp .env.example .env
# Edite .env com suas API keys

# 3. Start
docker-compose up -d

# 4. Access
# Web UI: http://localhost:3000
# Gateway: http://localhost:18789
# Langflow: http://localhost:7860
```

**Pronto.** WhatsApp conecta no gateway, agentes começam a trabalhar.

---

## ARQUITETURA

```
┌─────────────────────────────────────────┐
│          USER INTERFACES                │
│  WhatsApp │ Telegram │ Slack │ Web     │
└──────────────────┬──────────────────────┘
                   │
         ┌─────────▼─────────┐
         │  OpenClaw Gateway │
         │   Port: 18789     │
         └─────────┬─────────┘
                   │
         ┌─────────▼─────────┐
         │  Hermes Agents    │
         │  (Orchestration)  │
         └─────────┬─────────┘
                   │
    ┌──────────────┼──────────────┐
    │              │              │
┌───▼───┐    ┌────▼────┐    ┌───▼────┐
│Firecrawl│  │MiroFish │  │Langflow│
│Web Data │  │Simulate │  │Workflow│
└─────────┘  └─────────┘  └────────┘
                   │
         ┌─────────▼─────────┐
         │   Open-WebUI      │
         │   Port: 3000      │
         └───────────────────┘
```

---

## FEATURES

### ✅ Implementado
- [x] Gateway multi-canal (WhatsApp, Telegram, Slack)
- [x] Agent orchestration (Hermes)
- [x] Web scraping (Firecrawl)
- [x] Interface web (Open-WebUI)
- [x] Docker deployment
- [x] PostgreSQL + Redis

### 🚧 Em Desenvolvimento
- [ ] Simulação multi-agente (MiroFish)
- [ ] Visual workflows (Langflow)
- [ ] RAG + knowledge base
- [ ] API REST pública
- [ ] Mobile apps

### 🔮 Roadmap
- [ ] Custom AI models fine-tuned
- [ ] Vertical solutions (Finance, Healthcare)
- [ ] Autonomous decision execution
- [ ] Multi-language support

---

## CASOS DE USO

### Business Strategy
**Input:** "Devo expandir para o mercado brasileiro?"
**Process:**
1. Research agent coleta dados de mercado
2. Simulation agent simula 500 cenários
3. Report agent compila análise completa

**Output:** Recomendação + probabilidades + riscos + action plan

### Product Launch
**Input:** "Melhor timing para lançar produto X?"
**Process:**
1. Web crawling de tendências
2. Competitor analysis
3. Market simulation
4. Scenario comparison

**Output:** Timing otimizado + estratégia de pricing + go-to-market plan

### Investment Decision
**Input:** "Vale a pena investir em empresa Y?"
**Process:**
1. Financial data collection
2. Market position analysis
3. Risk simulation
4. ROI projection

**Output:** Investment recommendation + risk assessment + exit strategy

---

## TECH STACK

**Backend:**
- Python 3.11+ (Hermes, MiroFish, Langflow)
- Node.js 18+ (OpenClaw)
- FastAPI (APIs)

**Frontend:**
- React 18 + TypeScript
- Svelte (Open-WebUI)
- TailwindCSS

**Database:**
- PostgreSQL (Supabase)
- SQLite (Hermes memory)
- Redis (cache)
- Qdrant (vector DB)

**AI/ML:**
- Anthropic Claude
- OpenAI GPT-4
- Google Gemini
- Ollama (local)

**Infrastructure:**
- Docker + Docker Compose
- Nginx (reverse proxy)
- Let's Encrypt (SSL)

---

## STRUCTURE

```
SPIRIT/
├── gateway/              # OpenClaw gateway
│   ├── src/
│   ├── config/
│   └── Dockerfile
├── agents/               # Hermes agents
│   ├── orchestrator/
│   ├── workers/
│   ├── skills/
│   └── Dockerfile
├── simulation/           # MiroFish
│   ├── engine/
│   ├── scenarios/
│   └── Dockerfile
├── scraper/              # Firecrawl integration
│   ├── api/
│   └── config/
├── workflows/            # Langflow
│   ├── flows/
│   └── components/
├── ui/                   # Open-WebUI
│   ├── frontend/
│   ├── backend/
│   └── Dockerfile
├── infra/                # Infrastructure
│   ├── nginx/
│   ├── postgres/
│   └── redis/
├── docs/                 # Documentation
│   ├── architecture.md
│   ├── api.md
│   └── deployment.md
├── scripts/              # Setup scripts
│   ├── setup.sh
│   ├── deploy.sh
│   └── backup.sh
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## DEPLOYMENT

### Local Development

```bash
# Start services
docker-compose up -d

# Check logs
docker-compose logs -f

# Stop
docker-compose down
```

### Production (VPS)

```bash
# 1. Setup server
./scripts/setup.sh

# 2. Configure domain
# Edit nginx/nginx.conf

# 3. SSL
./scripts/ssl-setup.sh

# 4. Deploy
./scripts/deploy.sh

# 5. Monitor
docker-compose logs -f
```

### Kubernetes

```bash
# Apply configs
kubectl apply -f k8s/

# Check status
kubectl get pods -n spirit

# Scale
kubectl scale deployment hermes-worker --replicas=5
```

---

## CONFIGURATION

### API Keys Required

```bash
# LLMs
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...

# Services
FIRECRAWL_API_KEY=fc-...
SUPABASE_URL=https://...
SUPABASE_KEY=...

# Infrastructure
POSTGRES_PASSWORD=...
REDIS_PASSWORD=...
JWT_SECRET=...
```

### Optional

```bash
# Messaging
TELEGRAM_BOT_TOKEN=...
SLACK_BOT_TOKEN=...
DISCORD_BOT_TOKEN=...

# Monitoring
SENTRY_DSN=...
DATADOG_API_KEY=...

# Email
SENDGRID_API_KEY=...
```

---

## API

### REST Endpoints

```bash
# Decision endpoint
POST /api/v1/decisions
{
  "query": "Should we launch product X?",
  "context": {...},
  "simulation_depth": "high"
}

# Response
{
  "decision_id": "dec_123",
  "recommendation": "Launch in Q3 2026",
  "confidence": 0.78,
  "scenarios": [...],
  "risks": [...],
  "action_plan": [...]
}
```

### WebSocket

```javascript
// Connect to gateway
const ws = new WebSocket('ws://localhost:18789');

// Send message
ws.send(JSON.stringify({
  type: 'chat',
  payload: { text: 'Analyze market trends' }
}));

// Receive response
ws.on('message', (data) => {
  const msg = JSON.parse(data);
  console.log(msg.type, msg.payload);
});
```

---

## MONITORING

### Metrics

- **Decisions/day:** Target 1000+
- **Avg response time:** < 30s
- **Simulation accuracy:** > 75%
- **Uptime:** > 99.9%

### Dashboards

- Grafana: http://localhost:3001
- Prometheus: http://localhost:9090
- Logs: docker-compose logs -f

---

## CONTRIBUTING

1. Fork repo
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push branch (`git push origin feature/amazing`)
5. Open Pull Request

---

## SECURITY

- All API keys in environment variables
- JWT authentication for API
- Rate limiting enabled
- Input validation on all endpoints
- SQL injection protection
- XSS prevention
- CORS configured
- SSL/TLS enforced in production

**Report vulnerabilities:** security@spirit.ai

---

## LICENSE

MIT License - use, modify, distribute freely.

Repositories integrados mantêm suas licenças originais:
- OpenClaw: MIT
- Hermes Agent: MIT
- MiroFish: MIT
- Firecrawl: AGPL-3.0
- Langflow: MIT
- Open-WebUI: MIT

---

## SUPPORT

- **Docs:** https://docs.spirit.ai
- **Discord:** https://discord.gg/spirit
- **Twitter:** @spirit_ai
- **Email:** support@spirit.ai

---

## ROADMAP

### Q2 2026
- [x] MVP launch
- [x] WhatsApp integration
- [ ] 100 beta users

### Q3 2026
- [ ] API marketplace
- [ ] Mobile apps (iOS/Android)
- [ ] 1000 paying users

### Q4 2026
- [ ] Vertical solutions
- [ ] Enterprise features
- [ ] Series A funding

### 2027
- [ ] International expansion
- [ ] 10k+ users
- [ ] Category leadership

---

## ACKNOWLEDGMENTS

Built on the shoulders of giants:

- [OpenClaw](https://github.com/openclaw/openclaw) - AI agent gateway
- [Hermes Agent](https://github.com/NousResearch/hermes-agent) - Self-improving AI agent
- [MiroFish](https://github.com/666ghj/MiroFish) - Swarm intelligence engine
- [Firecrawl](https://github.com/firecrawl/firecrawl) - Web scraping for AI
- [Langflow](https://github.com/langflow-ai/langflow) - Visual AI workflows
- [Open-WebUI](https://github.com/open-webui/open-webui) - LLM interface

---

## STATS

![GitHub stars](https://img.shields.io/github/stars/SEU_USERNAME/SPIRIT)
![GitHub forks](https://img.shields.io/github/forks/SEU_USERNAME/SPIRIT)
![GitHub issues](https://img.shields.io/github/issues/SEU_USERNAME/SPIRIT)
![License](https://img.shields.io/github/license/SEU_USERNAME/SPIRIT)

---

**Made with 🔮 by [Seu Nome]**

**"Stop guessing. Start knowing."**
