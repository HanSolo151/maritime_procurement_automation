# Maritime Procurement AI Platform

> AI-powered procurement orchestration system for marine technical requisitions — built for RassOil's Dubai operations.

[![n8n](https://img.shields.io/badge/Orchestration-n8n-orange)](https://n8n.io)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-blue)](https://postgresql.org)
[![OpenRouter](https://img.shields.io/badge/AI-OpenRouter%20LLM-purple)](https://openrouter.ai)
[![Twilio](https://img.shields.io/badge/WhatsApp-Twilio-green)](https://twilio.com)
[![Brevo](https://img.shields.io/badge/Email-Brevo%20SMTP-teal)](https://brevo.com)

---

## Overview

This platform automates the end-to-end procurement intelligence cycle for vessel spare parts — from raw requisition document ingestion through AI-powered parameter extraction, dynamic supplier sourcing, benchmark price analysis, and automated high-price escalation via email and WhatsApp.

It is designed as a **modular procurement intelligence platform**, not a standalone script — built to scale, extend, and integrate with existing maritime operations infrastructure.

---

## Architecture

```
┌─────────────────────────────────────────────┐
│         LAYER 1 — Document Ingestion         │
│         PDF / Image Requisition (RFQ)        │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│         LAYER 2 — AI Extraction Engine       │
│   n8n Orchestration → OpenRouter LLM         │
│   → Structured JSON → Validation Layer       │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│    LAYER 3 — Procurement Intelligence DB     │
│    PostgreSQL: requisitions · suppliers      │
│                quotations                    │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│      LAYER 4 — Dynamic Sourcing Engine       │
│  Supplier Matching (material + standard)     │
│  → Benchmark Pricing Engine (deviation %)    │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│     LAYER 5 — Procurement Intelligence       │
│   Supplier Ranking · Deviation Flagging      │
│   Best-Value Selection                       │
└──────────┬──────────────────────┬───────────┘
           │  deviation > 15%     │
┌──────────▼──────────┐  ┌───────▼──────────┐
│   Email Alert        │  │  WhatsApp Alert   │
│   Brevo SMTP         │  │  Twilio Sandbox   │
│   HTML Report        │  │  Push Message     │
└─────────────────────┘  └──────────────────┘
```

---

## Features

- **AI document extraction** — LLM extracts `product_name`, `standard`, `size`, `pcd`, `holes`, `material`, `pressure_rating` from raw requisition text
- **Supplier matching engine** — filters by material grade and flange standard, ranks by price
- **Benchmark pricing engine** — calculates market average and deviation % per supplier
- **Automated escalation protocol** — triggers email + WhatsApp when any quote exceeds benchmark by >15%
- **15 pre-seeded suppliers** across Kandla (India) and Dubai with full contact details
- **Fully automated** — zero manual intervention from document upload to alert delivery

---

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Orchestration | n8n | Workflow automation engine |
| AI Extraction | OpenRouter (LLM) | Structured JSON from raw text |
| Database | PostgreSQL | Centralised intelligence layer |
| Email | Brevo SMTP | HTML alert emails |
| WhatsApp | Twilio | Push notification alerts |
| Language | JavaScript | n8n Code nodes |

---

## Database Schema

```sql
-- Stores every processed requisition
CREATE TABLE requisitions (
    id SERIAL PRIMARY KEY,
    filename TEXT,
    product_name TEXT,
    standard TEXT,
    size TEXT,
    pcd TEXT,
    holes INTEGER,
    material TEXT,
    pressure TEXT,
    supplier_matches JSONB,
    benchmark_price NUMERIC,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Supplier network (Kandla + Dubai)
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    supplier_name TEXT,
    location TEXT,
    supported_materials TEXT[],
    supported_standards TEXT[],
    avg_price NUMERIC,
    whatsapp TEXT,
    email TEXT
);

-- Quotation tracking with deviation
CREATE TABLE quotations (
    id SERIAL PRIMARY KEY,
    requisition_id INTEGER REFERENCES requisitions(id),
    supplier_name TEXT,
    quoted_price NUMERIC,
    benchmark_price NUMERIC,
    deviation_percent NUMERIC,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

## Workflows

### Workflow 1 — RFQ Extraction Pipeline
```
Manual Trigger
    → Edit Fields (mock RFQ input)
    → HTTP Request (OpenRouter LLM)
    → Code (JSON parser + validator)
    → Postgres (INSERT into requisitions)
```

### Workflow 2 — Supplier Matching & Alert Pipeline
```
Manual Trigger
    → Postgres (fetch latest requisition)
    → Postgres (match suppliers by material + standard)
    → Code (benchmark engine + deviation scoring)
    → IF (deviation > 15%)
        → TRUE: Send Email (Brevo) + WhatsApp (Twilio)
        → FALSE: log and exit
```

---

## Setup

### Prerequisites
- Node.js 18+
- PostgreSQL 16
- n8n (`npm install -g n8n`)
- OpenRouter API key (free at openrouter.ai)
- Brevo account (free SMTP)
- Twilio account (free trial)

### 1. Start n8n
```powershell
$env:PGSSLMODE="disable"
n8n start
```
Open `http://localhost:5678`

### 2. Create database
```sql
CREATE DATABASE maritime_procurement;
\c maritime_procurement
-- Run database/schema.sql
-- Run database/seed_suppliers.sql
```

### 3. Import workflows
In n8n: Settings → Import workflow → select files from `workflows/`

### 4. Configure credentials
- **OpenRouter**: HTTP Request node → Header Auth → `Bearer YOUR_KEY`
- **Postgres**: Host `127.0.0.1`, Port `5432`, DB `maritime_procurement`
- **Brevo SMTP**: Host `smtp-relay.brevo.com`, Port `587`
- **Twilio**: Account SID + Auth Token via Basic Auth

---

## Sample Output

### AI Extraction
```json
{
  "product_name": "Cargo Hose",
  "standard": "JIS 10K",
  "size": "150A",
  "pcd": "280mm",
  "holes": 8,
  "material": "SS316",
  "pressure_rating": "10 Bar"
}
```

### Supplier Matching Result
```json
{
  "benchmark_price": 662,
  "best_supplier": "Gujarat Marine Supplies",
  "best_price": 590,
  "best_deviation": -10.88,
  "alert_required": true,
  "all_suppliers": [
    { "supplier_name": "Gujarat Marine Supplies", "location": "Kandla", "avg_price": 590, "flag": "✅ OK" },
    { "supplier_name": "Marineserv Kandla",        "location": "Kandla", "avg_price": 600, "flag": "✅ OK" },
    { "supplier_name": "Kandla Marine Traders",    "location": "Kandla", "avg_price": 620, "flag": "✅ OK" },
    { "supplier_name": "Sealink Marine India",     "location": "Kandla", "avg_price": 650, "flag": "✅ OK" },
    { "supplier_name": "Gulf Marine Supplies",     "location": "Dubai",  "avg_price": 850, "flag": "⚠️ HIGH" }
  ]
}
```

---

## Repository Structure

```
maritime-procurement-ai/
├── README.md
├── workflows/
│   ├── rfq_extraction_pipeline.json
│   └── supplier_matching_alert.json
├── database/
│   ├── schema.sql
│   └── seed_suppliers.sql
├── samples/
│   ├── sample-rfq.pdf
│   └── sample-output.json
└── docs/
    └── screenshots/
```

---

## Future Roadmap

| Phase | Enhancement |
|-------|------------|
| 2 | ERP integration (SAP / Oracle) |
| 2 | Supplier performance scoring + lead time tracking |
| 3 | Predictive pricing bands using historical quotation data |
| 3 | Multilingual RFQ handling (Arabic + English) |
| 4 | Automated invoice reconciliation |
| 4 | AI-based demand forecasting + reorder alerts |

---

## Author

**Aryan Sirsavkar** — AI Automation Engineer  
📧 aryansirsavkarc700@gmail.com · 📍 Pune, India  
Built for the RassOil 48-hour technical challenge · May 2026
