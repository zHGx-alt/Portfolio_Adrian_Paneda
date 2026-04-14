-- =========================================================
-- DELIVERY ANALYTICS QUERIES
-- =========================================================


-- =========================================================
-- 1. OVERALL DELIVERY PERFORMANCE
-- =========================================================

-- 1.1 Overall average delivery time
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM delivery_duration;


-- 1.2 Overall average preparation time
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM preparation_time) / 60.0)::numeric, 2) AS avg_prep_time_min
FROM preparation_duration;


-- 1.3 Overall cancel rate
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE order_status = 'CANCELLED')::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS cancel_rate
FROM orders;


-- =========================================================
-- 2. DEMAND AND RESTAURANT ACTIVITY
-- =========================================================

-- 2.1 Total orders by cuisine category
SELECT
    r.cuisine_category,
    COUNT(*) AS total_orders
FROM orders o
JOIN restaurants r USING (restaurant_id)
GROUP BY r.cuisine_category
ORDER BY total_orders DESC;


-- 2.2 Average delivery time by restaurant
SELECT
    r.restaurant_id,
    r.restaurant_name,
    ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM delivery_duration d
JOIN orders o USING (order_id)
JOIN restaurants r USING (restaurant_id)
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY avg_delivery_time_min;


-- 2.3 Cancel rate by restaurant
SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE o.order_status = 'CANCELLED') AS cancelled_orders,
    ROUND(
        COUNT(*) FILTER (WHERE o.order_status = 'CANCELLED')::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS cancel_rate
FROM orders o
JOIN restaurants r USING (restaurant_id)
GROUP BY r.restaurant_id, r.restaurant_name
HAVING COUNT(*) >= 20
ORDER BY cancel_rate DESC;


-- =========================================================
-- 3. CONTEXT IMPACT: TRAFFIC AND WEATHER
-- =========================================================

-- 3.1 Average delivery time by traffic level
SELECT
    o.traffic_level,
    ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM orders o
JOIN delivery_duration d USING (order_id)
GROUP BY o.traffic_level
ORDER BY avg_delivery_time_min;


-- 3.2 Average delivery time by weather level
SELECT
    o.weather_level,
    ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM orders o
JOIN delivery_duration d USING (order_id)
GROUP BY o.weather_level
ORDER BY avg_delivery_time_min;


-- 3.3 Cancel rate by traffic level
SELECT
    traffic_level,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE order_status = 'CANCELLED') AS cancelled_orders,
    ROUND(
        COUNT(*) FILTER (WHERE order_status = 'CANCELLED')::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS cancel_rate
FROM orders
GROUP BY traffic_level
ORDER BY cancel_rate DESC;


-- 3.4 Cancel rate by weather level
SELECT
    weather_level,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE order_status = 'CANCELLED') AS cancelled_orders,
    ROUND(
        COUNT(*) FILTER (WHERE order_status = 'CANCELLED')::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS cancel_rate
FROM orders
GROUP BY weather_level
ORDER BY cancel_rate DESC;


-- =========================================================
-- 4. ESTIMATED VS REAL PERFORMANCE
-- =========================================================

-- 4.1 Overall delivery time: estimated vs real
SELECT
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min,
    ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min,
    ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_delivery_gap_min
FROM deliveries d
JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED';


-- 4.2 Delivery time gap by restaurant
SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min,
    ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_gap_min
FROM deliveries d
JOIN orders o USING (order_id)
JOIN restaurants r USING (restaurant_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.restaurant_id, r.restaurant_name
HAVING COUNT(*) >= 20
ORDER BY avg_gap_min DESC;


-- 4.3 Delivery time gap by traffic level
SELECT
    o.traffic_level,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min,
    ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_gap_min
FROM deliveries d
JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY o.traffic_level
ORDER BY avg_gap_min DESC;


-- 4.4 Delivery time gap by weather level
SELECT
    o.weather_level,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min,
    ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_gap_min
FROM deliveries d
JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY o.weather_level
ORDER BY avg_gap_min DESC;


-- 4.5 Preparation time gap by restaurant
SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.base_prep_time,
    COUNT(*) AS total_orders,
    ROUND(AVG(d.prep_minutes)::numeric, 2) AS avg_real_prep_minutes,
    ROUND(AVG(d.prep_minutes - r.base_prep_time)::numeric, 2) AS avg_prep_gap_min
FROM restaurants r
JOIN orders o USING (restaurant_id)
JOIN deliveries d USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.restaurant_id, r.restaurant_name, r.base_prep_time
HAVING COUNT(*) >= 20
ORDER BY avg_prep_gap_min DESC;


-- =========================================================
-- 5. TEMPORAL PERFORMANCE
-- =========================================================

-- 5.1 Delivery performance by hour of day
SELECT
    d.hour,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(d.prep_minutes)::numeric, 2) AS avg_prep_minutes,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes,
    ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM deliveries d
JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY d.hour
ORDER BY d.hour;


-- 5.2 Peak-hour pressure: delivery volume and performance
SELECT
    d.hour,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes
FROM deliveries d
JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY d.hour
HAVING COUNT(*) >= 10
ORDER BY total_deliveries DESC, avg_total_minutes DESC;


-- =========================================================
-- 6. RIDER PERFORMANCE
-- =========================================================

-- 6.1 Rider workload and performance
SELECT
    r.rider_id,
    r.rider_name,
    r.vehicle_type,
    COUNT(d.delivery_id) AS total_deliveries,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes,
    ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM deliveries d
JOIN riders r USING (rider_id)
GROUP BY r.rider_id, r.rider_name, r.vehicle_type
ORDER BY total_deliveries DESC, avg_total_minutes ASC;


-- 6.2 Delivery performance by vehicle type
SELECT
    r.vehicle_type,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes,
    ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM deliveries d
JOIN riders r USING (rider_id)
JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.vehicle_type
ORDER BY avg_delivery_minutes;


-- 6.3 Rider productivity by active slot
SELECT
    r.rider_id,
    r.rider_name,
    r.vehicle_type,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes,
    ROUND(
        COUNT(*)::numeric
        / NULLIF(COUNT(DISTINCT d.day || '-' || d.hour), 0),
        2
    ) AS avg_deliveries_per_active_slot
FROM deliveries d
JOIN riders r USING (rider_id)
JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.rider_id, r.rider_name, r.vehicle_type
HAVING COUNT(*) >= 10
ORDER BY avg_deliveries_per_active_slot DESC, avg_total_minutes ASC;


-- =========================================================
-- 7. ORDER COMPLEXITY
-- =========================================================

-- 7.1 Delivery performance by items count
SELECT
    o.items_count,
    COUNT(*) AS total_orders,
    ROUND(AVG(d.prep_minutes)::numeric, 2) AS avg_prep_minutes,
    ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM orders o
JOIN deliveries d USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY o.items_count
ORDER BY o.items_count;


-- =========================================================
-- 8. PROCESS TRACEABILITY USING EVENTS
-- =========================================================

-- 8.1 Average end-to-end time from CREATED to DELIVERED
SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (delivered.event_timestamp - created.event_timestamp)) / 60.0)::numeric,
        2
    ) AS avg_end_to_end_minutes
FROM order_events created
JOIN order_events delivered
    ON created.order_id = delivered.order_id
WHERE created.event_name = 'CREATED'
  AND delivered.event_name = 'DELIVERED';


-- 8.2 Average kitchen time from PREPARING to READY
SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (ready.event_timestamp - preparing.event_timestamp)) / 60.0)::numeric,
        2
    ) AS avg_kitchen_stage_minutes
FROM order_events preparing
JOIN order_events ready
    ON preparing.order_id = ready.order_id
WHERE preparing.event_name = 'PREPARING'
  AND ready.event_name = 'READY';


-- 8.3 Average pickup waiting time from READY to PICKED_UP
SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (picked.event_timestamp - ready.event_timestamp)) / 60.0)::numeric,
        2
    ) AS avg_ready_to_pickup_minutes
FROM order_events ready
JOIN order_events picked
    ON ready.order_id = picked.order_id
WHERE ready.event_name = 'READY'
  AND picked.event_name = 'PICKED_UP';