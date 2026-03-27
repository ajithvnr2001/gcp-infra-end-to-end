-- local-dev/init-db.sql
-- Creates databases and tables for local development
-- Runs automatically when postgres container starts

CREATE DATABASE catalog;
CREATE DATABASE orders;

\c catalog;
CREATE TABLE IF NOT EXISTS products (
    id          VARCHAR(50) PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    price       DECIMAL(10,2) NOT NULL,
    category    VARCHAR(100),
    stock       INTEGER DEFAULT 0,
    rating      DECIMAL(3,2),
    created_at  TIMESTAMP DEFAULT NOW(),
    updated_at  TIMESTAMP DEFAULT NOW()
);

INSERT INTO products (id, name, price, category, stock, rating) VALUES
  ('p1', 'Wireless Headphones', 1999.00, 'electronics', 150, 4.5),
  ('p2', 'Running Shoes',       2499.00, 'footwear',    80,  4.3),
  ('p3', 'Cotton T-Shirt',       499.00, 'clothing',    500, 4.1),
  ('p4', 'Smartphone Case',      299.00, 'accessories', 200, 4.6),
  ('p5', 'Yoga Mat',             799.00, 'sports',      60,  4.4)
ON CONFLICT (id) DO NOTHING;

\c orders;
CREATE TABLE IF NOT EXISTS orders (
    order_id       VARCHAR(50) PRIMARY KEY,
    user_id        VARCHAR(100) NOT NULL,
    status         VARCHAR(50) DEFAULT 'pending',
    total          DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'pending',
    address        TEXT,
    created_at     TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id          SERIAL PRIMARY KEY,
    order_id    VARCHAR(50) REFERENCES orders(order_id),
    product_id  VARCHAR(50) NOT NULL,
    product_name VARCHAR(200),
    price       DECIMAL(10,2) NOT NULL,
    quantity    INTEGER NOT NULL
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
