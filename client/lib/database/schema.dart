class DatabaseSchema {
  static const String schema = '''
-- Drop tables if they exist to avoid conflicts
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS users;

-- Create users table
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT CHECK( type IN ('driver','customer') )   NOT NULL DEFAULT 'customer',
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create addresses table
CREATE TABLE addresses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  street TEXT NOT NULL,
  number TEXT NOT NULL,
  complement TEXT,
  neighborhood TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip_code TEXT NOT NULL,
  is_default INTEGER DEFAULT 0
);

-- Create orders table
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  driver_id INTEGER,
  name TEXT NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  time TEXT NOT NULL,
  status TEXT CHECK( status IN ('pending','preparing','accepted','delivered','cancelled') )   NOT NULL DEFAULT 'pending',
  image BLOB,
  rating REAL DEFAULT 0.0,
  is_rated INTEGER DEFAULT 0,
  delivery_fee REAL DEFAULT 0.0,
  discount REAL DEFAULT 0.0,
  address_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES users (id),
  FOREIGN KEY (driver_id) REFERENCES users (id),
  FOREIGN KEY (address_id) REFERENCES addresses (id)
);

-- Create order_items table
CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_orders_customer ON orders (customer_id);
CREATE INDEX idx_orders_driver ON orders (driver_id);
CREATE INDEX idx_orders_status ON orders (status);
CREATE INDEX idx_order_items_order ON order_items (order_id);
''';
}
