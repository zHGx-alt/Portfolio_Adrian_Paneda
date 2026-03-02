BEGIN;

-- (Opcional en dev)
-- DROP TABLE IF EXISTS events, orders, riders, restaurants, order_categories, event_types, weather_levels, traffic_levels, delay_reasons CASCADE;

CREATE TABLE IF NOT EXISTS restaurants (
  restaurant_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  restaurant_name    TEXT NOT NULL,
  cuisine_category   TEXT,
  base_prep_time     NUMERIC(6,2) CHECK (base_prep_time >= 0),
  capacity           INTEGER CHECK (capacity > 0),
  restaurant_lat     DOUBLE PRECISION,
  restaurant_lon     DOUBLE PRECISION,
  restaurant_zone    TEXT
);

CREATE TABLE IF NOT EXISTS riders (
  rider_id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  home_zone          TEXT,
  avg_pickup_time    NUMERIC(6,2) CHECK (avg_pickup_time >= 0),
  avg_delivery_time  NUMERIC(6,2) CHECK (avg_delivery_time >= 0)
);

CREATE TABLE IF NOT EXISTS order_categories (
  category_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_name      TEXT NOT NULL UNIQUE,
  complexity_factor  NUMERIC(6,3) NOT NULL CHECK (complexity_factor > 0)
);

CREATE TABLE IF NOT EXISTS orders (
  order_id                 INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at               TIMESTAMPTZ NOT NULL,
  order_value              NUMERIC(10,2) CHECK (order_value >= 0),
  items_count              INTEGER CHECK (items_count >= 1),
  estimated_prep_time      INTEGER CHECK (estimated_prep_time >= 0),
  estimated_delivery_time  INTEGER CHECK (estimated_delivery_time >= 0),
  customer_lat             DOUBLE PRECISION,
  customer_lon             DOUBLE PRECISION,
  order_status             TEXT NOT NULL
    CHECK (order_status IN ('CREATED','ACCEPTED','PREPARING','READY','PICKED_UP','DELIVERED','CANCELLED')),
  restaurant_id            INTEGER NOT NULL REFERENCES restaurants(restaurant_id),
  category_id              INTEGER NOT NULL REFERENCES order_categories(category_id)
);

CREATE TABLE IF NOT EXISTS event_types (
  event_type_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  event_name         TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS weather_levels (
  weather_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  weather_name       TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS traffic_levels (
  traffic_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  traffic_name       TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS delay_reasons (
  delay_reason_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  delay_reason_name   TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS events (
  event_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ts                TIMESTAMPTZ NOT NULL,
  order_id          INTEGER NOT NULL REFERENCES orders(order_id),
  event_type_id     INTEGER NOT NULL REFERENCES event_types(event_type_id),
  rider_id          INTEGER REFERENCES riders(rider_id),
  weather_id        INTEGER NOT NULL REFERENCES weather_levels(weather_id),
  traffic_id        INTEGER NOT NULL REFERENCES traffic_levels(traffic_id),
  delay_reason_id   INTEGER REFERENCES delay_reasons(delay_reason_id),
  -- evita duplicados exactos en logs (ajústalo si no te encaja)
  UNIQUE (order_id, event_type_id, ts)
);

-- Indexes (IF NOT EXISTS para reproducible)
CREATE INDEX IF NOT EXISTS idx_orders_created_at            ON orders (created_at);
CREATE INDEX IF NOT EXISTS idx_orders_status                ON orders (order_status);
CREATE INDEX IF NOT EXISTS idx_orders_rest_status           ON orders (restaurant_id, order_status);
CREATE INDEX IF NOT EXISTS idx_orders_rest_created          ON orders (restaurant_id, created_at);
CREATE INDEX IF NOT EXISTS idx_orders_cat_created           ON orders (category_id, created_at);

CREATE INDEX IF NOT EXISTS idx_restaurants_zone             ON restaurants (restaurant_zone);
CREATE INDEX IF NOT EXISTS idx_restaurants_cuisine          ON restaurants (cuisine_category);
CREATE INDEX IF NOT EXISTS idx_riders_home_zone             ON riders (home_zone);

CREATE INDEX IF NOT EXISTS idx_events_order_ts              ON events (order_id, ts);
CREATE INDEX IF NOT EXISTS idx_events_rider_ts              ON events (rider_id, ts);
CREATE INDEX IF NOT EXISTS idx_events_type                  ON events (event_type_id);
CREATE INDEX IF NOT EXISTS idx_events_weather               ON events (weather_id);
CREATE INDEX IF NOT EXISTS idx_events_traffic               ON events (traffic_id);
CREATE INDEX IF NOT EXISTS idx_events_delay_reason          ON events (delay_reason_id);

COMMIT;