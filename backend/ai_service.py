"""
ai_service.py — Claude Anthropic integration with RAG-style semantic cache.

RAG EXPLANATION FOR JUNIOR DEVELOPERS:
---------------------------------------
RAG = Retrieval-Augmented Generation.
Instead of asking Claude everything from scratch every time (expensive),
we first RETRIEVE similar past answers from our ai_insights table.
If a match is found (same question hash), we return the cached answer.
Only if NO match exists do we GENERATE a new answer via Claude API.
This is the "augmented" part — we augment Claude's knowledge with our
own database context (SQL query results) before asking the question.

COST STRATEGY:
- SQL aggregates (SUM, MAX, AVG, MIN) handle all deterministic math
- Claude only handles pattern recognition, recommendations, narrative
- question_hash deduplication prevents repeat API calls
- sql_context is trimmed/deduped before sending to Claude
"""

import os
import hashlib
import json
import logging
from datetime import datetime, timedelta
from typing import Optional
import anthropic
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import AiInsight

# Claude client — initialized once at module level (not per request)
#claude_client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
# AnthropicVertex authenticates via GOOGLE_APPLICATION_CREDENTIALS env var
# which points to your service account JSON — no api_key string needed
claude_client = anthropic.AnthropicVertex(
    project_id=os.getenv("GCP_PROJECT",  "subaiproj"),
    region=os.getenv("GCP_REGION", "global")
)

# Cache TTL — insights expire after 24 hours to stay fresh
INSIGHT_CACHE_TTL_HOURS = 24

# Max rows sent to Claude to control token cost
MAX_ROWS_TO_CLAUDE = 50

# Claude model — use cheapest model that handles analytical narrative well
#CLAUDE_MODEL = "claude-3-haiku-20240307"
CLAUDE_MODEL = os.getenv("CLAUDE_MODEL", "claude-haiku-4-5@20251001")

# Max tokens for Claude response — keep concise for dashboard display
CLAUDE_MAX_TOKENS = 512

# System prompt — engineered for sales/marketing insight generation
# Strict instructions prevent Claude from hallucinating or going off-topic
SYSTEM_PROMPT = """You are a concise sales and marketing analyst AI assistant.
You receive structured sales data from a database and answer business questions.

STRICT RULES:
1. Answer ONLY based on the data provided. Never invent figures.
2. Be concise — maximum 3-4 sentences or bullet points.
3. Always cite specific product names, customer names, or numbers from the data.
4. For recommendations, suggest products from the same category or supplier.
5. Flag loyalty opportunities: if customer spent >$200 in <6 months, suggest reward.
6. Never perform math yourself — all aggregates are pre-computed by SQL.
7. Output plain text only — no markdown, no headers, no JSON.
"""

def normalize_question(question: str) -> str:
    """
    Normalize question text before hashing to maximize cache hits.
    Lowercases, strips punctuation and extra whitespace.
    Example: 'Which customer spent the MOST??' -> 'which customer spent the most'
    """
    import re
    question = question.lower().strip()
    question = re.sub(r'[^\w\s]', '', question)
    question = re.sub(r'\s+', ' ', question)
    return question


def hash_question(question: str) -> str:
    """
    SHA256 hash of normalized question for exact cache lookup.
    Reusable across all insight types.
    """
    normalized = normalize_question(question)
    return hashlib.sha256(normalized.encode()).hexdigest()


def get_cached_insight(db: Session, question_hash: str) -> Optional[AiInsight]:
    """
    Retrieve cached insight if it exists and has not expired.
    Returns None if no valid cache entry found.
    This is the RETRIEVAL step of RAG — check cache before hitting Claude API.
    """
    now = datetime.utcnow()
    return (
        db.query(AiInsight)
        .filter(
            AiInsight.question_hash == question_hash,
            # Either never expires (NULL) or expiry is in the future
            (AiInsight.expires_at == None) | (AiInsight.expires_at > now)
        )
        .order_by(AiInsight.created_at.desc())
        .first()
    )


def save_insight(
    db: Session,
    question_hash: str,
    question_text: str,
    insight_type: str,
    insight_text: str,
    sql_context: str,
    tokens_used: int
) -> AiInsight:
    """
    Persist Claude's response to ai_insights table for future cache hits.
    Sets expiry to INSIGHT_CACHE_TTL_HOURS from now.
    """
    expires_at = datetime.utcnow() + timedelta(hours=INSIGHT_CACHE_TTL_HOURS)
    insight = AiInsight(
        question_hash=question_hash,
        question_text=question_text,
        insight_type=insight_type,
        insight_text=insight_text,
        sql_context=sql_context,
        tokens_used=tokens_used,
        expires_at=expires_at
    )
    db.add(insight)
    db.commit()
    db.refresh(insight)
    return insight


