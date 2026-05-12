# SPIRIT - Diagrama de Arquitetura Técnica

## 1. VISÃO GERAL DO SISTEMA

```mermaid
graph TB
    subgraph "USER INTERFACES"
        WA[WhatsApp]
        TG[Telegram]
        SL[Slack]
        WEB[Web Dashboard]
        API[REST API]
    end

    subgraph "GATEWAY LAYER - OpenClaw"
        GW[WebSocket Gateway :18789]
        ROUTER[Message Router]
        SESSION[Session Manager]
        CRON[Cron Scheduler]
    end

    subgraph "AGENT ORCHESTRATION - Hermes"
        ORCH[Orchestrator Agent<br/>Claude Opus]
        
        subgraph "Agent Fleet"
            R[Research Agent<br/>Web Analysis]
            D[Data Agent<br/>Firecrawl]
            S[Simulation Agent<br/>MiroFish]
            W[Workflow Agent<br/>Langflow]
            REP[Report Agent<br/>Output]
        end
        
        MEM[(Memory DB<br/>SQLite + FTS5)]
        SKILLS[Skills Registry]
    end

    subgraph "DATA LAYER"
        FC[Firecrawl API]
        VDB[(Vector DB<br/>Chroma)]
        PG[(PostgreSQL<br/>Supabase)]
        REDIS[(Redis Cache)]
    end

    subgraph "SIMULATION ENGINE"
        MF[MiroFish<br/>OASIS Engine]
        AGENTS[Agent Swarm<br/>1000+ instances]
        SIM_DB[(Simulation State)]
    end

    subgraph "WORKFLOW ENGINE"
        LF[Langflow Visual IDE]
        FLOWS[Flow Executor]
        COMPONENTS[Component Registry]
    end

    subgraph "UI LAYER"
        WEBUI[Open-WebUI]
        CHAT[Chat Interface]
        DASH[Dashboard]
        VIZ[Visualization]
    end

    WA --> GW
    TG --> GW
    SL --> GW
    WEB --> GW
    API --> GW

    GW --> ROUTER
    ROUTER --> SESSION
    ROUTER --> ORCH

    ORCH --> R
    ORCH --> D
    ORCH --> S
    ORCH --> W
    ORCH --> REP

    R --> FC
    D --> FC
    FC --> VDB
    
    S --> MF
    MF --> AGENTS
    AGENTS --> SIM_DB

    W --> LF
    LF --> FLOWS
    FLOWS --> COMPONENTS

    R --> MEM
    D --> MEM
    S --> MEM
    W --> MEM
    REP --> MEM

    ORCH --> PG
    ORCH --> REDIS

    WEBUI --> CHAT
    WEBUI --> DASH
    WEBUI --> VIZ
    WEBUI --> GW

    REP --> WEBUI

    style ORCH fill:#8b5cf6
    style MF fill:#ec4899
    style FC fill:#3b82f6
    style GW fill:#10b981
```

## 2. FLUXO DE DECISÃO DETALHADO

```mermaid
sequenceDiagram
    participant U as User (WhatsApp)
    participant G as Gateway (OpenClaw)
    participant O as Orchestrator
    participant R as Research Agent
    participant D as Data Agent
    participant S as Simulation Agent
    participant M as MiroFish
    participant Rep as Report Agent
    participant W as WebUI

    U->>G: "Devo lançar produto X em Q3?"
    G->>O: Route message + context
    
    Note over O: Analyze request<br/>Create execution plan
    
    O->>R: Research market trends
    R->>D: Trigger web crawl
    
    par Parallel Data Collection
        D->>D: Firecrawl: competitors
        D->>D: Firecrawl: market data
        D->>D: Firecrawl: social sentiment
    end
    
    D->>R: Return structured data
    R->>O: Market analysis complete
    
    O->>S: Run simulations with data
    S->>M: Initialize simulation
    
    Note over M: Create 1000 agents<br/>Run 500 scenarios<br/>Test variations
    
    M->>S: Simulation results
    S->>O: Predictions + probabilities
    
    O->>Rep: Compile comprehensive report
    
    par Report Generation
        Rep->>Rep: Executive summary
        Rep->>Rep: Detailed analysis
        Rep->>Rep: Action plan
        Rep->>Rep: Interactive dashboard
    end
    
    Rep->>W: Upload to WebUI
    Rep->>G: Send WhatsApp summary
    G->>U: "✅ Analysis complete [link]"
    
    U->>W: Access full dashboard
    W->>U: Interactive visualization
```

