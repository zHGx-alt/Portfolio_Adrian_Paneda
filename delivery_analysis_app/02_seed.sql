BEGIN;

-- =========================
-- 1) CATALOGS / DIMENSIONS
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

INSERT INTO order_categories (category_name, complexity_factor) VALUES
  ('FAST_FOOD', 1.00),
  ('PIZZA', 1.10),
  ('SUSHI', 1.40),
  ('INDIAN', 1.25),
  ('HEALTHY', 1.15),
  ('GROCERIES', 1.05)
ON CONFLICT (category_name) DO NOTHING;

-- =========================
-- 2) ENTITIES
-- =========================

INSERT INTO restaurants
  (restaurant_name, cuisine_category, base_prep_time, capacity, restaurant_lat, restaurant_lon, restaurant_zone)
VALUES
  ('Burger Station',     'FAST_FOOD', 12.0, 25, 43.2630, -2.9350, 'BILBAO_CENTRO'),
  ('Napoli Pizza Lab',   'PIZZA',     15.0, 18, 43.2695, -2.9402, 'BILBAO_CENTRO'),
  ('Sakura Sushi',       'SUSHI',     20.0, 12, 43.2578, -2.9231, 'DEUSTO'),
  ('Bombay Corner',      'INDIAN',    18.0, 14, 43.2711, -2.9523, 'SANTUTXU'),
  ('Green Bowl',         'HEALTHY',   14.0, 16, 43.2622, -2.9474, 'INDAUTXU'),
  ('Market Express',     'GROCERIES', 10.0, 30, 43.2605, -2.9299, 'ABANDO')
ON CONFLICT DO NOTHING;

INSERT INTO riders (home_zone, avg_pickup_time, avg_delivery_time) VALUES
  ('BILBAO_CENTRO', 6.0, 14.0),
  ('DEUSTO',        7.0, 15.0),
  ('SANTUTXU',      8.0, 16.0),
  ('INDAUTXU',      6.5, 13.5),
  ('ABANDO',        5.5, 12.5)
ON CONFLICT DO NOTHING;

-- =========================
-- 3) ORDERS + EVENTS (coherentes)
--    - Usamos CTEs para capturar order_id
-- =========================

WITH
et AS (
  SELECT event_name, event_type_id
  FROM event_types
),
wx AS (
  SELECT weather_name, weather_id
  FROM weather_levels
),
tr AS (
  SELECT traffic_name, traffic_id
  FROM traffic_levels
),
dr AS (
  SELECT delay_reason_name, delay_reason_id
  FROM delay_reasons
),
cat AS (
  SELECT category_name, category_id
  FROM order_categories
),
rest AS (
  SELECT restaurant_name, restaurant_id
  FROM restaurants
),
rid AS (
  SELECT home_zone, rider_id
  FROM riders
),

-- ---------
-- ORDER A: Delivered (normal)
-- ---------
o1 AS (
  INSERT INTO orders
    (created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
     customer_lat, customer_lon, order_status, restaurant_id, category_id)
  SELECT
    now() - interval '55 minutes',
    18.90, 2, 15, 30,
    43.2652, -2.9341,
    'DELIVERED',
    (SELECT restaurant_id FROM rest WHERE restaurant_name = 'Napoli Pizza Lab'),
    (SELECT category_id   FROM cat  WHERE category_name  = 'PIZZA')
  RETURNING order_id, created_at
),

-- ---------
-- ORDER B: Cancelled (por restaurant busy)
-- ---------
o2 AS (
  INSERT INTO orders
    (created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
     customer_lat, customer_lon, order_status, restaurant_id, category_id)
  SELECT
    now() - interval '40 minutes',
    24.50, 3, 20, 35,
    43.2718, -2.9510,
    'CANCELLED',
    (SELECT restaurant_id FROM rest WHERE restaurant_name = 'Sakura Sushi'),
    (SELECT category_id   FROM cat  WHERE category_name  = 'SUSHI')
  RETURNING order_id, created_at
),

-- ---------
-- ORDER C: In progress (READY)
-- ---------
o3 AS (
  INSERT INTO orders
    (created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
     customer_lat, customer_lon, order_status, restaurant_id, category_id)
  SELECT
    now() - interval '25 minutes',
    13.20, 1, 12, 25,
    43.2585, -2.9258,
    'READY',
    (SELECT restaurant_id FROM rest WHERE restaurant_name = 'Burger Station'),
    (SELECT category_id   FROM cat  WHERE category_name  = 'FAST_FOOD')
  RETURNING order_id, created_at
),

-- ---------
-- ORDER D: In progress (PICKED_UP)
-- ---------
o4 AS (
  INSERT INTO orders
    (created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
     customer_lat, customer_lon, order_status, restaurant_id, category_id)
  SELECT
    now() - interval '30 minutes',
    29.70, 4, 18, 40,
    43.2628, -2.9488,
    'PICKED_UP',
    (SELECT restaurant_id FROM rest WHERE restaurant_name = 'Bombay Corner'),
    (SELECT category_id   FROM cat  WHERE category_name  = 'INDIAN')
  RETURNING order_id, created_at
),