def dedupe_rows(rows: list[dict]) -> list[dict]:
    """
    Deduplicate rows before sending to Claude to avoid redundant token usage.
    Uses JSON serialization for hashable comparison across mixed types.
    COST SAVER: fewer unique rows = fewer tokens = lower API cost.
    """
    seen = set()
    deduped = []
    for row in rows:
        row_key = json.dumps(row, sort_keys=True, default=str)
        if row_key not in seen:
            seen.add(row_key)
            deduped.append(row)
    return deduped[:MAX_ROWS_TO_CLAUDE]


def fetch_sql_context(db: Session, insight_type: str) -> tuple[list[dict], str]:
    """
    Fetch pre-aggregated SQL data relevant to the insight_type requested.
    SQL does ALL math — Claude only interprets patterns and narratives.

    WHY SQL NOT CLAUDE FOR AGGREGATES:
    - SQL SUM/MAX/AVG is deterministic, fast, free, and 100% accurate
    - Claude is probabilistic, slow, costly, and can hallucinate numbers
    - Only send Claude the pre-computed results, not raw transaction rows

    Returns: (list of row dicts, insight_type label string)
    """
    queries = {
        # Top customers by total spend — SQL does the SUM
        "top_customer": """
            SELECT
                c.customer_id,
                c.company_name,
                c.country,
                COUNT(DISTINCT o.order_id)                              AS total_orders,
                ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)), 2) AS total_spent,
                MIN(o.order_date)                                        AS first_order,
                MAX(o.order_date)                                        AS last_order
            FROM customers c
            JOIN orders o       ON c.customer_id = o.customer_id
            JOIN order_details od ON o.order_id  = od.order_id
            GROUP BY c.customer_id, c.company_name, c.country
            ORDER BY total_spent DESC
            LIMIT 20
        """,

        # Asian product ordering patterns — SQL filters, Claude interprets
        "product_pattern": """
            SELECT
                c.company_name,
                c.country,
                p.product_name,
                cat.category_name,
                s.company_name                                           AS supplier_country,
                SUM(od.quantity)                                         AS total_qty_ordered,
                ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)), 2) AS total_spent,
                COUNT(DISTINCT o.order_id)                               AS order_count
            FROM order_details od
            JOIN orders o       ON od.order_id   = o.order_id
            JOIN customers c    ON o.customer_id = c.customer_id
            JOIN products p     ON od.product_id = p.product_id
            JOIN categories cat ON p.category_id = cat.category_id
            JOIN suppliers s    ON p.supplier_id = s.supplier_id
            WHERE s.country IN ('Japan','Singapore','China','Thailand','Philippines')
               OR cat.category_name IN ('Seafood','Produce')
            GROUP BY c.company_name, c.country, p.product_name,
                     cat.category_name, s.company_name
            ORDER BY total_qty_ordered DESC
            LIMIT 30
        """,

        # Shipper performance — SQL counts, Claude narrates
        "shipper_performance": """
            SELECT
                sh.company_name                                          AS shipper_name,
                COUNT(o.order_id)                                        AS total_orders_shipped,
                ROUND(AVG(od.unit_price * od.quantity), 2)               AS avg_order_value,
                ROUND(SUM(o.freight), 2)                                 AS total_freight_collected,
                COUNT(DISTINCT o.customer_id)                            AS unique_customers_served
            FROM shippers sh
            JOIN orders o       ON sh.shipper_id = o.ship_via
            JOIN order_details od ON o.order_id  = od.order_id
            GROUP BY sh.company_name
            ORDER BY total_orders_shipped DESC
        """,

        # Loyalty candidates — customers spending >$200 in <6 months
        "loyalty_opportunity": """
            SELECT
                c.company_name,
                c.country,
                c.phone,
                COUNT(DISTINCT o.order_id)                               AS order_count,
                ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)), 2) AS total_spent,
                DATEDIFF(MAX(o.order_date), MIN(o.order_date))           AS days_active,
                GROUP_CONCAT(DISTINCT p.product_name ORDER BY p.product_name SEPARATOR ', ')
                                                                         AS products_ordered
            FROM customers c
            JOIN orders o       ON c.customer_id = o.customer_id
            JOIN order_details od ON o.order_id  = od.order_id
            JOIN products p     ON od.product_id = p.product_id
            GROUP BY c.company_name, c.country, c.phone
            HAVING total_spent > 200
               AND days_active <= 180
            ORDER BY total_spent DESC
        """,

        # Q3 spending summary — SQL computes quarter, Claude summarizes
        "q3_summary": """
            SELECT
                c.company_name,
                c.country,
                ROUND(SUM(od.unit_price * od.quantity * (1-od.discount)), 2) AS q3_spent,
                COUNT(DISTINCT o.order_id)                               AS q3_orders
            FROM customers c
            JOIN orders o       ON c.customer_id = o.customer_id
            JOIN order_details od ON o.order_id  = od.order_id
            WHERE QUARTER(o.order_date) = 3
            GROUP BY c.company_name, c.country
            ORDER BY q3_spent DESC
            LIMIT 20
        """
    }

    # Default to top_customer if insight_type not recognized
    query = queries.get(insight_type, queries["top_customer"])
    result = db.execute(text(query))
    rows = [dict(row._mapping) for row in result]
    return dedupe_rows(rows), insight_type


