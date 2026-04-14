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
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #f4f1de; line-height: 1.2;">
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

<div style="text-align: center; margin: 30px 0;">
      <img src="https://i.postimg.cc/k4jW15hy/dashboard.png" alt="Placeholder" style="border: none; max-width: 100%; height: auto; border-radius: 8px;">	
      <img src="https://i.postimg.cc/k4jW15hw/loadarchive.png" alt="Placeholder" style="border: none; max-width: 100%; height: auto; border-radius: 8px;">	
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
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #f4f1de; line-height: 1.2;">
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
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #f4f1de; line-height: 1.2;">

[yourFolder]/
├── schema.sql                        # MariaDB schema + seed data
├── requirements.txt                  # Python dependencies
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
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #f4f1de; line-height: 1.2;">
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
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #Consolas, monospace; font-size: 14px; color: #f4f1de; line-height: 1.2;">
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
  
  <div id="schema" style="margin-bottom: 60px; padding-top: 10px;">
    <h2 style="color: #39ff14; margin-top: 0; text-shadow: 0 0 8px rgba(57,255,20,0.6);">> Schema</h2>
    
    <p style="font-size: 16px; line-height: 1.6; color: #d3d3d3;">
      Schema reused from Microsoft's OG NorthWind Database (just few tables used) only ai_insights is the 
      new table
    </p>
    <div style="background-color: #000000; padding: 16px; border-radius: 4px; border: 1px solid #1f6b11; overflow-x: auto; margin: 20px 0;">
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #f4f1de; line-height: 1.2;">
CREATE TABLE orders (
    order_id smallint NOT NULL PRIMARY KEY,
    customer_id bpchar,
    employee_id smallint,
    order_date date,
    required_date date,
    shipped_date date,
    ship_via smallint,
    freight real,
    ship_name character varying(40),
    ship_address character varying(60),
    ship_city character varying(15),
    ship_region character varying(15),
    ship_postal_code character varying(10),
    ship_country character varying(15),
    FOREIGN KEY (customer_id) REFERENCES customers,
    FOREIGN KEY (employee_id) REFERENCES employees,
    FOREIGN KEY (ship_via) REFERENCES shippers
);

CREATE TABLE order_details (
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price real NOT NULL,
    quantity smallint NOT NULL,
    discount real NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES products,
    FOREIGN KEY (order_id) REFERENCES orders
);

CREATE TABLE employees (
    employee_id smallint NOT NULL PRIMARY KEY,
    last_name character varying(20) NOT NULL,
    first_name character varying(10) NOT NULL,
    title character varying(30),
    title_of_courtesy character varying(25),
    birth_date date,
    hire_date date,
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    home_phone character varying(24),
    extension character varying(4),
    photo bytea,
    notes text,
    reports_to smallint,
    photo_path character varying(255),
	FOREIGN KEY (reports_to) REFERENCES employees
);

CREATE TABLE categories (
    category_id smallint NOT NULL PRIMARY KEY,
    category_name character varying(15) NOT NULL,
    description text,
    picture bytea
);

CREATE TABLE suppliers (
    supplier_id smallint NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    fax character varying(24),
    homepage text
);

CREATE TABLE products (
    product_id smallint NOT NULL PRIMARY KEY,
    product_name character varying(40) NOT NULL,
    supplier_id smallint,
    category_id smallint,
    quantity_per_unit character varying(20),
    unit_price real,
    units_in_stock smallint,
    units_on_order smallint,
    reorder_level smallint,
    discontinued integer NOT NULL,
	FOREIGN KEY (category_id) REFERENCES categories,
	FOREIGN KEY (supplier_id) REFERENCES suppliers
);

CREATE TABLE customers (
    customer_id bpchar NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    fax character varying(24)
);

CREATE TABLE shippers (
    shipper_id smallint NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
    phone character varying(24)
);
      </pre>
    </div>
    
    <a href="#top" style="color: #39ff14; text-decoration: none; font-size: 14px;">↑ Return to Top</a>
  </div>
  
  <div id="scenario" style="margin-bottom: 60px; padding-top: 10px;">
    <h2 style="color: #39ff14; margin-top: 0; text-shadow: 0 0 8px rgba(57,255,20,0.6);">> Scenario</h2>
    
    <p style="font-size: 16px; line-height: 1.6; color: #d3d3d3;">
      <!--
      Final section. Because this entire container uses <code>box-sizing: border-box</code> and <code>max-width: 100%</code>, it will perfectly scale down to mobile screens while keeping your horizontal menu wrapped and clean.
      -->
      Where Claude is capable of ... sales related question
    </p>
    <div style="background-color: #000000; padding: 16px; border-radius: 4px; border: 1px solid #1f6b11; overflow-x: auto; margin: 20px 0;">
      <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #f4f1de; line-height: 1.2;">

┌─────────────────────────────────────────────────────────────────────┐
│                    RECOMMENDED PRESET QUESTIONS                     │
│                    FOR MARKETING ASSOCIATE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  CUSTOMER INTELLIGENCE:                                             │
│  • "Who are our top 10 customers by total revenue?"                │
│  • "Which customers have not ordered in the last 90 days?"         │
│  • "Which country generates the most revenue?"                     │
│  • "Which customers qualify for loyalty rewards?"                  │
│                                                                     │
│  PRODUCT PERFORMANCE:                                               │
│  • "Which products are selling the fastest this quarter?"          │
│  • "Which products have the highest profit margin?"                │
│  • "What products are frequently ordered together?"                │
│  • "Which products are at risk of stockout?"                       │
│                                                                     │
│  SALES TEAM PERFORMANCE:                                            │
│  • "Which employee closed the most revenue this month?"            │
│  • "Which sales rep has the most repeat customers?"                │
│  • "Which employee handles the largest average order value?"       │
│                                                                     │
│  OPERATIONAL:                                                       │
│  • "Which shipper has the best on-time delivery rate?"             │
│  • "What is the average time between order and shipment?"          │
│  • "Which orders are overdue for shipping?"                        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────┐
│                    DETERMINISTIC vs INTERPRETIVE                    │
├──────────────────────────────┬──────────────────────────────────────┤
│  DETERMINISTIC               │  INTERPRETIVE                        │
│  SQL answers perfectly       │  Claude adds real value              │
├──────────────────────────────┼──────────────────────────────────────┤
│  Who spent the most?         │  Why might Christina spend more?     │
│  Which country orders most?  │  What risk does UK market pose?      │
│  How many orders this month? │  What pattern explains low spend?    │
│  What is average order size? │  What should we do about Elizabeth?  │
└──────────────────────────────┴──────────────────────────────────────┘
    
      VERDICT:
