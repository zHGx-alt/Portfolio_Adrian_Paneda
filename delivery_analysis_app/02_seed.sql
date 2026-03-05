BEGIN;

-- =========================
-- 0) DEV reset (reproducible)
-- =========================
TRUNCATE TABLE
  events,
  orders,
  riders,
  restaurants,
  order_categories,
  event_types,
  weather_levels,
  traffic_levels,
  delay_reasons
RESTART IDENTITY CASCADE;

-- =========================
-- 1) Catalogs
-- =========================
INSERT INTO event_types (event_name) VALUES
  ('CREATED'),
  ('ACCEPTED'),
  ('PREPARING'),
  ('READY'),
  ('PICKED_UP'),
  ('DELIVERED'),
  ('CANCELLED')
ON CONFLICT (event_name) DO NOTHING;

INSERT INTO weather_levels (weather_name) VALUES
  ('CLEAR'),
  ('RAIN'),
  ('WIND'),
  ('STORM'),
  ('HEAT')
ON CONFLICT (weather_name) DO NOTHING;

INSERT INTO traffic_levels (traffic_name) VALUES
  ('LOW'),
  ('MEDIUM'),
  ('HIGH')
ON CONFLICT (traffic_name) DO NOTHING;

INSERT INTO delay_reasons (delay_reason_name) VALUES
  ('RESTAURANT_BUSY'),
  ('KITCHEN_DELAY'),
  ('RIDER_DELAY'),
  ('TRAFFIC'),
  ('WEATHER'),
  ('ADDRESS_ISSUE')
ON CONFLICT (delay_reason_name) DO NOTHING;

-- =========================
-- 2) Master data
-- =========================
INSERT INTO restaurants
  (restaurant_name, cuisine_category, base_prep_time, capacity, restaurant_lat, restaurant_lon, restaurant_zone)
VALUES
  ('Napoli Pizza Lab', 'ITALIAN',  15, 20, 43.2630, -2.9350, 'BILBAO_CENTRO'),
  ('Sakura Sushi',     'JAPANESE', 20, 15, 43.2710, -2.9520, 'DEUSTO'),
  ('Burger Station',   'AMERICAN', 12, 18, 43.2580, -2.9260, 'SANTUTXU'),
  ('Bombay Corner',    'INDIAN',   18, 16, 43.2620, -2.9490, 'INDAUTXU'),
  ('Green Bowl',       'HEALTHY',  10, 14, 43.2610, -2.9310, 'BILBAO_CENTRO');

INSERT INTO riders (home_zone, avg_pickup_time, avg_delivery_time) VALUES
  ('BILBAO_CENTRO', 6.50, 14.00),
  ('DEUSTO',        7.20, 13.50),
  ('SANTUTXU',      8.00, 15.20),
  ('INDAUTXU',      6.80, 12.80);

-- OJO: complexity_factor es NOT NULL en tu schema
INSERT INTO order_categories (category_name, complexity_factor) VALUES
  ('PIZZA',     1.150),
  ('SUSHI',     1.350),
  ('FAST_FOOD', 1.050),
  ('INDIAN',    1.200),
  ('HEALTHY',   1.000)
ON CONFLICT (category_name) DO NOTHING;

-- =========================
-- 3) Orders + events
-- =========================
WITH
et AS (SELECT event_name, event_type_id::int AS event_type_id FROM event_types),
wx AS (SELECT weather_name, weather_id::int AS weather_id FROM weather_levels),
tr AS (SELECT traffic_name, traffic_id::int AS traffic_id FROM traffic_levels),
dr AS (SELECT delay_reason_name, delay_reason_id::int AS delay_reason_id FROM delay_reasons),
rest AS (
  SELECT restaurant_id, restaurant_name
  FROM restaurants
  WHERE restaurant_name IN ('Napoli Pizza Lab','Sakura Sushi','Burger Station','Bombay Corner','Green Bowl')
),
cat AS (
  SELECT category_id, category_name
  FROM order_categories
  WHERE category_name IN ('PIZZA','SUSHI','FAST_FOOD','INDIAN','HEALTHY')
),
rid AS (SELECT rider_id::int AS rider_id FROM riders ORDER BY rider_id),

