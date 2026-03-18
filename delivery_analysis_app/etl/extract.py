import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
CSV_DIR = PROJECT_DIR / "csv"

CSV_DIR.mkdir(exist_ok=True)

random.seed(42)

NUM_RESTAURANTS = 50
NUM_RIDERS = 120
NUM_ORDERS = 10000

ZONES = ["CENTER", "NORTH", "SOUTH", "EAST", "WEST"]
CUISINES = {
    "ITALIAN": (15, 25),
    "BURGER": (10, 18),
    "SUSHI": (20, 30),
    "HEALTHY": (12, 20),
    "KEBAB": (8, 15),
    "ASIAN": (15, 25),
}
WEATHER_OPTIONS = ["CLEAR", "RAIN", "WIND"]
TRAFFIC_OPTIONS = ["LOW", "MEDIUM", "HIGH"]

START_DATE = datetime(2026, 1, 1, 0, 0, 0)
END_DATE = datetime(2026, 1, 31, 23, 59, 59)


def random_datetime_weighted(start, end):
    """Generate more orders during peak hours."""
    while True:
        total_seconds = int((end - start).total_seconds())
        dt = start + timedelta(seconds=random.randint(0, total_seconds))

        hour = dt.hour
        if hour in [13, 14, 21, 22]:
            if random.random() < 0.75:
                return dt
        elif hour in [12, 15, 20, 23]:
            if random.random() < 0.45:
                return dt
        else:
            if random.random() < 0.12:
                return dt


def build_restaurants():
    restaurants = []
    for i in range(1, NUM_RESTAURANTS + 1):
        cuisine = random.choice(list(CUISINES.keys()))
        base_min, base_max = CUISINES[cuisine]
        restaurants.append({
            "restaurant_id": i,
            "restaurant_name": f"{cuisine}_PLACE_{i}",
            "cuisine_category": cuisine,
            "base_prep_time": random.randint(base_min, base_max),
            "capacity": random.randint(10, 40),
            "restaurant_zone": random.choice(ZONES),
            "restaurant_lat": round(random.uniform(43.20, 43.30), 6),
            "restaurant_lon": round(random.uniform(-2.99, -2.88), 6),
        })
    return restaurants


def build_riders():
    riders = []
    for i in range(1, NUM_RIDERS + 1):
        riders.append({
            "rider_id": i,
            "rider_name": f"RIDER_{i}",
            "home_zone": random.choice(ZONES),
            "vehicle_type": random.choice(["BIKE", "MOTORBIKE"]),
            "max_orders_per_hour": random.randint(2, 5),
        })
    return riders


def pick_weather():
    roll = random.random()
    if roll < 0.70:
        return "CLEAR"
    if roll < 0.90:
        return "RAIN"
    return "WIND"


def pick_traffic(hour):
    if hour in [13, 14, 21, 22]:
        return random.choices(["MEDIUM", "HIGH"], weights=[0.35, 0.65])[0]
    return random.choices(["LOW", "MEDIUM", "HIGH"], weights=[0.55, 0.35, 0.10])[0]


def estimate_order_value(items_count, cuisine):
    base = {
        "ITALIAN": 12,
        "BURGER": 10,
        "SUSHI": 18,
        "HEALTHY": 13,
        "KEBAB": 9,
        "ASIAN": 14,
    }[cuisine]
    value = base * items_count + random.uniform(-2, 6)
    return round(max(value, 6.5), 2)


