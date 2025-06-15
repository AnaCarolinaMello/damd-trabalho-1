CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  type TEXT CHECK( type IN ('driver','customer') ) NOT NULL DEFAULT 'customer',
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users (email);