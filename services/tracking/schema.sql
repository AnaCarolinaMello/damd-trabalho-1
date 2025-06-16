CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE driver_locations (
  id SERIAL PRIMARY KEY,
  driver_id INTEGER NOT NULL,
  order_id INTEGER,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  location GEOMETRY(POINT, 4326),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  speed DECIMAL(5, 2) DEFAULT 0.0,
  heading DECIMAL(5, 2) DEFAULT 0.0,
  accuracy DECIMAL(8, 2) DEFAULT 0.0
);

CREATE TABLE delivery_tracking (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL,
  driver_id INTEGER NOT NULL,
  status TEXT CHECK( status IN ('pending','preparing','accepted','delivered','cancelled') ) NOT NULL DEFAULT 'assigned',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location GEOMETRY(POINT, 4326),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT
);

CREATE OR REPLACE FUNCTION update_location_geometry()
RETURNS TRIGGER AS $$
BEGIN
  NEW.location = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER driver_locations_location_trigger
  BEFORE INSERT OR UPDATE ON driver_locations
  FOR EACH ROW EXECUTE FUNCTION update_location_geometry();

CREATE TRIGGER delivery_tracking_location_trigger
  BEFORE INSERT OR UPDATE ON delivery_tracking
  FOR EACH ROW EXECUTE FUNCTION update_location_geometry();

-- Indexes for performance
CREATE INDEX idx_driver_locations_driver ON driver_locations (driver_id);
CREATE INDEX idx_driver_locations_order ON driver_locations (order_id);
CREATE INDEX idx_driver_locations_timestamp ON driver_locations (timestamp);
CREATE INDEX idx_driver_locations_geom ON driver_locations USING GIST (location);

CREATE INDEX idx_delivery_tracking_order ON delivery_tracking (order_id);
CREATE INDEX idx_delivery_tracking_driver ON delivery_tracking (driver_id);
CREATE INDEX idx_delivery_tracking_status ON delivery_tracking (status);
CREATE INDEX idx_delivery_tracking_timestamp ON delivery_tracking (timestamp);
CREATE INDEX idx_delivery_tracking_geom ON delivery_tracking USING GIST (location);
