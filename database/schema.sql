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

CREATE TABLE quotations (
    id SERIAL PRIMARY KEY,
    requisition_id INTEGER REFERENCES requisitions(id),
    supplier_name TEXT,
    quoted_price NUMERIC,
    benchmark_price NUMERIC,
    deviation_percent NUMERIC,
    created_at TIMESTAMP DEFAULT NOW()
);