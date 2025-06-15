CREATE TABLE addresses (
  id SERIAL PRIMARY KEY,
  street TEXT NOT NULL,
  number TEXT NOT NULL,
  complement TEXT,
  neighborhood TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip_code TEXT NOT NULL,
  is_default INTEGER DEFAULT 0
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  driver_id INTEGER,
  name TEXT NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  time TEXT NOT NULL,
  status TEXT CHECK( status IN ('pending','preparing','accepted','delivered','cancelled') ) NOT NULL DEFAULT 'pending',
  image BYTEA,
  rating REAL DEFAULT 0.0,
  is_rated INTEGER DEFAULT 0,
  delivery_fee REAL DEFAULT 0.0,
  discount REAL DEFAULT 0.0,
  address_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (address_id) REFERENCES addresses (id)
);

CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
);

CREATE INDEX idx_orders_customer ON orders (customer_id);
CREATE INDEX idx_orders_driver ON orders (driver_id);
CREATE INDEX idx_orders_status ON orders (status);
CREATE INDEX idx_order_items_order ON order_items (order_id);