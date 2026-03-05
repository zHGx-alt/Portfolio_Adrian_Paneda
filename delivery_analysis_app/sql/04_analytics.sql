-- =====================================
-- 1. Average delivery time
-- =====================================
SELECT
    AVG(delivery_time) AS avg_delivery_time
FROM delivery_duration;


-- =====================================
-- 2. Delivery time by restaurant
-- =====================================
SELECT
    r.restaurant_name,
    AVG(delivery_time) AS avg_delivery_time
FROM delivery_duration d
JOIN orders o USING(order_id)
JOIN restaurants r USING(restaurant_id)
GROUP BY r.restaurant_name
ORDER BY avg_delivery_time;


-- =====================================
-- 3. Average preparation time
-- =====================================
SELECT
    AVG(preparation_time) AS avg_prep_time
FROM preparation_duration;


-- =====================================
-- 4. Cancel rate
-- =====================================
SELECT
    COUNT(*) FILTER (WHERE order_status='CANCELLED')::float
    /
    COUNT(*) AS cancel_rate
FROM orders;


-- =====================================
-- 5. Orders by category
-- =====================================
SELECT
    oc.category_name,
    COUNT(*) AS total_orders
FROM orders o
JOIN order_categories oc USING(category_id)
GROUP BY oc.category_name
ORDER BY total_orders DESC;


-- =====================================
-- 6. Impact of traffic on delivery
-- =====================================
SELECT
    tl.traffic_name,
    AVG(e.ts - o.created_at) AS avg_delivery_time
FROM events e
JOIN traffic_levels tl USING(traffic_id)
JOIN event_types et USING(event_type_id)
JOIN orders o USING(order_id)
WHERE et.event_name='DELIVERED'
GROUP BY tl.traffic_name;


-- =====================================
-- 7. Impact of weather on delivery
-- =====================================
SELECT
    wl.weather_name,
    AVG(e.ts - o.created_at) AS avg_delivery_time
FROM events e
JOIN weather_levels wl USING(weather_id)
JOIN event_types et USING(event_type_id)
JOIN orders o USING(order_id)
WHERE et.event_name='DELIVERED'
GROUP BY wl.weather_name;


-- =====================================
-- 8. Rider workload
-- =====================================
SELECT
    r.rider_id,
    COUNT(e.order_id) AS deliveries
FROM events e
JOIN event_types et USING(event_type_id)
JOIN riders r USING(rider_id)
WHERE et.event_name='DELIVERED'
GROUP BY r.rider_id
ORDER BY deliveries DESC;