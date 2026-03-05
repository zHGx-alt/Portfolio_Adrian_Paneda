-- =============================
-- Order delivery metrics
-- =============================
CREATE OR REPLACE VIEW order_delivery_metrics AS
SELECT
    o.order_id,
    o.restaurant_id,
    o.category_id,
    MIN(CASE WHEN et.event_name='CREATED' THEN e.ts END) AS created_at,
    MAX(CASE WHEN et.event_name='DELIVERED' THEN e.ts END) AS delivered_at,
    MAX(CASE WHEN et.event_name='READY' THEN e.ts END) AS ready_at,
    MAX(CASE WHEN et.event_name='PICKED_UP' THEN e.ts END) AS picked_up_at,
    MAX(e.ts) - MIN(e.ts) AS lifecycle_time
FROM events e
JOIN event_types et USING(event_type_id)
JOIN orders o USING(order_id)
GROUP BY o.order_id, o.restaurant_id, o.category_id;

-- =============================
-- Delivery duration
-- =============================
CREATE OR REPLACE VIEW delivery_duration AS
SELECT
    order_id,
    delivered_at - created_at AS delivery_time
FROM order_delivery_metrics
WHERE delivered_at IS NOT NULL;

-- =============================
-- Preparation duration
-- =============================
CREATE OR REPLACE VIEW preparation_duration AS
SELECT
    order_id,
    ready_at - created_at AS preparation_time
FROM order_delivery_metrics
WHERE ready_at IS NOT NULL;

-- =============================
-- Pickup duration
-- =============================
CREATE OR REPLACE VIEW pickup_duration AS
SELECT
    order_id,
    picked_up_at - ready_at AS pickup_delay
FROM order_delivery_metrics
WHERE picked_up_at IS NOT NULL;

-- =============================
-- Order status summary
-- =============================
CREATE OR REPLACE VIEW order_status_summary AS
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;