──────────────
Asking Claude pure deterministic questions = mild overkill
SQL already answered it — Claude just repeats it with words
Small cost for low additional value

BEST PRACTICE:
──────────────
Never ask Claude WHAT the data says
Always ask Claude WHAT TO DO about what the data says

❌ WEAK:  "Which customer spent the most?"
          SQL already shows this — Claude adds nothing new

✅ STRONG: "Christina Berglund is our top spender at $6,560.86
            What retention strategy should we prioritize for her
            given she is in Sweden and orders frequently?"
            Claude now adds strategy SQL cannot compute

┌─────────────────────────────────────────────────────────────────────┐
│  Elizabeth Brown — UK — $740.29 total spent                        │
│  "What would entice Elizabeth to order more?"                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  THIS IS THE CORRECT USE OF AI — not deterministic at all          │
│  SQL cannot answer this — Claude can reason about it               │
│                                                                     │
│  WHAT CLAUDE WOULD REASON:                                          │
│  • Low spend could mean: new customer, price sensitive,            │
│    infrequent need, bad experience, competitor preference          │
│  • SQL context shows: order frequency, product categories,         │
│    last order date, average order value                            │
│  • Claude connects these to recommend specific action              │
│                                                                     │
│  MARKETING STRESS CONCERN — YOUR INSTINCT IS CORRECT:             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────┐       │
│  │  WRONG APPROACH          │  RIGHT APPROACH              │       │
│  ├──────────────────────────┼──────────────────────────────┤       │
│  │  Blast email to          │  One personalized touch      │       │
│  │  Elizabeth weekly        │  based on her order history  │       │
│  │  "We miss you!"          │                              │       │
│  │  Generic discount code   │  Specific product she        │       │
│  │  Tedious survey          │  ordered before — restocked  │       │
│  │  Reminder after reminder │  or improved version         │       │
│  │  = Elizabeth unsubscribes│  = Elizabeth feels seen      │       │
│  └──────────────────────────┴──────────────────────────────┘       │
│                                                                     │
│  BEST CLAUDE QUESTION FOR ELIZABETH:                               │
│  "Elizabeth Brown from UK has spent only $740.29 total             │
│   across 2 orders. Her last order was [date]. She ordered          │
│   [products]. What is one specific non-intrusive action            │
│   we can take to increase her engagement without                   │
│   overwhelming her with communications?"                           │
│                                                                     │
│  Claude will reason:                                                │
│  • One targeted email — not a campaign                             │
│  • Reference her specific past purchase                            │
│  • Offer relevant product — not generic discount                   │
│  • Respect her low-frequency buying pattern                        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    STRONG CLAUDE QUESTIONS                          │
│                    FOR CROSS-MARKET INSIGHT                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  QUESTION 1 — Discovery:                                            │
│  "Which non-Asian customers are ordering products                  │
│   sourced from Asian suppliers and what does this                  │
│   pattern suggest about their preferences?"                        │
│                                                                     │
│  Claude will reason:                                                │
│  • Health food trend (tofu, green tea) in Western markets          │
│  • Specialty cuisine interest                                       │
│  • Premium product seeking behavior                                │
│  • Recommend: expand Asian supplier catalog for Western buyers     │
│                                                                     │
│  QUESTION 2 — Logistics Reality Check:                             │
│  "A UK customer is ordering Japanese-sourced products.             │
│   Given shipping costs from Asia to UK what local                  │
│   alternatives or bundling strategies would maintain               │
│   margin while keeping the customer engaged?"                      │
│                                                                     │
│  Claude will reason:                                                │
│  • European distributors carrying same Asian brands               │
│  • Bundle Asian products to justify shipping cost                  │
│  • Minimum order threshold for free shipping                       │
│  • Local substitute products with similar profile                  │
│                                                                     │
│  QUESTION 3 — Opportunity Sizing:                                  │
│  "Which Western European customers show the strongest              │
│   affinity for Asian-sourced products and what is                  │
│   their combined revenue potential if we doubled                   │
│   our Asian product catalog?"                                      │
│                                                                     │
│  Claude will reason:                                                │
│  • Identify highest-spend Western buyers of Asian goods            │
│  • Project revenue based on current spend patterns                 │
│  • Recommend catalog expansion priority by country                 │
│                                                                     │
│  QUESTION 4 — Practical Alternative:                               │
│  "For UK customers buying Japanese products what                   │
│   European-sourced alternatives exist in our catalog               │
│   that match the same product category?"                           │
│                                                                     │
│  Claude will reason:                                                │
│  • Map Japanese products to European equivalents                   │
│  • Suggest cross-sell opportunities                                │
│  • Reduce shipping cost while retaining customer                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘      
      </pre>
    </div>    
    <a href="#top" style="color: #39ff14; text-decoration: none; font-size: 14px;">↑ Return to Top</a>
  </div>
  
</div>