-- ---------
-- ORDER E: Just created (CREATED)
-- ---------
o5 AS (
  INSERT INTO orders
    (created_at, order_value, items_count, estimated_prep_time, estimated_delivery_time,
     customer_lat, customer_lon, order_status, restaurant_id, category_id)
  SELECT
    now() - interval '7 minutes',
    11.50, 2, 10, 20,
    43.2609, -2.9314,
    'CREATED',
    (SELECT restaurant_id FROM rest WHERE restaurant_name = 'Green Bowl'),
    (SELECT category_id   FROM cat  WHERE category_name  = 'HEALTHY')
  RETURNING order_id, created_at
)

-- =========================
-- EVENTS INSERT
-- =========================
INSERT INTO events (ts, order_id, event_type_id, rider_id, weather_id, traffic_id, delay_reason_id)

-- ---- Order A (DELIVERED)
SELECT
  o1.created_at,
  o1.order_id,
  (SELECT event_type_id FROM et WHERE event_name='CREATED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
  NULL
FROM o1
UNION ALL
SELECT
  o1.created_at + interval '2 minutes',
  o1.order_id,
  (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
  NULL
FROM o1
UNION ALL
SELECT
  o1.created_at + interval '10 minutes',
  o1.order_id,
  (SELECT event_type_id FROM et WHERE event_name='READY'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
  NULL
FROM o1
UNION ALL
SELECT
  o1.created_at + interval '13 minutes',
  o1.order_id,
  (SELECT event_type_id FROM et WHERE event_name='PICKED_UP'),
  (SELECT rider_id FROM rid WHERE home_zone='BILBAO_CENTRO' LIMIT 1),
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
  NULL
FROM o1
UNION ALL
SELECT
  o1.created_at + interval '33 minutes',
  o1.order_id,
  (SELECT event_type_id FROM et WHERE event_name='DELIVERED'),
  (SELECT rider_id FROM rid WHERE home_zone='BILBAO_CENTRO' LIMIT 1),
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
  NULL
FROM o1

-- ---- Order B (CANCELLED)
UNION ALL
SELECT
  o2.created_at,
  o2.order_id,
  (SELECT event_type_id FROM et WHERE event_name='CREATED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='RAIN'),
  (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
  NULL
FROM o2
UNION ALL
SELECT
  o2.created_at + interval '3 minutes',
  o2.order_id,
  (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='RAIN'),
  (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
  NULL
FROM o2
UNION ALL
SELECT
  o2.created_at + interval '6 minutes',
  o2.order_id,
  (SELECT event_type_id FROM et WHERE event_name='CANCELLED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='RAIN'),
  (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
  (SELECT delay_reason_id FROM dr WHERE delay_reason_name='RESTAURANT_BUSY')
FROM o2

-- ---- Order C (READY)
UNION ALL
SELECT
  o3.created_at,
  o3.order_id,
  (SELECT event_type_id FROM et WHERE event_name='CREATED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='WIND'),
  (SELECT traffic_id FROM tr WHERE traffic_name='LOW'),
  NULL
FROM o3
UNION ALL
SELECT
  o3.created_at + interval '2 minutes',
  o3.order_id,
  (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='WIND'),
  (SELECT traffic_id FROM tr WHERE traffic_name='LOW'),
  NULL
FROM o3
UNION ALL
SELECT
  o3.created_at + interval '9 minutes',
  o3.order_id,
  (SELECT event_type_id FROM et WHERE event_name='READY'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='WIND'),
  (SELECT traffic_id FROM tr WHERE traffic_name='LOW'),
  NULL
FROM o3

-- ---- Order D (PICKED_UP)
UNION ALL
SELECT
  o4.created_at,
  o4.order_id,
  (SELECT event_type_id FROM et WHERE event_name='CREATED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
  NULL
FROM o4
UNION ALL
SELECT
  o4.created_at + interval '3 minutes',
  o4.order_id,
  (SELECT event_type_id FROM et WHERE event_name='ACCEPTED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
  NULL
FROM o4
UNION ALL
SELECT
  o4.created_at + interval '14 minutes',
  o4.order_id,
  (SELECT event_type_id FROM et WHERE event_name='READY'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
  (SELECT delay_reason_id FROM dr WHERE delay_reason_name='TRAFFIC')
FROM o4
UNION ALL
SELECT
  o4.created_at + interval '16 minutes',
  o4.order_id,
  (SELECT event_type_id FROM et WHERE event_name='PICKED_UP'),
  (SELECT rider_id FROM rid WHERE home_zone='SANTUTXU' LIMIT 1),
  (SELECT weather_id FROM wx WHERE weather_name='CLEAR'),
  (SELECT traffic_id FROM tr WHERE traffic_name='HIGH'),
  (SELECT delay_reason_id FROM dr WHERE delay_reason_name='TRAFFIC')
FROM o4

-- ---- Order E (CREATED)
UNION ALL
SELECT
  o5.created_at,
  o5.order_id,
  (SELECT event_type_id FROM et WHERE event_name='CREATED'),
  NULL,
  (SELECT weather_id FROM wx WHERE weather_name='HEAT'),
  (SELECT traffic_id FROM tr WHERE traffic_name='MEDIUM'),
  NULL
FROM o5
;

COMMIT;