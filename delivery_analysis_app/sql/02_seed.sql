BEGIN;

-- =====================================
-- LIMPIEZA
-- =====================================
DELETE FROM order_events;
DELETE FROM deliveries;
DELETE FROM orders;
DELETE FROM riders;
DELETE FROM restaurants;

-- =====================================
-- RESTAURANTS
-- =====================================
INSERT INTO restaurants (
  restaurant_id,
  restaurant_name,
  cuisine_category,
  base_prep_time,
  capacity,
  restaurant_zone,
  restaurant_lat,
  restaurant_lon
) VALUES
  (1, 'Napoli Pizza Lab', 'ITALIAN', 15, 20, 'CENTRO', 43.2630, -2.9350),
  (2, 'Sakura Sushi', 'JAPANESE', 20, 15, 'NORTE', 43.2710, -2.9520),
  (3, 'Burger Station', 'AMERICAN', 12, 18, 'SUR', 43.2580, -2.9260),
  (4, 'Bombay Corner', 'INDIAN', 18, 16, 'CENTRO', 43.2620, -2.9490),
  (5, 'Green Bowl', 'HEALTHY', 10, 14, 'EAST', 43.2610, -2.9310);

-- =====================================
-- RIDERS
-- =====================================
INSERT INTO riders (
  rider_id,
  rider_name,
  home_zone,
  vehicle_type,
  max_orders_per_hour
) VALUES
  (1, 'Alex Ruiz', 'CENTRO', 'BIKE', 3),
  (2, 'Marta Lopez', 'NORTE', 'MOTORBIKE', 5),
  (3, 'Jon Etxeberria', 'SUR', 'BIKE', 3),
  (4, 'Carlos Vega', 'EAST', 'MOTORBIKE', 6),
  (5, 'Iker Bilbao', 'CENTRO', 'BIKE', 4);

-- =====================================
-- ORDERS
-- =====================================
INSERT INTO orders (
  order_id,
  created_at,
  order_value,
  items_count,
  estimated_prep_time,
  estimated_delivery_time,
  customer_lat,
  customer_lon,
  order_status,
  restaurant_id,
  weather_level,
  traffic_level
) VALUES
  (1, '2026-01-10 13:05:00', 22.50, 3, 15, 20, 43.2620, -2.9340, 'DELIVERED', 1, 'CLEAR', 'MEDIUM'),
  (2, '2026-01-10 14:10:00', 35.00, 5, 20, 25, 43.2700, -2.9500, 'DELIVERED', 2, 'RAIN', 'HIGH'),
  (3, '2026-01-11 20:15:00', 18.75, 2, 12, 18, 43.2585, -2.9280, 'DELIVERED', 3, 'CLEAR', 'LOW'),
  (4, '2026-01-11 21:30:00', 40.20, 6, 18, 30, 43.2635, -2.9480, 'DELIVERED', 4, 'WIND', 'MEDIUM'),
  (5, '2026-01-12 12:45:00', 15.00, 2, 10, 15, 43.2600, -2.9320, 'CANCELLED', 5, 'RAIN', 'HIGH');

-- =====================================
-- DELIVERIES
-- SOLO PARA PEDIDOS ENTREGADOS
-- =====================================
INSERT INTO deliveries (
  delivery_id,
  order_id,
  rider_id,
  assigned_at,
  picked_up_at,
  delivered_at,
  hour,
  day,
  month,
  prep_minutes,
  delivery_minutes,
  total_minutes
) VALUES
  (1, 1, 1, '2026-01-10 13:07:00', '2026-01-10 13:22:00', '2026-01-10 13:42:00', 13, 'Saturday', 1, 15.00, 20.00, 35.00),
  (2, 2, 2, '2026-01-10 14:12:00', '2026-01-10 14:35:00', '2026-01-10 15:05:00', 14, 'Saturday', 1, 23.00, 30.00, 53.00),
  (3, 3, 3, '2026-01-11 20:17:00', '2026-01-11 20:29:00', '2026-01-11 20:48:00', 20, 'Sunday', 1, 12.00, 19.00, 31.00),
  (4, 4, 4, '2026-01-11 21:32:00', '2026-01-11 21:55:00', '2026-01-11 22:30:00', 21, 'Sunday', 1, 23.00, 35.00, 58.00);

-- =====================================
-- ORDER EVENTS
-- =====================================
INSERT INTO order_events (
  event_id,
  order_id,
  event_name,
  event_timestamp
) VALUES
  -- ORDER 1
  (1, 1, 'CREATED',   '2026-01-10 13:05:00'),
  (2, 1, 'ACCEPTED',  '2026-01-10 13:06:00'),
  (3, 1, 'PREPARING', '2026-01-10 13:07:00'),
  (4, 1, 'READY',     '2026-01-10 13:20:00'),
  (5, 1, 'PICKED_UP', '2026-01-10 13:22:00'),
  (6, 1, 'DELIVERED', '2026-01-10 13:42:00'),

  -- ORDER 2
  (7, 2, 'CREATED',   '2026-01-10 14:10:00'),
  (8, 2, 'ACCEPTED',  '2026-01-10 14:11:00'),
  (9, 2, 'PREPARING', '2026-01-10 14:12:00'),
  (10, 2, 'READY',    '2026-01-10 14:33:00'),
  (11, 2, 'PICKED_UP','2026-01-10 14:35:00'),
  (12, 2, 'DELIVERED','2026-01-10 15:05:00'),

  -- ORDER 3
  (13, 3, 'CREATED',   '2026-01-11 20:15:00'),
  (14, 3, 'ACCEPTED',  '2026-01-11 20:16:00'),
  (15, 3, 'PREPARING', '2026-01-11 20:17:00'),
  (16, 3, 'READY',     '2026-01-11 20:27:00'),
  (17, 3, 'PICKED_UP', '2026-01-11 20:29:00'),
  (18, 3, 'DELIVERED', '2026-01-11 20:48:00'),

  -- ORDER 4
  (19, 4, 'CREATED',   '2026-01-11 21:30:00'),
  (20, 4, 'ACCEPTED',  '2026-01-11 21:31:00'),
  (21, 4, 'PREPARING', '2026-01-11 21:32:00'),
  (22, 4, 'READY',     '2026-01-11 21:53:00'),
  (23, 4, 'PICKED_UP', '2026-01-11 21:55:00'),
  (24, 4, 'DELIVERED', '2026-01-11 22:30:00'),

  -- ORDER 5
  (25, 5, 'CREATED',   '2026-01-12 12:45:00'),
  (26, 5, 'CANCELLED', '2026-01-12 12:50:00');

COMMIT;