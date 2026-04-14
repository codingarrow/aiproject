<div id="top" style="background-color: #0a0a0a; color: #e0e0e0; padding: 30px; border-radius: 8px; border: 1px solid #39ff14; max-width: 100%; box-sizing: border-box; font-family: 'Courier New', Courier, monospace; box-shadow: 0 0 15px rgba(57, 255, 20, 0.1);">

  <nav style="border-bottom: 1px dashed #39ff14; padding-bottom: 20px; margin-bottom: 40px;">
    <ul style="list-style-type: none; padding: 0; margin: 0; display: flex; justify-content: center; flex-wrap: wrap; gap: 30px;">
      <li>
        <a href="#overview" style="color: #39ff14; text-decoration: none; font-size: 18px; font-weight: bold; text-shadow: 0 0 5px rgba(57, 255, 20, 0.5);"> [ Overview ]</a>
      </li>
      <li>
        <a href="#architecture" style="color: #39ff14; text-decoration: none; font-size: 18px; font-weight: bold; text-shadow: 0 0 5px rgba(57, 255, 20, 0.5);"> [ Architecture ]</a>
      </li>
      <li>
        <a href="#setup" style="color: #39ff14; text-decoration: none; font-size: 18px; font-weight: bold; text-shadow: 0 0 5px rgba(57, 255, 20, 0.5);"> [ Setup Guide ]</a>
      </li>
      <li>
        <a href="#apireference" style="color: #39ff14; text-decoration: none; font-size: 18px; font-weight: bold; text-shadow: 0 0 5px rgba(57, 255, 20, 0.5);">[ API  Reference ]</a>
      </li>      
      <li>
        <a href="#guide" style="color: #39ff14; text-decoration: none; font-size: 18px; font-weight: bold; text-shadow: 0 0 5px rgba(57, 255, 20, 0.5);"> [ AI Analyst Guide ]</a>
      </li>
      <li>
        <a href="#schema" style="color: #39ff14; text-decoration: none; font-size: 18px; font-weight: bold; text-shadow: 0 0 5px rgba(57, 255, 20, 0.5);"> [Schema]</a>
      </li>
      <li>
        <a href="#scenario" style="color: #39ff14; text-decoration: none; font-size: 18px; font-weight: bold; text-shadow: 0 0 5px rgba(57, 255, 20, 0.5);"> [Scenario]</a>
      </li>
      
    </ul>
  </nav>

  <div id="overview" style="margin-bottom: 60px; padding-top: 10px;">
    <h2 style="color: #39ff14; margin-top: 0; text-shadow: 0 0 8px rgba(57,255,20,0.6);">> Project Overview</h2>
    
    <p style="font-size: 16px; line-height: 1.6; color: #d3d3d3;">
      AI powered by Claude (Anthropic) — Backend: FastAPI + MariaDB — Frontend: Vite + React TSX.
    </p>

    <div style="background-color: #000000; padding: 16px; border-radius: 4px; border: 1px solid #1f6b11; overflow-x: auto; margin: 20px 0;">
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #39ff14; line-height: 1.2;">
┌─────────────────────────────────────────────────────────┐
│                  podman ecomm_watcher                   │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐   │
│  │   MariaDB   │  │  FastAPI    │  │   Vite React   │   │
│  │   :3306     │  │  :8000      │  │   :3000        │   │
│  └─────────────┘  └─────────────┘  └────────────────┘   │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐                       │
│  │ CSV Watcher │  │  start.sh   │                       │
│  │  /drop_here │  │ orchestrate │                       │
│  └─────────────┘  └─────────────┘                       │
└─────────────────────────────────────────────────────────┘
         │                              │
   /drop_here (csv)              /app/finished
   host mount only               host mount only
      </pre>
    </div>
    
    <a href="#top" style="color: #39ff14; text-decoration: none; font-size: 14px;">↑ Return to Top</a>
  </div>

  <div id="architecture" style="margin-bottom: 60px; padding-top: 10px;">
    <h2 style="color: #39ff14; margin-top: 0; text-shadow: 0 0 8px rgba(57,255,20,0.6);">> Architecture</h2>
    
    <p style="font-size: 16px; line-height: 1.6; color: #d3d3d3;">
    <!--
      This is the second section. Notice how clicking the navigation links above drops you exactly here. The spacing is designed to feel spacious but strictly constrained to a single-page app layout.
      -->
    </p>

    <!--ul style="list-style-type: square; margin-left: 20px; line-height: 1.8;">
      <li>MariaDB connection via internal Podman network</li>
      <li>Volume mapping to persist state</li>
      <li>Automated CSV ingestion</li>
    </ul-->

    <div style="background-color: #000000; padding: 16px; border-radius: 4px; border: 1px solid #1f6b11; overflow-x: auto; margin: 20px 0;">
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #39ff14; line-height: 1.2;">
┌─────────────────────────────────────────────────────────────────────┐
│                    RUNNING INSIDE ONE PODMAN CONTAINER              │
├─────────────────────────────────────────────────────────────────────┤
│  ✅ MariaDB    — stores all sales data + AI insights cache          │
│  ✅ FastAPI    — serves all data endpoints                          │
│  ✅ React      — dashboard UI                                       │
│  ✅ Watcher    — CSV drop processor (in progress)                   │
└─────────────────────────────────────────────────────────────────────┘

Runs compatibility on a fully provisioned containerized podman in Ubuntu 24 (latest)