def generate_orders_and_events(restaurants, riders):
    orders = []
    order_events = []
    deliveries = []

    event_id = 1

    for order_id in range(1, NUM_ORDERS + 1):
        created_at = random_datetime_weighted(START_DATE, END_DATE)
        restaurant = random.choice(restaurants)

        items_count = random.randint(1, 6)
        weather = pick_weather()
        traffic = pick_traffic(created_at.hour)
        is_peak = created_at.hour in [13, 14, 21, 22]

        order_value = estimate_order_value(items_count, restaurant["cuisine_category"])

        prep_time = restaurant["base_prep_time"] + random.randint(-2, 4)
        if is_peak:
            prep_time += random.randint(3, 10)

        delivery_time = random.randint(10, 20)
        if traffic == "MEDIUM":
            delivery_time += random.randint(2, 5)
        elif traffic == "HIGH":
            delivery_time += random.randint(6, 12)

        if weather == "RAIN":
            delivery_time += random.randint(4, 8)
        elif weather == "WIND":
            delivery_time += random.randint(2, 5)

        cancel_prob = 0.05
        if is_peak:
            cancel_prob += 0.03
        if traffic == "HIGH":
            cancel_prob += 0.02

        final_status = "DELIVERED"
        if random.random() < cancel_prob:
            final_status = "CANCELLED"

        customer_lat = round(random.uniform(43.20, 43.30), 6)
        customer_lon = round(random.uniform(-2.99, -2.88), 6)

        orders.append({
            "order_id": order_id,
            "created_at": created_at.isoformat(sep=" "),
            "order_value": order_value,
            "items_count": items_count,
            "estimated_prep_time": prep_time,
            "estimated_delivery_time": delivery_time,
            "customer_lat": customer_lat,
            "customer_lon": customer_lon,
            "order_status": final_status,
            "restaurant_id": restaurant["restaurant_id"],
            "weather_level": weather,
            "traffic_level": traffic,
        })

        timeline = []
        timeline.append(("CREATED", created_at))
        accepted_at = created_at + timedelta(minutes=random.randint(1, 4))
        timeline.append(("ACCEPTED", accepted_at))

        if final_status == "CANCELLED" and random.random() < 0.5:
            cancelled_at = accepted_at + timedelta(minutes=random.randint(1, 5))
            timeline.append(("CANCELLED", cancelled_at))
        else:
            preparing_at = accepted_at + timedelta(minutes=random.randint(1, 3))
            ready_at = preparing_at + timedelta(minutes=prep_time)
            picked_up_at = ready_at + timedelta(minutes=random.randint(2, 8))
            delivered_at = picked_up_at + timedelta(minutes=delivery_time)

            timeline.extend([
                ("PREPARING", preparing_at),
                ("READY", ready_at),
                ("PICKED_UP", picked_up_at),
            ])

            if final_status == "CANCELLED":
                cancelled_at = ready_at + timedelta(minutes=random.randint(1, 4))
                timeline.append(("CANCELLED", cancelled_at))
            else:
                timeline.append(("DELIVERED", delivered_at))

                rider = random.choice(riders)
                deliveries.append({
                    "delivery_id": len(deliveries) + 1,
                    "order_id": order_id,
                    "rider_id": rider["rider_id"],
                    "assigned_at": accepted_at.isoformat(sep=" "),
                    "picked_up_at": picked_up_at.isoformat(sep=" "),
                    "delivered_at": delivered_at.isoformat(sep=" "),
                })

        for event_name, event_time in timeline:
            order_events.append({
                "event_id": event_id,
                "order_id": order_id,
                "event_name": event_name,
                "event_timestamp": event_time.isoformat(sep=" "),
            })
            event_id += 1

    return orders, order_events, deliveries


def write_csv(filename, rows):
    if not rows:
        return
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    restaurants = build_restaurants()
    riders = build_riders()
    orders, order_events, deliveries = generate_orders_and_events(restaurants, riders)

    write_csv(CSV_DIR / "restaurants.csv", restaurants)
    write_csv(CSV_DIR / "riders.csv", riders)
    write_csv(CSV_DIR / "orders.csv", orders)
    write_csv(CSV_DIR / "order_events.csv", order_events)
    write_csv(CSV_DIR / "deliveries.csv", deliveries)

    print("CSV generados correctamente.")
    print(f"restaurants: {len(restaurants)}")
    print(f"riders: {len(riders)}")
    print(f"orders: {len(orders)}")
    print(f"order_events: {len(order_events)}")
    print(f"deliveries: {len(deliveries)}")