## 3. ARQUITETURA DE DADOS

```mermaid
graph LR
    subgraph "Data Sources"
        WEB[Web Pages<br/>Firecrawl]
        INT[Internal Docs<br/>Upload]
        API_EXT[External APIs<br/>Integrations]
    end

    subgraph "Ingestion Layer"
        ETL[ETL Pipeline]
        PARSE[Parsers<br/>PDF/DOC/HTML]
        CLEAN[Data Cleaning]
    end

    subgraph "Storage Layer"
        RAW[(Raw Data<br/>S3/Blob)]
        VEC[(Vector Store<br/>Chroma)]
        REL[(Relational<br/>Supabase)]
        CACHE[(Cache<br/>Redis)]
    end

    subgraph "Processing Layer"
        EMB[Embeddings<br/>OpenAI/Local]
        INDEX[Indexing<br/>FTS5]
        SEARCH[Semantic Search]
    end

    subgraph "Consumption Layer"
        RAG[RAG Engine]
        AGENTS[Agent Memory]
        ANALYTICS[Analytics]
    end

    WEB --> ETL
    INT --> ETL
    API_EXT --> ETL

    ETL --> PARSE
    PARSE --> CLEAN

    CLEAN --> RAW
    CLEAN --> VEC
    CLEAN --> REL

    RAW --> EMB
    EMB --> VEC
    VEC --> INDEX
    INDEX --> SEARCH

    SEARCH --> RAG
    SEARCH --> AGENTS
    REL --> ANALYTICS

    VEC --> CACHE
    REL --> CACHE
```

## 4. DEPLOYMENT ARCHITECTURE

```mermaid
graph TB
    subgraph "Edge Layer"
        CF[Cloudflare CDN]
        LB[Load Balancer]
    end

    subgraph "Application Tier"
        subgraph "Gateway Cluster"
            GW1[OpenClaw 1]
            GW2[OpenClaw 2]
            GW3[OpenClaw 3]
        end

        subgraph "Agent Tier"
            subgraph "Orchestrators"
                O1[Orchestrator 1]
                O2[Orchestrator 2]
            end
            
            subgraph "Worker Pool"
                W1[Worker 1-10]
                W2[Worker 11-20]
                W3[Worker 21-30]
            end
        end

        subgraph "UI Tier"
            UI1[WebUI 1]
            UI2[WebUI 2]
        end
    end

    subgraph "Service Layer"
        FC_SVC[Firecrawl Service]
        MF_SVC[MiroFish Service]
        LF_SVC[Langflow Service]
    end

    subgraph "Data Tier"
        PG_MASTER[(PostgreSQL<br/>Master)]
        PG_REPLICA[(PostgreSQL<br/>Replica)]
        REDIS_CLUSTER[(Redis Cluster)]
        VEC_CLUSTER[(Vector DB<br/>Cluster)]
    end

    subgraph "Message Queue"
        MQ[RabbitMQ/Redis]
    end

    CF --> LB
    LB --> GW1
    LB --> GW2
    LB --> GW3
    LB --> UI1
    LB --> UI2

    GW1 --> MQ
    GW2 --> MQ
    GW3 --> MQ

    MQ --> O1
    MQ --> O2

    O1 --> W1
    O1 --> W2
    O2 --> W3

    W1 --> FC_SVC
    W2 --> MF_SVC
    W3 --> LF_SVC

    O1 --> PG_MASTER
    O2 --> PG_MASTER
    PG_MASTER --> PG_REPLICA

    W1 --> REDIS_CLUSTER
    W2 --> REDIS_CLUSTER
    W3 --> VEC_CLUSTER

    style PG_MASTER fill:#ec4899
    style REDIS_CLUSTER fill:#8b5cf6
    style VEC_CLUSTER fill:#3b82f6
```

