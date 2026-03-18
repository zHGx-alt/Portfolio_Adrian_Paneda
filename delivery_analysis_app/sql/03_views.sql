CREATE OR REPLACE VIEW order_delivery_metrics AS
SELECT
    o.order_id,
    o.restaurant_id,
    MIN(CASE WHEN oe.event_name = 'CREATED' THEN oe.event_timestamp END) AS created_at,
    MAX(CASE WHEN oe.event_name = 'READY' THEN oe.event_timestamp END) AS ready_at,
    MAX(CASE WHEN oe.event_name = 'PICKED_UP' THEN oe.event_timestamp END) AS picked_up_at,
    MAX(CASE WHEN oe.event_name = 'DELIVERED' THEN oe.event_timestamp END) AS delivered_at,
    MAX(CASE WHEN oe.event_name = 'CANCELLED' THEN oe.event_timestamp END) AS cancelled_at,
    CASE
        WHEN MAX(CASE WHEN oe.event_name = 'DELIVERED' THEN oe.event_timestamp END) IS NOT NULL
        THEN MAX(CASE WHEN oe.event_name = 'DELIVERED' THEN oe.event_timestamp END)
           - MIN(CASE WHEN oe.event_name = 'CREATED' THEN oe.event_timestamp END)
        WHEN MAX(CASE WHEN oe.event_name = 'CANCELLED' THEN oe.event_timestamp END) IS NOT NULL
        THEN MAX(CASE WHEN oe.event_name = 'CANCELLED' THEN oe.event_timestamp END)
           - MIN(CASE WHEN oe.event_name = 'CREATED' THEN oe.event_timestamp END)
        ELSE NULL
    END AS lifecycle_time
FROM order_events oe
JOIN orders o
    ON o.order_id = oe.order_id
GROUP BY o.order_id, o.restaurant_id;

CREATE OR REPLACE VIEW delivery_duration AS
SELECT
    order_id,
    delivered_at - created_at AS delivery_time
FROM order_delivery_metrics
WHERE delivered_at IS NOT NULL
  AND created_at IS NOT NULL;

CREATE OR REPLACE VIEW preparation_duration AS
SELECT
    order_id,
    ready_at - created_at AS preparation_time
FROM order_delivery_metrics
WHERE ready_at IS NOT NULL
  AND created_at IS NOT NULL;

CREATE OR REPLACE VIEW pickup_duration AS
SELECT
    order_id,
    picked_up_at - ready_at AS pickup_delay
FROM order_delivery_metrics
WHERE picked_up_at IS NOT NULL
  AND ready_at IS NOT NULL;

CREATE OR REPLACE VIEW order_status_summary AS
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;

CREATE OR REPLACE VIEW delivery_analysis_base AS
SELECT
    o.order_id,
    o.created_at,
    o.order_value,
    o.items_count,
    o.estimated_prep_time,
    o.estimated_delivery_time,
    o.order_status,
    o.weather_level,
    o.traffic_level,
    o.restaurant_id,
    r.restaurant_name,
    r.cuisine_category,
    d.rider_id,
    ri.vehicle_type,
    d.assigned_at,
    d.picked_up_at,
    d.delivered_at,
    d.hour,
    d.day,
    d.month,
    d.prep_minutes,
    d.delivery_minutes,
    d.total_minutes
FROM orders o
LEFT JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
LEFT JOIN deliveries d
    ON o.order_id = d.order_id
LEFT JOIN riders ri
    ON d.rider_id = ri.rider_id;

CREATE OR REPLACE VIEW delay_metrics AS
SELECT
    o.order_id,
    o.estimated_prep_time,
    o.estimated_delivery_time,
    d.prep_minutes,
    d.delivery_minutes,
    d.total_minutes,
    (d.prep_minutes - o.estimated_prep_time) AS prep_delay_minutes,
    (d.delivery_minutes - o.estimated_delivery_time) AS delivery_delay_minutes,
    (d.total_minutes - (o.estimated_prep_time + o.estimated_delivery_time)) AS total_delay_minutes
FROM orders o
JOIN deliveries d
    ON o.order_id = d.order_id
WHERE o.order_status = 'DELIVERED';