-- ========== Orders ==========
o1 AS (
  INSERT INTO orders (
    created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
    customer_lat, customer_lon, order_status, restaurant_id, category_id
  )
  SELECT
    now() - interval '55 minutes',
    18.90, 2, 15, 30,
    43.2652, -2.9341,
    'DELIVERED',
    r.restaurant_id,
    c.category_id
  FROM rest r
  JOIN cat c ON c.category_name = 'PIZZA'
  WHERE r.restaurant_name = 'Napoli Pizza Lab'
  RETURNING order_id, created_at
),
o2 AS (
  INSERT INTO orders (
    created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
    customer_lat, customer_lon, order_status, restaurant_id, category_id
  )
  SELECT
    now() - interval '40 minutes',
    24.50, 3, 20, 35,
    43.2718, -2.9510,
    'CANCELLED',
    r.restaurant_id,
    c.category_id
  FROM rest r
  JOIN cat c ON c.category_name = 'SUSHI'
  WHERE r.restaurant_name = 'Sakura Sushi'
  RETURNING order_id, created_at
),
o3 AS (
  INSERT INTO orders (
    created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
    customer_lat, customer_lon, order_status, restaurant_id, category_id
  )
  SELECT
    now() - interval '25 minutes',
    13.20, 1, 12, 25,
    43.2585, -2.9258,
    'READY',
    r.restaurant_id,
    c.category_id
  FROM rest r
  JOIN cat c ON c.category_name = 'FAST_FOOD'
  WHERE r.restaurant_name = 'Burger Station'
  RETURNING order_id, created_at
),
o4 AS (
  INSERT INTO orders (
    created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
    customer_lat, customer_lon, order_status, restaurant_id, category_id
  )
  SELECT
    now() - interval '30 minutes',
    29.70, 4, 18, 40,
    43.2628, -2.9488,
    'PICKED_UP',
    r.restaurant_id,
    c.category_id
  FROM rest r
  JOIN cat c ON c.category_name = 'INDIAN'
  WHERE r.restaurant_name = 'Bombay Corner'
  RETURNING order_id, created_at
),
o5 AS (
  INSERT INTO orders (
    created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
    customer_lat, customer_lon, order_status, restaurant_id, category_id
  )
  SELECT
    now() - interval '7 minutes',
    11.50, 2, 10, 20,
    43.2609, -2.9314,
    'CREATED',
    r.restaurant_id,
    c.category_id
  FROM rest r
  JOIN cat c ON c.category_name = 'HEALTHY'
  WHERE r.restaurant_name = 'Green Bowl'
  RETURNING order_id, created_at
),

-- Riders deterministas para cada pedido (1..4..)
r1 AS (SELECT (SELECT rider_id FROM rid OFFSET 0 LIMIT 1) AS rider_id),
r2 AS (SELECT (SELECT rider_id FROM rid OFFSET 1 LIMIT 1) AS rider_id),
r3 AS (SELECT (SELECT rider_id FROM rid OFFSET 2 LIMIT 1) AS rider_id),
r4 AS (SELECT (SELECT rider_id FROM rid OFFSET 3 LIMIT 1) AS rider_id)

-- ========== Events ==========
INSERT INTO events (ts, order_id, event_type_id, rider_id, weather_id, traffic_id, delay_reason_id)