## 5. MULTI-TENANT ARCHITECTURE

```mermaid
graph TB
    subgraph "Request Flow"
        REQ[User Request]
        AUTH[Authentication]
        TENANT[Tenant Resolver]
    end

    subgraph "Tenant Isolation"
        T1[Tenant 1<br/>Workspace]
        T2[Tenant 2<br/>Workspace]
        T3[Tenant 3<br/>Workspace]
    end

    subgraph "Shared Services"
        LLM[LLM Pool<br/>Shared]
        CRAWLER[Firecrawl Pool<br/>Shared]
    end

    subgraph "Isolated Resources"
        subgraph "Tenant 1 Resources"
            DB1[(Database<br/>Schema T1)]
            VEC1[(Vector Store<br/>Namespace T1)]
            AGENT1[Agent Pool<br/>T1]
        end

        subgraph "Tenant 2 Resources"
            DB2[(Database<br/>Schema T2)]
            VEC2[(Vector Store<br/>Namespace T2)]
            AGENT2[Agent Pool<br/>T2]
        end
    end

    REQ --> AUTH
    AUTH --> TENANT
    
    TENANT --> T1
    TENANT --> T2
    TENANT --> T3

    T1 --> DB1
    T1 --> VEC1
    T1 --> AGENT1

    T2 --> DB2
    T2 --> VEC2
    T2 --> AGENT2

    AGENT1 --> LLM
    AGENT2 --> LLM
    AGENT1 --> CRAWLER
    AGENT2 --> CRAWLER

    style DB1 fill:#ec4899
    style DB2 fill:#ec4899
    style LLM fill:#8b5cf6
    style CRAWLER fill:#3b82f6
```

## 6. SECURITY ARCHITECTURE

```mermaid
graph TB
    subgraph "External"
        USER[User]
        ATTACK[Attacker]
    end

    subgraph "Security Perimeter"
        WAF[WAF<br/>Cloudflare]
        DDOS[DDoS Protection]
        SSL[SSL/TLS]
    end

    subgraph "Authentication"
        OAUTH[OAuth 2.0]
        JWT[JWT Tokens]
        MFA[2FA/MFA]
    end

    subgraph "Authorization"
        RBAC[RBAC Engine]
        POLICY[Policy Engine]
        AUDIT[Audit Log]
    end

    subgraph "Application Security"
        INPUT[Input Validation]
        SANITIZE[Data Sanitization]
        RATE[Rate Limiting]
    end

    subgraph "Data Security"
        ENCRYPT[Encryption at Rest]
        TLS[TLS in Transit]
        VAULT[Secrets Vault]
    end

    subgraph "Network Security"
        VPC[VPC Isolation]
        FW[Firewall Rules]
        PRIV[Private Subnets]
    end

    USER --> WAF
    ATTACK --> WAF
    WAF --> DDOS
    DDOS --> SSL

    SSL --> OAUTH
    OAUTH --> JWT
    JWT --> MFA

    MFA --> RBAC
    RBAC --> POLICY
    POLICY --> AUDIT

    AUDIT --> INPUT
    INPUT --> SANITIZE
    SANITIZE --> RATE

    RATE --> ENCRYPT
    ENCRYPT --> TLS
    TLS --> VAULT

    VAULT --> VPC
    VPC --> FW
    FW --> PRIV

    style WAF fill:#ef4444
    style ENCRYPT fill:#8b5cf6
    style VAULT fill:#ec4899
```