def classify_insight_type(question: str) -> str:
    """
    Simple keyword classifier to route question to correct SQL context.
    Avoids sending Claude irrelevant data — cost and accuracy optimization.
    No ML needed — deterministic keyword matching is sufficient here.
    """
    question_lower = question.lower()
    if any(k in question_lower for k in ['q3', 'quarter', 'third quarter']):
        return 'q3_summary'
    if any(k in question_lower for k in ['ship', 'shipper', 'shipping', 'deliver']):
        return 'shipper_performance'
    if any(k in question_lower for k in ['loyalty', 'reward', 'voucher', 'gift', 'subscribe']):
        return 'loyalty_opportunity'
    if any(k in question_lower for k in ['asian', 'hokkien', 'singapore', 'japanese',
                                          'pattern', 'recommend', 'similar', 'product']):
        return 'product_pattern'
    # Default: customer spending questions
    return 'top_customer'


def ask_claude(question: str, db: Session) -> dict:
    """
    Main RAG entry point called by FastAPI route /ai/ask.

    Flow:
    1. Normalize + hash question
    2. Check ai_insights cache (RETRIEVAL) — return if hit
    3. Classify insight type from question keywords
    4. Fetch pre-aggregated SQL context (AUGMENTATION)
    5. Dedupe rows before sending to Claude
    6. Call Claude API with system prompt + data context (GENERATION)
    7. Save response to cache for future reuse
    8. Return insight text + metadata

    JUNIOR DEV NOTE:
    This is RAG in its simplest form:
    R = Retrieve cached answer or SQL data
    A = Augment Claude prompt with real database rows
    G = Generate narrative insight from that augmented context
    """
    question_hash = hash_question(question)

    # Step 1: Check cache — avoid Claude API call if already answered
    cached = get_cached_insight(db, question_hash)
    if cached:
        logging.info(f"Cache HIT for question hash {question_hash[:8]}...")
        return {
            "insight_text": cached.insight_text,
            "insight_type": cached.insight_type,
            "tokens_used":  cached.tokens_used,
            "cached":       True,
            "created_at":   cached.created_at.isoformat()
        }

    logging.info(f"Cache MISS — calling Claude for: {question[:60]}...")

    # Step 2: Classify and fetch relevant SQL context
    insight_type = classify_insight_type(question)
    rows, insight_type = fetch_sql_context(db, insight_type)

    if not rows:
        return {
            "insight_text": "No data available to answer this question.",
            "insight_type": insight_type,
            "tokens_used":  0,
            "cached":       False
        }

    # Step 3: Build user message with SQL context embedded
    sql_context_str = json.dumps(rows, default=str, indent=2)
    user_message = f"""
SALES DATA (pre-aggregated by SQL):
{sql_context_str}

QUESTION: {question}

Answer based strictly on the data above.
"""

    # Step 4: Call Claude — only reaches here on cache miss
    response = claude_client.messages.create(
        model=CLAUDE_MODEL,
        max_tokens=CLAUDE_MAX_TOKENS,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": user_message}]
    )

    insight_text = response.content[0].text.strip()
    tokens_used  = response.usage.input_tokens + response.usage.output_tokens

    # Step 5: Cache the response for future identical/similar questions
    save_insight(
        db=db,
        question_hash=question_hash,
        question_text=question,
        insight_type=insight_type,
        insight_text=insight_text,
        sql_context=sql_context_str[:2000],  # truncate for storage
        tokens_used=tokens_used
    )

    return {
        "insight_text": insight_text,
        "insight_type": insight_type,
        "tokens_used":  tokens_used,
        "cached":       False,
        "created_at":   datetime.utcnow().isoformat()
    }