-- o1 DELIVERED: 6 eventos
SELECT o1.created_at + interval '0 min',  o1.order_id, (SELECT event_type_id FROM et WHERE event_name='CREATED'),
       NULL::int, (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'), NULL::int
FROM o1
UNION ALL
SELECT o1.created_at + interval '2 min',  o1.order_id, (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
       (SELECT rider_id FROM r1), (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'), NULL::int
FROM o1
UNION ALL
SELECT o1.created_at + interval '6 min',  o1.order_id, (SELECT event_type_id FROM et WHERE event_name='PREPARING'),
       (SELECT rider_id FROM r1), (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
       (SELECT delay_reason_id FROM dr WHERE delay_reason_name='KITCHEN_DELAY')
FROM o1
UNION ALL
SELECT o1.created_at + interval '14 min', o1.order_id, (SELECT event_type_id FROM et WHERE event_name='READY'),
       (SELECT rider_id FROM r1), (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'), NULL::int
FROM o1
UNION ALL
SELECT o1.created_at + interval '18 min', o1.order_id, (SELECT event_type_id FROM et WHERE event_name='PICKED_UP'),
       (SELECT rider_id FROM r1), (SELECT weather_id FROM wx WHERE weather_name='RAIN'), (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
       (SELECT delay_reason_id FROM dr WHERE delay_reason_name='TRAFFIC')
FROM o1
UNION ALL
SELECT o1.created_at + interval '30 min', o1.order_id, (SELECT event_type_id FROM et WHERE event_name='DELIVERED'),
       (SELECT rider_id FROM r1), (SELECT weather_id FROM wx WHERE weather_name='RAIN'), (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'), NULL::int
FROM o1

-- o2 CANCELLED: 3 eventos
UNION ALL
SELECT o2.created_at + interval '0 min',  o2.order_id, (SELECT event_type_id FROM et WHERE event_name='CREATED'),
       NULL::int, (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='LOW'), NULL::int
FROM o2
UNION ALL
SELECT o2.created_at + interval '2 min',  o2.order_id, (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
       (SELECT rider_id FROM r2), (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'), NULL::int
FROM o2
UNION ALL
SELECT o2.created_at + interval '10 min', o2.order_id, (SELECT event_type_id FROM et WHERE event_name='CANCELLED'),
       NULL::int, (SELECT weather_id FROM wx WHERE weather_name='RAIN'), (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
       (SELECT delay_reason_id FROM dr WHERE delay_reason_name='RESTAURANT_BUSY')
FROM o2

-- o3 READY: 4 eventos
UNION ALL
SELECT o3.created_at + interval '0 min',  o3.order_id, (SELECT event_type_id FROM et WHERE event_name='CREATED'),
       NULL::int, (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='LOW'), NULL::int
FROM o3
UNION ALL
SELECT o3.created_at + interval '2 min',  o3.order_id, (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
       (SELECT rider_id FROM r3), (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'), NULL::int
FROM o3
UNION ALL
SELECT o3.created_at + interval '6 min',  o3.order_id, (SELECT event_type_id FROM et WHERE event_name='PREPARING'),
       (SELECT rider_id FROM r3), (SELECT weather_id FROM wx WHERE weather_name='HEAT'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'), NULL::int
FROM o3
UNION ALL
SELECT o3.created_at + interval '14 min', o3.order_id, (SELECT event_type_id FROM et WHERE event_name='READY'),
       (SELECT rider_id FROM r3), (SELECT weather_id FROM wx WHERE weather_name='HEAT'), (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
       (SELECT delay_reason_id FROM dr WHERE delay_reason_name='RESTAURANT_BUSY')
FROM o3

-- o4 PICKED_UP: 5 eventos
UNION ALL
SELECT o4.created_at + interval '0 min',  o4.order_id, (SELECT event_type_id FROM et WHERE event_name='CREATED'),
       NULL::int, (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='LOW'), NULL::int
FROM o4
UNION ALL
SELECT o4.created_at + interval '2 min',  o4.order_id, (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
       (SELECT rider_id FROM r4), (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'), NULL::int
FROM o4
UNION ALL
SELECT o4.created_at + interval '6 min',  o4.order_id, (SELECT event_type_id FROM et WHERE event_name='PREPARING'),
       (SELECT rider_id FROM r4), (SELECT weather_id FROM wx WHERE weather_name='RAIN'), (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
       (SELECT delay_reason_id FROM dr WHERE delay_reason_name='KITCHEN_DELAY')
FROM o4
UNION ALL
SELECT o4.created_at + interval '14 min', o4.order_id, (SELECT event_type_id FROM et WHERE event_name='READY'),
       (SELECT rider_id FROM r4), (SELECT weather_id FROM wx WHERE weather_name='RAIN'), (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'), NULL::int
FROM o4
UNION ALL
SELECT o4.created_at + interval '18 min', o4.order_id, (SELECT event_type_id FROM et WHERE event_name='PICKED_UP'),
       (SELECT rider_id FROM r4), (SELECT weather_id FROM wx WHERE weather_name='RAIN'), (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
       (SELECT delay_reason_id FROM dr WHERE delay_reason_name='TRAFFIC')
FROM o4

-- o5 CREATED: 1 evento
UNION ALL
SELECT o5.created_at + interval '0 min',  o5.order_id, (SELECT event_type_id FROM et WHERE event_name='CREATED'),
       NULL::int, (SELECT weather_id FROM wx WHERE weather_name='CLEAR'), (SELECT traffic_id FROM tr WHERE traffic_name='LOW'), NULL::int
FROM o5
;

COMMIT;