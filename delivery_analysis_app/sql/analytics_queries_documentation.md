# SQL Analytics Queries Documentation

Esta documentación explica las consultas SQL utilizadas en la aplicación de análisis de entregas. Está escrita para personas que aprenden SQL y quieren entender qué hacen estas consultas.

## Tabla de Contenidos

1. [¿Qué es SQL?](#qué-es-sql)
2. [Conceptos Básicos de SQL](#conceptos-básicos-de-sql)
3. [1. Rendimiento General de Entregas](#1-rendimiento-general-de-entregas)
4. [2. Demanda y Actividad de Restaurantes](#2-demanda-y-actividad-de-restaurantes)
5. [3. Impacto del Contexto: Tráfico y Clima](#3-impacto-del-contexto-tráfico-y-clima)
6. [4. Rendimiento Estimado vs Real](#4-rendimiento-estimado-vs-real)
7. [5. Rendimiento Temporal](#5-rendimiento-temporal)
8. [6. Rendimiento de Riders](#6-rendimiento-de-riders)
9. [7. Complejidad de Pedidos](#7-complejidad-de-pedidos)
10. [8. Trazabilidad de Procesos](#8-trazabilidad-de-procesos)

## ¿Qué es SQL?

SQL (Structured Query Language) es un lenguaje para comunicarse con bases de datos. Nos ayuda a hacer preguntas sobre los datos y obtener respuestas. Piensa en una base de datos como una hoja de cálculo grande con múltiples tablas.

## Conceptos Básicos de SQL

- **SELECT**: Elige qué información quieres ver
- **FROM**: Especifica de qué tabla obtener los datos
- **JOIN**: Combina datos de múltiples tablas
- **WHERE**: Filtra datos basándose en condiciones
- **GROUP BY**: Agrupa datos por categorías
- **ORDER BY**: Ordena los resultados
- **COUNT()**: Cuenta el número de filas
- **AVG()**: Calcula promedios
- **ROUND()**: Redondea números

## 1. Rendimiento General de Entregas

Estas consultas dan una vista general de cómo funcionan las entregas en todo el sistema.

### 1.1 Tiempo Promedio de Entrega General
```sql
SELECT ROUND(AVG(EXTRACT(EPOCH FROM delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM delivery_duration;
```
**Qué hace**: Calcula el tiempo promedio que toman las entregas, en minutos.

### 1.2 Tiempo Promedio de Preparación General
```sql
SELECT ROUND(AVG(EXTRACT(EPOCH FROM preparation_time) / 60.0)::numeric, 2) AS avg_prep_time_min
FROM preparation_duration;
```
**Qué hace**: Calcula el tiempo promedio que los restaurantes tardan en preparar los pedidos.

### 1.3 Tasa de Cancelación General
```sql
SELECT ROUND(COUNT(*) FILTER (WHERE order_status = 'CANCELLED')::numeric / NULLIF(COUNT(*), 0), 4) AS cancel_rate
FROM orders;
```
**Qué hace**: Muestra qué porcentaje de pedidos se cancelan.

## 2. Demanda y Actividad de Restaurantes

Estas consultas analizan cómo funcionan diferentes restaurantes y cocinas.

### 2.1 Total de Pedidos por Categoría de Cocina
```sql
SELECT r.cuisine_category, COUNT(*) AS total_orders
FROM orders o JOIN restaurants r USING (restaurant_id)
GROUP BY r.cuisine_category
ORDER BY total_orders DESC;
```
**Qué hace**: Muestra qué tipos de comida son más populares.

### 2.2 Tiempo Promedio de Entrega por Restaurante
```sql
SELECT r.restaurant_id, r.restaurant_name, ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM delivery_duration d JOIN orders o USING (order_id) JOIN restaurants r USING (restaurant_id)
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY avg_delivery_time_min;
```
**Qué hace**: Muestra qué restaurantes tienen los tiempos de entrega más rápidos.

### 2.3 Tasa de Cancelación por Restaurante
```sql
SELECT r.restaurant_id, r.restaurant_name, COUNT(*) AS total_orders, COUNT(*) FILTER (WHERE o.order_status = 'CANCELLED') AS cancelled_orders, ROUND(COUNT(*) FILTER (WHERE o.order_status = 'CANCELLED')::numeric / NULLIF(COUNT(*), 0), 4) AS cancel_rate
FROM orders o JOIN restaurants r USING (restaurant_id)
GROUP BY r.restaurant_id, r.restaurant_name
HAVING COUNT(*) >= 20
ORDER BY cancel_rate DESC;
```
**Qué hace**: Muestra qué restaurantes tienen las tasas de cancelación más altas (solo restaurantes con 20+ pedidos).

## 3. Impacto del Contexto: Tráfico y Clima

Estas consultas muestran cómo factores externos afectan el rendimiento de las entregas.

### 3.1 Tiempo Promedio de Entrega por Nivel de Tráfico
```sql
SELECT o.traffic_level, ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM orders o JOIN delivery_duration d USING (order_id)
GROUP BY o.traffic_level
ORDER BY avg_delivery_time_min;
```
**Qué hace**: Muestra cómo el tráfico afecta la velocidad de entrega.

### 3.2 Tiempo Promedio de Entrega por Nivel de Clima
```sql
SELECT o.weather_level, ROUND(AVG(EXTRACT(EPOCH FROM d.delivery_time) / 60.0)::numeric, 2) AS avg_delivery_time_min
FROM orders o JOIN delivery_duration d USING (order_id)
GROUP BY o.weather_level
ORDER BY avg_delivery_time_min;
```
**Qué hace**: Muestra cómo el clima afecta la velocidad de entrega.

### 3.3 Tasa de Cancelación por Nivel de Tráfico
```sql
SELECT traffic_level, COUNT(*) AS total_orders, COUNT(*) FILTER (WHERE order_status = 'CANCELLED') AS cancelled_orders, ROUND(COUNT(*) FILTER (WHERE order_status = 'CANCELLED')::numeric / NULLIF(COUNT(*), 0), 4) AS cancel_rate
FROM orders
GROUP BY traffic_level
ORDER BY cancel_rate DESC;
```
**Qué hace**: Muestra cómo el tráfico afecta las cancelaciones de pedidos.

### 3.4 Tasa de Cancelación por Nivel de Clima
```sql
SELECT weather_level, COUNT(*) AS total_orders, COUNT(*) FILTER (WHERE order_status = 'CANCELLED') AS cancelled_orders, ROUND(COUNT(*) FILTER (WHERE order_status = 'CANCELLED')::numeric / NULLIF(COUNT(*), 0), 4) AS cancel_rate
FROM orders
GROUP BY weather_level
ORDER BY cancel_rate DESC;
```
**Qué hace**: Muestra cómo el clima afecta las cancelaciones de pedidos.

## 4. Rendimiento Estimado vs Real

Estas consultas comparan lo que se prometió con lo que realmente sucedió.

### 4.1 Tiempo de Entrega General: Estimado vs Real
```sql
SELECT ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min, ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min, ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_delivery_gap_min
FROM deliveries d JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED';
```
**Qué hace**: Compara el tiempo promedio real de entrega con el tiempo promedio estimado, y muestra la diferencia promedio.

### 4.2 Brecha de Tiempo de Entrega por Restaurante
```sql
SELECT r.restaurant_id, r.restaurant_name, COUNT(*) AS total_orders, ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min, ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min, ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_gap_min
FROM deliveries d JOIN orders o USING (order_id) JOIN restaurants r USING (restaurant_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.restaurant_id, r.restaurant_name
HAVING COUNT(*) >= 20
ORDER BY avg_gap_min DESC;
```
**Qué hace**: Muestra qué restaurantes tienden a entregar más tarde de lo prometido.

### 4.3 Brecha de Tiempo de Entrega por Nivel de Tráfico
```sql
SELECT o.traffic_level, COUNT(*) AS total_orders, ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min, ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min, ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_gap_min
FROM deliveries d JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY o.traffic_level
ORDER BY avg_gap_min DESC;
```
**Qué hace**: Muestra cómo el tráfico afecta si las entregas llegan a tiempo.

### 4.4 Brecha de Tiempo de Entrega por Nivel de Clima
```sql
SELECT o.weather_level, COUNT(*) AS total_orders, ROUND(AVG(o.estimated_delivery_time)::numeric, 2) AS avg_estimated_delivery_min, ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_real_delivery_min, ROUND(AVG(d.delivery_minutes - o.estimated_delivery_time)::numeric, 2) AS avg_gap_min
FROM deliveries d JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY o.weather_level
ORDER BY avg_gap_min DESC;
```
**Qué hace**: Muestra cómo el clima afecta si las entregas llegan a tiempo.

### 4.5 Brecha de Tiempo de Preparación por Restaurante
```sql
SELECT r.restaurant_id, r.restaurant_name, r.base_prep_time, COUNT(*) AS total_orders, ROUND(AVG(d.prep_minutes)::numeric, 2) AS avg_real_prep_minutes, ROUND(AVG(d.prep_minutes - r.base_prep_time)::numeric, 2) AS avg_prep_gap_min
FROM restaurants r JOIN orders o USING (restaurant_id) JOIN deliveries d USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.restaurant_id, r.restaurant_name, r.base_prep_time
HAVING COUNT(*) >= 20
ORDER BY avg_prep_gap_min DESC;
```
**Qué hace**: Muestra qué restaurantes tardan más que su tiempo estándar de preparación.

## 5. Rendimiento Temporal

Estas consultas miran cómo cambia el rendimiento a lo largo del día.

### 5.1 Rendimiento de Entrega por Hora del Día
```sql
SELECT d.hour, COUNT(*) AS total_deliveries, ROUND(AVG(d.prep_minutes)::numeric, 2) AS avg_prep_minutes, ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes, ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM deliveries d JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY d.hour
ORDER BY d.hour;
```
**Qué hace**: Muestra el rendimiento de entrega para cada hora del día.

### 5.2 Presión de Horas Pico: Volumen de Entrega y Rendimiento
```sql
SELECT d.hour, COUNT(*) AS total_deliveries, ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes, ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes
FROM deliveries d JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY d.hour
HAVING COUNT(*) >= 10
ORDER BY total_deliveries DESC, avg_total_minutes DESC;
```
**Qué hace**: Identifica horas ocupadas y cómo cambia el rendimiento durante las horas pico.

## 6. Rendimiento de Riders

Estas consultas analizan cómo funcionan los riders de entrega.

### 6.1 Carga de Trabajo y Rendimiento del Rider
```sql
SELECT r.rider_id, r.rider_name, r.vehicle_type, COUNT(d.delivery_id) AS total_deliveries, ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes, ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM deliveries d JOIN riders r USING (rider_id)
GROUP BY r.rider_id, r.rider_name, r.vehicle_type
ORDER BY total_deliveries DESC, avg_total_minutes ASC;
```
**Qué hace**: Muestra qué tan ocupado está cada rider y qué tan rápido entrega.

### 6.2 Rendimiento de Entrega por Tipo de Vehículo
```sql
SELECT r.vehicle_type, COUNT(*) AS total_deliveries, ROUND(AVG(d.delivery_minutes)::numeric, 2) AS avg_delivery_minutes, ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM deliveries d JOIN riders r USING (rider_id) JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.vehicle_type
ORDER BY avg_delivery_minutes;
```
**Qué hace**: Compara el rendimiento entre diferentes tipos de vehículos (bicicleta, auto, etc.).

### 6.3 Productividad del Rider por Franja Activa
```sql
SELECT r.rider_id, r.rider_name, r.vehicle_type, COUNT(*) AS total_deliveries, ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes, ROUND(COUNT(*)::numeric / NULLIF(COUNT(DISTINCT d.day || '-' || d.hour), 0), 2) AS avg_deliveries_per_active_slot
FROM deliveries d JOIN riders r USING (rider_id) JOIN orders o USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY r.rider_id, r.rider_name, r.vehicle_type
HAVING COUNT(*) >= 10
ORDER BY avg_deliveries_per_active_slot DESC, avg_total_minutes ASC;
```
**Qué hace**: Muestra qué riders son más eficientes, considerando cuántas entregas hacen por hora que están activos.

## 7. Complejidad de Pedidos

Estas consultas miran cómo el tamaño del pedido afecta el rendimiento.

### 7.1 Rendimiento de Entrega por Cantidad de Artículos
```sql
SELECT o.items_count, COUNT(*) AS total_orders, ROUND(AVG(d.prep_minutes)::numeric, 2) AS avg_prep_minutes, ROUND(AVG(d.total_minutes)::numeric, 2) AS avg_total_minutes
FROM orders o JOIN deliveries d USING (order_id)
WHERE o.order_status = 'DELIVERED'
GROUP BY o.items_count
ORDER BY o.items_count;
```
**Qué hace**: Muestra cómo el número de artículos en un pedido afecta el tiempo de preparación y total.

## 8. Trazabilidad de Procesos

Estas consultas usan registros de eventos para rastrear el viaje de cada pedido.

### 8.1 Tiempo Promedio de Extremo a Extremo desde CREADO hasta ENTREGADO
```sql
SELECT ROUND(AVG(EXTRACT(EPOCH FROM (delivered.event_timestamp - created.event_timestamp)) / 60.0)::numeric, 2) AS avg_end_to_end_minutes
FROM order_events created JOIN order_events delivered ON created.order_id = delivered.order_id
WHERE created.event_name = 'CREATED' AND delivered.event_name = 'DELIVERED';
```
**Qué hace**: Calcula el tiempo promedio total desde que se hace un pedido hasta que se entrega.

### 8.2 Tiempo Promedio de Cocina desde PREPARANDO hasta LISTO
```sql
SELECT ROUND(AVG(EXTRACT(EPOCH FROM (ready.event_timestamp - preparing.event_timestamp)) / 60.0)::numeric, 2) AS avg_kitchen_stage_minutes
FROM order_events preparing JOIN order_events ready ON preparing.order_id = ready.order_id
WHERE preparing.event_name = 'PREPARING' AND ready.event_name = 'READY';
```
**Qué hace**: Muestra cuánto tiempo tardan los pedidos desde que se preparan hasta que están listos para recoger.

### 8.3 Tiempo Promedio de Espera de Recogida desde LISTO hasta RECOGIDO
```sql
SELECT ROUND(AVG(EXTRACT(EPOCH FROM (picked.event_timestamp - ready.event_timestamp)) / 60.0)::numeric, 2) AS avg_ready_to_pickup_minutes
FROM order_events ready JOIN order_events picked ON ready.order_id = picked.order_id
WHERE ready.event_name = 'READY' AND picked.event_name = 'PICKED_UP';
```
**Qué hace**: Muestra cuánto tiempo esperan los pedidos después de estar listos antes de que un rider los recoja.