## 7. MONITORING & OBSERVABILITY

```mermaid
graph TB
    subgraph "Application Metrics"
        APP[Application<br/>Logs]
        PERF[Performance<br/>Metrics]
        ERR[Error<br/>Tracking]
    end

    subgraph "Infrastructure Metrics"
        CPU[CPU Usage]
        MEM[Memory]
        DISK[Disk I/O]
        NET[Network]
    end

    subgraph "Business Metrics"
        USER_M[User Activity]
        DEC[Decisions Made]
        API_USAGE[API Usage]
        COST[Cost per Decision]
    end

    subgraph "Collection Layer"
        PROM[Prometheus]
        LOKI[Loki<br/>Logs]
        JAEGER[Jaeger<br/>Traces]
    end

    subgraph "Visualization"
        GRAF[Grafana<br/>Dashboards]
    end

    subgraph "Alerting"
        ALERT[Alert Manager]
        ONCALL[On-Call<br/>PagerDuty]
        SLACK_ALERT[Slack<br/>Notifications]
    end

    APP --> LOKI
    PERF --> PROM
    ERR --> PROM

    CPU --> PROM
    MEM --> PROM
    DISK --> PROM
    NET --> PROM

    USER_M --> PROM
    DEC --> PROM
    API_USAGE --> PROM
    COST --> PROM

    PROM --> GRAF
    LOKI --> GRAF
    JAEGER --> GRAF

    PROM --> ALERT
    ALERT --> ONCALL
    ALERT --> SLACK_ALERT

    style PROM fill:#ec4899
    style GRAF fill:#8b5cf6
    style ALERT fill:#ef4444
```

## 8. CI/CD PIPELINE

```mermaid
graph LR
    subgraph "Development"
        DEV[Developer]
        GIT[Git Push]
    end

    subgraph "CI Stage"
        BUILD[Build]
        TEST[Unit Tests]
        LINT[Linting]
        SEC[Security Scan]
    end

    subgraph "CD Stage"
        CONTAINER[Docker Build]
        REG[Container Registry]
        DEPLOY[Deploy to K8s]
    end

    subgraph "Environments"
        STAGING[Staging]
        CANARY[Canary]
        PROD[Production]
    end

    subgraph "Validation"
        SMOKE[Smoke Tests]
        INTEGRATION[Integration Tests]
        MONITOR[Monitoring Check]
    end

    subgraph "Rollback"
        ALERT_FAIL[Alert on Failure]
        AUTO_ROLLBACK[Auto Rollback]
    end

    DEV --> GIT
    GIT --> BUILD
    BUILD --> TEST
    TEST --> LINT
    LINT --> SEC

    SEC --> CONTAINER
    CONTAINER --> REG
    REG --> DEPLOY

    DEPLOY --> STAGING
    STAGING --> SMOKE
    SMOKE --> CANARY
    CANARY --> INTEGRATION
    INTEGRATION --> MONITOR
    MONITOR --> PROD

    MONITOR --> ALERT_FAIL
    ALERT_FAIL --> AUTO_ROLLBACK
    AUTO_ROLLBACK --> CANARY

    style SEC fill:#ef4444
    style PROD fill:#10b981
    style AUTO_ROLLBACK fill:#ec4899
```

## TECH STACK SUMMARY

**Gateway:** OpenClaw (Node.js, WebSocket)
**Agents:** Hermes (Python 3.11+, SQLite)
**Simulation:** MiroFish (Python, OASIS)
**Data:** Firecrawl (REST API, Fire-engine)
**Workflow:** Langflow (Python, React)
**UI:** Open-WebUI (Svelte, Python)
**Database:** PostgreSQL (Supabase), Redis
**Vector:** Chroma/Qdrant
**Deployment:** Docker, Kubernetes
**Monitoring:** Prometheus, Grafana
**CI/CD:** GitHub Actions, ArgoCD
