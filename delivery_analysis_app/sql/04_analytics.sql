-- =====================================
-- 1. Average delivery time
-- =====================================
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM delivery_time)/60.0)::numeric, 2) AS avg_delivery_time_min
FROM delivery_duration;


-- =====================================
-- 2. Delivery time by restaurant
-- =====================================
SELECT
    r.restaurant_id,
    r.restaurant_name,
    ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time)/60.0)::numeric, 2) AS avg_delivery_time_min
FROM delivery_duration d
JOIN orders o USING(order_id)
JOIN restaurants r USING(restaurant_id)
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY avg_delivery_time_min;


-- =====================================
-- 3. Average preparation time
-- =====================================
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM preparation_time)/60.0)::numeric, 2) AS avg_prep_time_min
FROM preparation_duration;


-- =====================================
-- 4. Cancel rate
-- =====================================
SELECT
    ROUND(
        (
            COUNT(*) FILTER (WHERE order_status = 'CANCELLED')::numeric
            / NULLIF(COUNT(*), 0)
        ), 4
    ) AS cancel_rate
FROM orders;


-- =====================================
-- 5. Orders by cuisine category
-- =====================================
SELECT
    r.cuisine_category,
    COUNT(*) AS total_orders
FROM orders o
JOIN restaurants r USING(restaurant_id)
GROUP BY r.cuisine_category
ORDER BY total_orders DESC;


-- =====================================
-- 6. Impact of traffic on delivery
-- =====================================
SELECT
    o.traffic_level,
    ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time)/60.0)::numeric, 2) AS avg_delivery_time_min
FROM orders o
JOIN delivery_duration d USING(order_id)
GROUP BY o.traffic_level
ORDER BY avg_delivery_time_min;


-- =====================================
-- 7. Impact of weather on delivery
-- =====================================
SELECT
    o.weather_level,
    ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time)/60.0)::numeric, 2) AS avg_delivery_time_min
FROM orders o
JOIN delivery_duration d USING(order_id)
GROUP BY o.weather_level
ORDER BY avg_delivery_time_min;


-- =====================================
-- 8. Rider workload + performance
-- =====================================
SELECT
    r.rider_id,
    r.rider_name,
    r.vehicle_type,
    COUNT(d.delivery_id) AS total_deliveries,
    ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes,
    ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM deliveries d
JOIN riders r USING(rider_id)
GROUP BY r.rider_id, r.rider_name, r.vehicle_type
ORDER BY total_deliveries DESC, avg_total_minutes ASC;