Backend: FastAPI + MariaDB 
Frontend: Vite + React TSX


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
      </pre>
    </div>

    <a href="#top" style="color: #39ff14; text-decoration: none; font-size: 14px;">↑ Return to Top</a>
  </div>

  <div id="setup" style="margin-bottom: 20px; padding-top: 10px;">
    <h2 style="color: #39ff14; margin-top: 0; text-shadow: 0 0 8px rgba(57,255,20,0.6);">> Setup Guide</h2>    
    <p style="font-size: 16px; line-height: 1.6; color: #d3d3d3;">
      <!--
      Final section. Because this entire container uses <code>box-sizing: border-box</code> and <code>max-width: 100%</code>, it will perfectly scale down to mobile screens while keeping your horizontal menu wrapped and clean.
      -->
      Code is in github still in progress of refactoring and adding other features.
    </p>
    <div style="background-color: #000000; padding: 16px; border-radius: 4px; border: 1px solid #1f6b11; overflow-x: auto; margin: 20px 0;">
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #39ff14; line-height: 1.2;">

mypoc_ecommerce/
├── schema.sql                        # MariaDB schema + seed data
├── requirements.txt                  # Python dependencies
├── .env                              # Environment variables
├── Dockerfile                        # Container build
├── start.sh                          # Starts FastAPI + watcher together
├── rebuild.sh                        # Podman build + run script
├── backend/
│   ├── main.py                       # FastAPI app + all routes
│   ├── database.py                   # MariaDB connection + ORM models
│   ├── ai_service.py                 # Claude RAG integration + cache
│   └── watcher.py                    # CSV drop watcher for UPSERT
└── frontend/
    ├── index.html
    ├── package.json
    ├── tsconfig.json
    ├── vite.config.ts
    └── src/
        ├── main.tsx                  # React entry point
        ├── index.css                 # Dark neon green theme
        ├── api.ts                    # Axios instance + all typed API calls
        ├── App.tsx                   # Root component + navigation
        ├── hooks/
        │   └── useApi.ts             # Generic reusable fetch hook
        └── components/
            ├── KpiCard.tsx           # Memoized KPI metric card
            ├── DataTable.tsx         # Memoized generic data table
            ├── RevenueChart.tsx      # SVG bar chart (no external lib)
            └── AiPanel.tsx           # Claude AI question + insights archive
      </pre>
    </div>

    <a href="#top" style="color: #39ff14; text-decoration: none; font-size: 14px;">↑ Return to Top</a>
  </div>

  <div id="apireference" style="margin-bottom: 60px; padding-top: 10px;">
    <h2 style="color: #39ff14; margin-top: 0; text-shadow: 0 0 8px rgba(57,255,20,0.6);">> API  Reference</h2>
    
    <p style="font-size: 16px; line-height: 1.6; color: #d3d3d3;">
      <!--
      Final section. Because this entire container uses <code>box-sizing: border-box</code> and <code>max-width: 100%</code>, it will perfectly scale down to mobile screens while keeping your horizontal menu wrapped and clean.
      -->
    </p>
    <div style="background-color: #000000; padding: 16px; border-radius: 4px; border: 1px solid #1f6b11; overflow-x: auto; margin: 20px 0;">
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #39ff14; line-height: 1.2;">
  http://localhost:8000/getCustomer/customer_id/all
  
  http://localhost:8000/getEmployee/employee_id/all
  
  http://localhost:8000/getDashboard/summary)   
      </pre>
    </div>
    
    <a href="#top" style="color: #39ff14; text-decoration: none; font-size: 14px;">↑ Return to Top</a>
  </div>


  <div id="guide" style="margin-bottom: 60px; padding-top: 10px;">
    <h2 style="color: #39ff14; margin-top: 0; text-shadow: 0 0 8px rgba(57,255,20,0.6);">> AI Analyst Guide</h2>
    
    <p style="font-size: 16px; line-height: 1.6; color: #d3d3d3;">
      <!--
      Final section. Because this entire container uses <code>box-sizing: border-box</code> and <code>max-width: 100%</code>, it will perfectly scale down to mobile screens while keeping your horizontal menu wrapped and clean.
      -->
    </p>
    <div style="background-color: #000000; padding: 16px; border-radius: 4px; border: 1px solid #1f6b11; overflow-x: auto; margin: 20px 0;">
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #39ff14; line-height: 1.2;">
┌─────────────────────────────────────────────────────────────────────┐
│              USER / MARKETING ASSOCIATE MENTAL MODEL                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Think of it like a very smart analyst sitting next to you         │
│                                                                     │
│  The dashboard charts and tables = free reports                    │
│  already prepared — like a printed report on your desk             │
│                                                                     │
│  The AI Analyst tab = asking that smart analyst                    │
│  a specific question about those reports                           │
│  First time you ask = analyst thinks and answers = small cost      │
│  Same question again = analyst remembers = no cost                 │
│                                                                     │
│  Load Archive = reading the analyst's notebook                     │
│  of all previous questions and answers = free                      │
│                                                                     │
│  Best practice:                                                     │
│  Ask your most important questions once                            │
│  Save the answers in the archive                                   │
│  Share archive answers with the team                               │
│  Only ask NEW questions when you need new insight                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
  
      </pre>
    </div>
    
    <a href="#top" style="color: #39ff14; text-decoration: none; font-size: 14px;">↑ Return to Top</a>
  </div>

  

</div>
