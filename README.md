# aiproject

┌─────────────────────────────────────────────────────────┐
│                  podman ecomm_watcher                   │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐  │
│  │   MariaDB   │  │  FastAPI    │  │   Vite React   │  │
│  │   :3306     │  │  :8000      │  │   :3000        │  │
│  └─────────────┘  └─────────────┘  └────────────────┘  │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐                       │
│  │ CSV Watcher │  │  start.sh   │                       │
│  │  /drop_here │  │ orchestrate │                       │
│  └─────────────┘  └─────────────┘                       │
└─────────────────────────────────────────────────────────┘
         │                              │
   /drop_here (csv)              /app/finished
   host mount only               host mount only


┌─────────────────────────────────────────────────────────────────────┐
│                    RUNNING INSIDE ONE PODMAN CONTAINER              │
├─────────────────────────────────────────────────────────────────────┤
│  ✅ MariaDB    — stores all sales data + AI insights cache          │
│  ✅ FastAPI    — serves all data endpoints                          │
│  ✅ React      — dashboard UI                                       │
│  ✅ Watcher    — CSV drop processor                                 │
└─────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────┐
│  STEP 1 — Associate types in AI Analyst tab:                        │
│  "Who are our top 5 customers by revenue this year?"               │
│                                                                     │
│           React AiPanel.tsx                                         │
│                │                                                    │
│                ▼                                                    │
│  STEP 2 — api.ts sends POST to:                                    │
│           /ai/ask                                                   │
│           { "question": "Who are our top 5 customers..." }         │
│                │                                                    │
│                ▼                                                    │
│  STEP 3 — FastAPI main.py receives request                         │
│           calls ask_claude() in ai_service.py                      │
│                │                                                    │
│                ▼                                                    │
│  STEP 4 — ai_service.py generates question_hash                    │
│           SHA256 of the question text                              │
│           checks ai_insights table:                                │
│           SELECT * FROM ai_insights                                │
│           WHERE question_hash = 'abc123...'                        │
│           AND expires_at > NOW()                                   │
│                │                                                    │
│         ┌──────┴──────┐                                            │
│         │             │                                             │
│      FOUND          NOT FOUND                                       │
│      (cached)       (new question)                                  │
│         │             │                                             │
│         ▼             ▼                                             │
│  STEP 5a          STEP 5b                                          │
│  Return cached    fetch_sql_context() runs                         │
│  answer           FREE SQL aggregates:                             │
│  NO API cost      • top customers by revenue                       │
│  instant          • order counts                                    │
│                   • product performance                             │
│                   • employee sales totals                           │
│                        │                                            │
│                        ▼                                            │
│                   STEP 6 — Build Claude prompt:                    │
│                   SYSTEM_PROMPT (your role definition)             │
│                   + SQL results as context                         │
│                   + associate's question                           │
│                        │                                            │
│                        ▼                                            │
│                   STEP 7 — Send to Claude via                      │
│                   AnthropicVertex API                              │
│                   ⚠️  THIS IS WHERE API COST HITS                  │
│                        │                                            │
│                        ▼                                           │
│                   STEP 8 — Claude returns insight text             │
│                        │                                            │
│                        ▼                                            │
│                   STEP 9 — Save to ai_insights table:             │
│                   INSERT INTO ai_insights                          │
│                   (question_hash, question_text,                   │
│                    insight_text, tokens_used,                      │
│                    created_at, expires_at)                         │
│                        │                                            │
│                        ▼                                            │
│                   STEP 10 — Return insight to React               │
│                   Display in AI Analyst panel                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    COST BREAKDOWN PER QUESTION                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  FREE — SQL aggregates (always):                                   │
│  • Dashboard KPI cards        → pure SQL → $0.00                  │
│  • Customer table data        → pure SQL → $0.00                  │
│  • Employee table data        → pure SQL → $0.00                  │
│  • Order table data           → pure SQL → $0.00                  │
│  • Revenue charts             → pure SQL → $0.00                  │
│  • Load Archive button        → pure SQL → $0.00                  │
│                                                                     │
│  COSTS MONEY — Claude API (only on new questions):                 │
│  • First time question asked  → Claude API → ~$0.002              │
│  • Same question asked again  → cache hit  → $0.00                │
│  • Slightly different wording → new hash   → ~$0.002              │
│                                                                     │
│  TOKEN BREAKDOWN PER QUESTION:                                     │
│  Input tokens:                                                      │
│  • SYSTEM_PROMPT      ≈ 300  tokens                                │
│  • SQL context data   ≈ 500  tokens                                │
│  • User question      ≈ 50   tokens                                │
│  Total input          ≈ 850  tokens                                │
│                                                                     │
│  Output tokens:                                                     │
│  • Claude answer      ≈ 200  tokens (max_tokens=512 ceiling)       │
│                                                                     │
│  Claude Haiku pricing (Vertex AI):                                 │
│  Input:  $0.00025 per 1K tokens → 850 tokens  = $0.0002           │
│  Output: $0.00125 per 1K tokens → 200 tokens  = $0.0003           │
│  Total per new question                        ≈ $0.0005           │
│                                                                     │
│  100 unique questions per month                ≈ $0.05             │
│  1000 unique questions per month               ≈ $0.50             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘


   
