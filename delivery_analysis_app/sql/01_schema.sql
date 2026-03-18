BEGIN;

DROP TABLE IF EXISTS order_events, deliveries, orders, riders, restaurants CASCADE;

CREATE TABLE restaurants (
  restaurant_id      INTEGER PRIMARY KEY,
  restaurant_name    TEXT NOT NULL,
  cuisine_category   TEXT NOT NULL,
  base_prep_time     INTEGER NOT NULL CHECK (base_prep_time >= 0),
  capacity           INTEGER NOT NULL CHECK (capacity > 0),
  restaurant_zone    TEXT NOT NULL,
  restaurant_lat     DOUBLE PRECISION NOT NULL,
  restaurant_lon     DOUBLE PRECISION NOT NULL
);

CREATE TABLE riders (
  rider_id              INTEGER PRIMARY KEY,
  rider_name            TEXT NOT NULL,
  home_zone             TEXT NOT NULL,
  vehicle_type          TEXT NOT NULL CHECK (vehicle_type IN ('BIKE', 'MOTORBIKE')),
  max_orders_per_hour   INTEGER NOT NULL CHECK (max_orders_per_hour > 0)
);

CREATE TABLE orders (
  order_id                   INTEGER PRIMARY KEY,
  created_at                 TIMESTAMP NOT NULL,
  order_value                NUMERIC(10,2) NOT NULL CHECK (order_value >= 0),
  items_count                INTEGER NOT NULL CHECK (items_count >= 1),
  estimated_prep_time        INTEGER NOT NULL CHECK (estimated_prep_time >= 0),
  estimated_delivery_time    INTEGER NOT NULL CHECK (estimated_delivery_time >= 0),
  customer_lat               DOUBLE PRECISION NOT NULL,
  customer_lon               DOUBLE PRECISION NOT NULL,
  order_status               TEXT NOT NULL CHECK (
    order_status IN ('CREATED','ACCEPTED','PREPARING','READY','PICKED_UP','DELIVERED','CANCELLED')
  ),
  restaurant_id              INTEGER NOT NULL REFERENCES restaurants(restaurant_id),
  weather_level              TEXT NOT NULL CHECK (
    weather_level IN ('CLEAR','RAIN','WIND')
  ),
  traffic_level              TEXT NOT NULL CHECK (
    traffic_level IN ('LOW','MEDIUM','HIGH')
  )
);

CREATE TABLE deliveries (
  delivery_id         INTEGER PRIMARY KEY,
  order_id            INTEGER NOT NULL UNIQUE REFERENCES orders(order_id),
  rider_id            INTEGER NOT NULL REFERENCES riders(rider_id),
  assigned_at         TIMESTAMP NOT NULL,
  picked_up_at        TIMESTAMP NOT NULL,
  delivered_at        TIMESTAMP NOT NULL,
  hour                INTEGER NOT NULL CHECK (hour BETWEEN 0 AND 23),
  day                 TEXT NOT NULL CHECK (
    day IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')
  ),
  month               INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  prep_minutes        NUMERIC(8,2) NOT NULL CHECK (prep_minutes >= 0),
  delivery_minutes    NUMERIC(8,2) NOT NULL CHECK (delivery_minutes >= 0),
  total_minutes       NUMERIC(8,2) NOT NULL CHECK (total_minutes >= 0),
  CHECK (picked_up_at >= assigned_at),
  CHECK (delivered_at >= picked_up_at)
);

CREATE TABLE order_events (
  event_id            INTEGER PRIMARY KEY,
  order_id            INTEGER NOT NULL REFERENCES orders(order_id),
  event_name          TEXT NOT NULL CHECK (
    event_name IN ('CREATED','ACCEPTED','PREPARING','READY','PICKED_UP','DELIVERED','CANCELLED')
  ),
  event_timestamp     TIMESTAMP NOT NULL,
  UNIQUE (order_id, event_name, event_timestamp)
);

CREATE INDEX idx_restaurants_zone            ON restaurants (restaurant_zone);
CREATE INDEX idx_restaurants_cuisine         ON restaurants (cuisine_category);

CREATE INDEX idx_riders_home_zone            ON riders (home_zone);
CREATE INDEX idx_riders_vehicle_type         ON riders (vehicle_type);

CREATE INDEX idx_orders_created_at           ON orders (created_at);
CREATE INDEX idx_orders_status               ON orders (order_status);
CREATE INDEX idx_orders_restaurant_id        ON orders (restaurant_id);
CREATE INDEX idx_orders_weather_level        ON orders (weather_level);
CREATE INDEX idx_orders_traffic_level        ON orders (traffic_level);

CREATE INDEX idx_deliveries_order_id         ON deliveries (order_id);
CREATE INDEX idx_deliveries_rider_id         ON deliveries (rider_id);
CREATE INDEX idx_deliveries_assigned_at      ON deliveries (assigned_at);
CREATE INDEX idx_deliveries_delivered_at     ON deliveries (delivered_at);
CREATE INDEX idx_deliveries_day_hour         ON deliveries (day, hour);

CREATE INDEX idx_order_events_order_id       ON order_events (order_id);
CREATE INDEX idx_order_events_event_name     ON order_events (event_name);
CREATE INDEX idx_order_events_timestamp      ON order_events (event_timestamp);

COMMIT;