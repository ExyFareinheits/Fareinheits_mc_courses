-- =====================================================
-- МОДУЛЬ 3, УРОК 6: Dynamic Load Balancing та Auto-scaling
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-3' AND order_index = 3;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 6;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_lesson_id,
    'Dynamic Load Balancing: Auto-scaling та оптимізація',
    'text',
    '# Dynamic Load Balancing: автоматичне масштабування

## 🎯 Що таке Dynamic Load Balancing?

**Static** = фіксована кількість серверів (3 lobby завжди працюють)
**Dynamic** = автоматичне створення/вимкнення серверів за потребою

```
08:00 (5 гравців):  [Lobby-1] ← тільки 1 працює
12:00 (50 гравців): [Lobby-1] [Lobby-2] ← auto-start Lobby-2
18:00 (200 гравців): [Lobby-1] [Lobby-2] [Lobby-3] [Lobby-4] ← peak hours
23:00 (30 гравців): [Lobby-1] [Lobby-2] ← auto-stop Lobby-3,4
```

**Економія:** платите тільки за активні години!

---

## 🔄 Auto-scaling: Концепція

### Triggeri для scaling UP (додати сервер):

```
1. Середнє навантаження >75% на всіх серверах
   lobby-1: 38/50 (76%)
   lobby-2: 39/50 (78%)
   → START lobby-3

2. TPS падає <18 на будь-якому
   lobby-1: TPS 17.3 ← перевантажений!
   → START lobby-2 (розділити навантаження)

3. Queue system
   Черга: 15 гравців чекають
   → START lobby-3 (обробити чергу)

4. Scheduled peak hours
   17:00-22:00 → auto-start 2 додаткові
```

### Triggers для scaling DOWN (вимкнути сервер):

```
1. Низьке навантаження <25%
   lobby-1: 12/50 (24%)
   lobby-2: 8/50 (16%)
   lobby-3: 5/50 (10%)
   → STOP lobby-3 (переміграти 5 гравців)

2. Idle server (порожній >10 хв)
   lobby-4: 0/50 (0%) for 10 min
   → STOP lobby-4

3. Off-peak hours
   02:00-08:00 → auto-stop до 1 сервера
```

---

## 🛠️ Реалізація: Docker + Pterodactyl

### Docker Compose для динамічних серверів:

```yaml
# docker-compose.yml
version: "3.8"

services:
  velocity:
    image: velocity:latest
    ports:
      - "25565:25577"
    networks:
      - minecraft

  lobby-template:
    image: paper:1.20.4
    deploy:
      replicas: 0  # Start 0, scale динамічно
    networks:
      - minecraft
    environment:
      MEMORY: 2G
      SERVER_PORT: 30066

networks:
  minecraft:
    driver: bridge
```

### Auto-scaling script (Python):

```python
import docker
import time

client = docker.from_env()

def get_player_count(server):
    # Query server via RCON
    return server.execute("list")

def scale_up(service_name):
    service = client.services.get(service_name)
    current = service.attrs["Spec"]["Mode"]["Replicated"]["Replicas"]
    service.scale(current + 1)
    print(f"Scaled {service_name} to {current + 1}")

def scale_down(service_name):
    service = client.services.get(service_name)
    current = service.attrs["Spec"]["Mode"]["Replicated"]["Replicas"]
    if current > 1:
        service.scale(current - 1)
        print(f"Scaled {service_name} to {current - 1}")

while True:
    lobbies = client.services.list(filters={"name": "lobby"})
    total_players = sum(get_player_count(l) for l in lobbies)
    avg_load = total_players / len(lobbies)
    
    if avg_load > 40:  # >80% (50 max)
        scale_up("lobby-template")
    elif avg_load < 15 and len(lobbies) > 1:
        scale_down("lobby-template")
    
    time.sleep(60)  # Check every 1 min
```

---

## 📊 Load Prediction (ML)

### Прогнозування навантаження:

```python
# Використовуємо історичні дані для prediction
import pandas as pd
from sklearn.ensemble import RandomForestRegressor

# Historical data (player count per hour):
data = pd.read_csv("player_history.csv")
# Columns: hour, day_of_week, month, holiday, player_count

# Train model:
X = data[["hour", "day_of_week", "month", "holiday"]]
y = data["player_count"]
model = RandomForestRegressor()
model.fit(X, y)

# Predict next hour:
next_hour = [[18, 5, 12, 0]]  # Friday, 18:00, December, no holiday
predicted = model.predict(next_hour)
print(f"Predicted players: {predicted[0]}")  # → 180 players

# Pre-scale servers:
if predicted[0] > 150:
    scale_up("lobby", target_replicas=4)
```

---

## 🌐 Kubernetes для Minecraft

### Kubernetes deployment:

```yaml
# lobby-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lobby
spec:
  replicas: 2  # Start з 2
  selector:
    matchLabels:
      app: lobby
  template:
    metadata:
      labels:
        app: lobby
    spec:
      containers:
      - name: paper
        image: paper:1.20.4
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "3Gi"
            cpu: "2000m"
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: lobby-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lobby
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Scale at 70% CPU
```

### Auto-scaling у дії:

