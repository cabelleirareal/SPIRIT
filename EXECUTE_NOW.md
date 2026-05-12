# 🔮 CRIAR REPOSITÓRIO SPIRIT NO GITHUB

## PASSO 1: CRIAR TOKEN DO GITHUB (2 minutos)

1. Acesse: https://github.com/settings/tokens/new
2. **Note:** SPIRIT Repository
3. **Expiration:** 90 days
4. **Scopes:** Marque APENAS:
   - ✅ `repo` (Full control of private repositories)
5. Click "Generate token"
6. **COPIE O TOKEN** (só aparece uma vez)
   - Formato: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

---

## PASSO 2: EXECUTAR SCRIPT (30 segundos)

```bash
cd /home/claude/spirit
./scripts/github-setup.sh
```

**O script vai pedir:**
1. GitHub Username: `SEU_USERNAME`
2. Token: `cole o token que você copiou`

**Depois:** Script cria repo + faz push automaticamente.

---

## PRONTO!

Repositório criado em: `https://github.com/SEU_USERNAME/SPIRIT`

---

## SE DER ERRO "command not found"

```bash
bash /home/claude/spirit/scripts/github-setup.sh
```

---

## SE PREFERIR FAZER MANUAL

```bash
# 1. Crie repo em https://github.com/new
#    Nome: SPIRIT
#    Public

# 2. No terminal:
cd /home/claude/spirit
git remote add origin https://github.com/SEU_USERNAME/SPIRIT.git
git branch -M main
git push -u origin main

# Se pedir senha: use o TOKEN (não a senha do GitHub)
```

---

## DEPOIS DO PUSH

### Adicionar Topics no GitHub

No repositório, click "⚙️ Settings" ou "Add topics":
- ai
- decision-intelligence
- multi-agent
- docker
- whatsapp-bot
- predictive-analytics
- langchain
- claude
- python
- nodejs

### Criar Release v1.0.0

1. GitHub > Releases > Create a new release
2. Tag: `v1.0.0`
3. Title: `SPIRIT v1.0.0 - Initial Release`
4. Description:
```markdown
## 🔮 SPIRIT v1.0.0 - Initial Release

First public release of SPIRIT - Strategic Predictive Intelligence & Research Intelligence Technology.

### Features
- Multi-channel AI gateway (WhatsApp, Telegram, Slack, Web)
- Agent orchestration (Hermes-based)
- Web scraping integration (Firecrawl)
- Visual workflows (Langflow)
- Modern Web UI (Open-WebUI)
- Production-ready Docker stack

### Quick Start
See [QUICKSTART.md](QUICKSTART.md)

### Stack
Node.js 18+, Python 3.11+, Docker, PostgreSQL, Redis
```

5. Publish

---

## COMPARTILHAR

### Twitter/X
```
Just open-sourced SPIRIT 🔮

AI platform that simulates the future before you decide.

✨ WhatsApp-first
🤖 Multi-agent swarm
🔮 Predictive scenarios
📊 Data-driven decisions

→ github.com/SEU_USERNAME/SPIRIT

#AI #OpenSource
```

### LinkedIn
```
Excited to share SPIRIT 🔮 - a new approach to decision-making.

Instead of gut feeling, SPIRIT simulates hundreds of scenarios using AI agents and returns data-driven recommendations.

Completely open-source. MIT license.

→ github.com/SEU_USERNAME/SPIRIT
```

---

**TOTAL: 3 MINUTOS DO ZERO AO PÚBLICO.** 🚀
