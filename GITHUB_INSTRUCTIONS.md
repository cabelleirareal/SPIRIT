# 🔮 SPIRIT - Instruções para GitHub

## CRIAR REPOSITÓRIO NO GITHUB

### 1. Via GitHub Web

1. Acesse: https://github.com/new
2. **Repository name:** `SPIRIT`
3. **Description:** `Strategic Predictive Intelligence & Research Intelligence Technology - AI-powered decision platform`
4. **Visibility:** Public (ou Private se preferir)
5. **NÃO** marque "Initialize with README" (já temos)
6. Click **"Create repository"**

### 2. Push do Código Local

```bash
# Adicione o remote (substitua SEU_USERNAME)
cd /home/claude/spirit
git remote add origin https://github.com/SEU_USERNAME/SPIRIT.git

# Push
git branch -M main
git push -u origin main
```

### 3. Configurar GitHub (Opcional)

#### Topics/Tags (no repositório)
- ai
- decision-intelligence
- multi-agent
- langchain
- docker
- whatsapp-bot
- predictive-analytics

#### About
```
Strategic Predictive Intelligence & Research Intelligence Technology - AI platform that simulates the future before you decide. WhatsApp-first interface, multi-agent orchestration, predictive simulations.
```

#### Website
```
https://spirit.ai
```

---

## SE PRECISAR DE TOKEN (2FA habilitado)

### Criar Personal Access Token

1. GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Generate new token (classic)
3. **Note:** "SPIRIT Repository Access"
4. **Expiration:** 90 days (ou No expiration)
5. **Scopes:** Marcar `repo` (full control)
6. Generate token
7. **COPIE O TOKEN** (só aparece uma vez)

### Push com Token

```bash
git remote set-url origin https://TOKEN@github.com/SEU_USERNAME/SPIRIT.git
git push -u origin main
```

Onde `TOKEN` é o token que você copiou.

---

## DEPOIS DO PUSH

### 1. Adicionar Badges ao README

Edite o README.md no GitHub ou localmente:

```markdown
![GitHub stars](https://img.shields.io/github/stars/SEU_USERNAME/SPIRIT)
![GitHub forks](https://img.shields.io/github/forks/SEU_USERNAME/SPIRIT)
![GitHub issues](https://img.shields.io/github/issues/SEU_USERNAME/SPIRIT)
![License](https://img.shields.io/github/license/SEU_USERNAME/SPIRIT)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Python](https://img.shields.io/badge/python-3.11+-blue)
![Node](https://img.shields.io/badge/node-18+-green)
```

### 2. Create Release

1. GitHub > Releases > Create a new release
2. **Tag version:** `v1.0.0`
3. **Release title:** `SPIRIT v1.0.0 - Initial Release`
4. **Description:**
```markdown
## 🔮 SPIRIT v1.0.0 - Initial Release

Strategic Predictive Intelligence & Research Intelligence Technology

### Features
- ✅ Multi-channel gateway (WhatsApp, Telegram, Slack, Web)
- ✅ AI agent orchestration (Hermes-based)
- ✅ Web scraping (Firecrawl integration)
- ✅ Visual workflows (Langflow)
- ✅ Modern Web UI (Open-WebUI)
- ✅ Full Docker stack
- ✅ Production-ready

### Quick Start
```bash
git clone https://github.com/SEU_USERNAME/SPIRIT.git
cd SPIRIT
cp .env.example .env
# Edit .env with your API keys
./scripts/setup.sh
```

Access: http://localhost:3000

### Tech Stack
- Node.js 18+ (Gateway)
- Python 3.11+ (Agents)
- Docker + Docker Compose
- PostgreSQL + Redis + Qdrant
- Nginx

### Documentation
- [Quick Start](QUICKSTART.md)
- [Full README](README.md)

### Support
- [Issues](https://github.com/SEU_USERNAME/SPIRIT/issues)
- [Discussions](https://github.com/SEU_USERNAME/SPIRIT/discussions)
```

5. Publish release

### 3. Habilitar GitHub Actions (opcional)

Criar `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker images
        run: docker-compose build
      - name: Test
        run: docker-compose up -d && sleep 10 && docker-compose ps
```

---

## COMANDOS ÚTEIS GIT

```bash
# Ver status
git status

# Ver commits
git log --oneline

# Criar branch
git checkout -b feature/nova-feature

# Push branch
git push origin feature/nova-feature

# Atualizar do remote
git pull origin main

# Ver remotes
git remote -v
```

---

## ESTRUTURA FINAL NO GITHUB

```
SEU_USERNAME/SPIRIT
├── README.md (⭐ página principal)
├── QUICKSTART.md
├── LICENSE (MIT)
├── .env.example
├── docker-compose.yml
├── gateway/
├── agents/
├── infra/
├── scripts/
└── docs/
```

---

## PRÓXIMOS PASSOS

1. ✅ Push código
2. ✅ Criar release v1.0.0
3. ✅ Adicionar badges
4. 🔄 Criar issues para features
5. 🔄 Setup GitHub Projects
6. 🔄 Criar Wiki
7. 🔄 Launch Product Hunt
8. 🔄 Post no Twitter/LinkedIn

---

## MARKETING GITHUB

### Profile README

Se não tiver, crie repositório com seu username:
`https://github.com/SEU_USERNAME/SEU_USERNAME`

Adicione no README.md:

```markdown
## 🔮 SPIRIT - Decision Intelligence Platform

I'm building SPIRIT, an AI platform that simulates the future before you decide.

⚡ WhatsApp-first interface
🤖 Multi-agent orchestration  
🔮 Predictive simulations
📊 Data-driven decisions

→ [Check it out](https://github.com/SEU_USERNAME/SPIRIT)
```

### Social Media Post

**Twitter/X:**
```
Just open-sourced SPIRIT 🔮 - an AI decision platform that SIMULATES the future before you commit.

✨ Features:
• WhatsApp-first (zero friction)
• Multi-agent swarm
• Predictive scenarios
• Web scraping built-in

Built with: Claude, Docker, Python, Node.js

→ github.com/SEU_USERNAME/SPIRIT

#AI #OpenSource #DecisionIntelligence
```

**LinkedIn:**
```
Excited to share SPIRIT - Strategic Predictive Intelligence & Research Intelligence Technology 🔮

A new approach to decision-making: instead of gut feeling or static analysis, SPIRIT simulates hundreds of future scenarios using AI agents and returns data-driven recommendations.

Key innovations:
• WhatsApp-first interface (accessible to anyone)
• Multi-agent orchestration (divide & conquer)
• Scenario simulation (predict outcomes)
• Real-time web scraping (always current data)

Tech stack: Claude Sonnet, Docker, Python, Node.js, PostgreSQL

Completely open-source. MIT license.

→ github.com/SEU_USERNAME/SPIRIT

What decisions would you simulate first?

#ArtificialIntelligence #OpenSource #DecisionScience #StartupTech
```

---

**PRONTO!** Repositório completo e pronto para lançamento. 🚀