```bash
# Застосувати конфіг:
kubectl apply -f lobby-deployment.yaml

# Перевірити:
kubectl get hpa
# NAME       TARGETS   MINPODS   MAXPODS   REPLICAS
# lobby-hpa  45%/70%   1         10        2

# Симуляція навантаження:
# 100 гравців підключаються → CPU 85% → scale to 4 replicas

kubectl get pods
# lobby-6d7f8b-abc12  Running  (replica 1)
# lobby-6d7f8b-def34  Running  (replica 2)
# lobby-6d7f8b-ghi56  Running  (replica 3) ← auto-created!
# lobby-6d7f8b-jkl78  Running  (replica 4) ← auto-created!
```

---

## 💰 Cost Optimization

### Порівняння витрат:

**Static (3 lobby 24/7):**
```
3 VPS × $20/міс × 24h/day = $60/міс
Реальне використання:
- Peak (4h/day): потрібно 3 сервери
- Normal (12h/day): потрібно 2 сервери
- Off-peak (8h/day): потрібно 1 сервер

Марнування: ~40% часу сервери простоюють
```

**Dynamic (auto-scaling):**
```
Використання:
- 1 server × 8h = 8h
- 2 servers × 12h = 24h
- 3 servers × 4h = 12h
Total: 44 server-hours/day

Cost (AWS EC2 on-demand):
$0.05/hour × 44h = $2.20/day = $66/міс

BUT з Spot Instances (70% discount):
$0.015/hour × 44h = $0.66/day = $20/міс

Економія: $60 → $20 = -67%!
```

### AWS Auto Scaling Groups:

```yaml
# Terraform config:
resource "aws_autoscaling_group" "lobby" {
  name = "lobby-asg"
  min_size = 1
  max_size = 10
  desired_capacity = 2
  
  launch_template {
    id = aws_launch_template.paper_server.id
  }
  
  # Spot instances (дешево!)
  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy = "capacity-optimized"
    }
  }
  
  # Scaling policies:
  target_tracking_scaling_policy {
    metric = "CPUUtilization"
    target_value = 70.0
  }
}
```

---

## 🔥 Приклад: Production setup

### Pterodactyl API для auto-scaling:

```javascript
// Node.js script
const axios = require(''axios'');

const PTERO_URL = ''https://panel.yourserver.com'';
const API_KEY = ''ptlc_your_api_key'';

async function createServer(name) {
  const response = await axios.post(
    `${PTERO_URL}/api/application/servers`,
    {
      name: name,
      user: 1,
      egg: 5,  // Paper egg
      docker_image: ''ghcr.io/pterodactyl/yolks:java_17'',
      startup: ''java -Xms2G -Xmx2G -jar server.jar'',
      environment: {
        SERVER_JARFILE: ''server.jar'',
        VERSION: ''1.20.4''
      },
      limits: {
        memory: 2048,
        swap: 0,
        disk: 5120,
        io: 500,
        cpu: 200
      },
      allocation: {
        default: 1  // Auto-assign port
      }
    },
    {
      headers: {
        ''Authorization'': `Bearer ${API_KEY}`,
        ''Content-Type'': ''application/json''
      }
    }
  );
  
  console.log(`Created server: ${name}`);
  return response.data.attributes.id;
}

async function deleteServer(serverId) {
  await axios.delete(
    `${PTERO_URL}/api/application/servers/${serverId}`,
    {
      headers: { ''Authorization'': `Bearer ${API_KEY}` }
    }
  );
  console.log(`Deleted server: ${serverId}`);
}

// Auto-scaling loop:
setInterval(async () => {
  const servers = await getActiveServers();
  const totalPlayers = servers.reduce((sum, s) => sum + s.players, 0);
  const avgLoad = totalPlayers / servers.length;
  
  if (avgLoad > 40 && servers.length < 5) {
    await createServer(`lobby-${Date.now()}`);
  } else if (avgLoad < 15 && servers.length > 1) {
    const emptiest = servers.sort((a, b) => a.players - b.players)[0];
    if (emptiest.players === 0) {
      await deleteServer(emptiest.id);
    }
  }
}, 60000);  // Every 1 minute
```

---

## 📈 Моніторинг

### Metrics для auto-scaling:

```
1. Current replicas:
   - Active: 3
   - Target: 4 (scaling up...)

2. Player distribution:
   - lobby-1: 42/50
   - lobby-2: 38/50
   - lobby-3: 45/50
   → Total: 125 players across 3 servers (83% avg)
   → Action: SCALE UP

3. Cost tracking:
   - Today: $2.15 (vs $2.50 static)
   - This month: $58 (vs $60 static)
   - Savings: 3%

4. Scaling events (last 24h):
   - Scaled UP: 5 times
   - Scaled DOWN: 3 times
```

---

## ✅ Домашнє завдання

1. Налаштувати Docker Compose з 1 lobby (replicas: 1)
2. Написати простий Python script для моніторингу гравців
3. Реалізувати manual scaling (додати/видалити replica)
4. (Bonus) Інтеграція з Pterodactyl API

**Далі: Модуль 4 - Redis messaging для cross-server communication!**',
    4800,
    6,
    false
  );

  RAISE NOTICE 'Module 3, Lesson 6 created!';
END $$;
