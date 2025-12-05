-- =====================================================
-- МОДУЛЬ 3, УРОК 5: Load Balancing стратегії
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  -- Перевіряємо чи існує модуль 3
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-3' AND order_index = 3;
  
  -- Якщо не існує - створюємо
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-3',
      'module-3',
      'Load Balancing',
      'Автоматичний розподіл гравців, балансування навантаження, динамічні групи серверів',
      3
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 5;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_lesson_id,
    'Load Balancing: Round Robin, Least Connection, Priority',
    'text',
    '# Load Balancing: розумний розподіл гравців

## 🎯 Навіщо Load Balancing?

### Проблема: один lobby сервер

```
Мережа:
Velocity → Lobby (1 сервер)
         ↓
         100 гравців

Проблеми:
❌ TPS падає (19 → 15 → 10)
❌ Лагає для всіх
❌ Краш = всі у disconnect
❌ Не можна горизонтально масштабувати
```

### Рішення: Load Balancer

```
Velocity → Lobby Group (3 сервери)
         ├─ Lobby-1 (33 гравці)
         ├─ Lobby-2 (34 гравці)
         └─ Lobby-3 (33 гравці)

Переваги:
✅ Навантаження розподілене (TPS 19.8 на всіх)
✅ Краш одного = інші працюють
✅ Можна додати Lobby-4, Lobby-5...
✅ Масштабування до нескінченності
```

---

## 📊 Алгоритми Load Balancing

### 1. Round Robin (по черзі)

**Як працює:**
```
Player1 → Lobby-1
Player2 → Lobby-2
Player3 → Lobby-3
Player4 → Lobby-1 (знову)
Player5 → Lobby-2
...

Просто чергуємо сервера циклічно!
```

**Переваги:**
```
✅ Найпростіший алгоритм
✅ Рівномірний розподіл (якщо всі рівні)
✅ Низьке CPU навантаження на proxy
✅ Передбачуваний
```

**Недоліки:**
```
❌ Не враховує реальне навантаження
❌ Якщо Lobby-1 лагає (TPS 12) → все одно шле туди
❌ Не враховує кількість гравців на сервері
```

**Velocity конфіг:**
```toml
[servers]
  # Група lobby серверів:
  lobby-1 = "10.0.1.10:30066"
  lobby-2 = "10.0.1.11:30066"
  lobby-3 = "10.0.1.12:30066"
  
  # Try list (порядок = round robin):
  try = [
    "lobby-1",
    "lobby-2",
    "lobby-3"
  ]
```

**Коли використовувати:**
```
✅ Всі сервера однакової потужності
✅ Передбачуване навантаження
✅ Простота важливіша за оптимізацію
✅ Мала мережа (2-5 серверів)
```

---

### 2. Least Connection (найменше гравців)

**Як працює:**
```
Стан:
Lobby-1: 45 гравців
Lobby-2: 38 гравців ← найменше!
Lobby-3: 42 гравці

Новий гравець → Lobby-2 (найменше гравців)

Після підключення:
Lobby-1: 45
Lobby-2: 39 ← тепер тут більше
Lobby-3: 42

Наступний гравець → Lobby-2 (все ще найменше)
```

**Переваги:**
```
✅ Враховує реальну кількість гравців
✅ Автоматичне балансування
✅ Якщо сервер перевантажений → не шле туди
✅ Ідеально для динамічного навантаження
```

**Недоліки:**
```
❌ Більше CPU на proxy (треба рахувати)
❌ Не враховує TPS (може бути 50 гравців але TPS 19)
❌ Потрібен плагін (нема нативно у Velocity)
```

**Плагін: LuckPerms + API:**

```java
// Velocity plugin (pseudo-code):
@Subscribe
public void onServerPreConnect(ServerPreConnectEvent event) {
    // Отримуємо всі lobby сервера:
    List<RegisteredServer> lobbies = proxy.getAllServers().stream()
        .filter(s -> s.getServerInfo().getName().startsWith("lobby-"))
        .collect(Collectors.toList());
    
    // Знаходимо з найменшою кількістю гравців:
    RegisteredServer leastConnected = lobbies.stream()
        .min(Comparator.comparing(s -> s.getPlayersConnected().size()))
        .orElse(null);
    
    // Redirect:
    event.setResult(ServerPreConnectEvent.ServerResult.allowed(leastConnected));
}
```

**Коли використовувати:**
```
✅ Динамічне навантаження (peak hours)
✅ Гравці приходять/виходять часто
✅ Різні потужності серверів
✅ Середні/великі мережі (5-50 серверів)
```

---

### 3. Weighted Round Robin (з вагами)

**Як працює:**
```
Сервера з вагами:
Lobby-1: вага 3 (потужний VPS)
Lobby-2: вага 2 (середній VPS)
Lobby-3: вага 1 (слабкий VPS)

Розподіл:
Player1 → Lobby-1
Player2 → Lobby-1
Player3 → Lobby-1  (3 рази для ваги 3)
Player4 → Lobby-2
Player5 → Lobby-2  (2 рази для ваги 2)
Player6 → Lobby-3  (1 раз для ваги 1)
Player7 → Lobby-1  (цикл заново)
```

**Переваги:**
```
✅ Враховує різну потужність серверів
✅ Потужніші отримують більше гравців
✅ Простіше за Least Connection
✅ Передбачувано
```

**Конфігурація (плагін):**

```yaml
# LoadBalancer plugin config:
servers:
  lobby-1:
    address: "10.0.1.10:30066"
    weight: 3
  lobby-2:
    address: "10.0.1.11:30066"
    weight: 2
  lobby-3:
    address: "10.0.1.12:30066"
    weight: 1

algorithm: "weighted-round-robin"
```

**Коли використовувати:**
```
✅ Різні потужності серверів (cheap + expensive VPS)
✅ Один сервер local (low latency) + remote
✅ Тестовий сервер (вага 1) + production (вага 5)
```

---

### 4. Priority-based (пріоритети)

**Як працює:**
```
Пріоритети:
Lobby-1: Priority 1 (highest)
Lobby-2: Priority 2
Lobby-3: Priority 3 (lowest)

Логіка:
1. Спроба підключити до Lobby-1
2. Якщо повний/офлайн → Lobby-2
3. Якщо Lobby-2 недоступний → Lobby-3
```

**Переваги:**
```
✅ Завжди намагається використати найкращий
✅ Fallback якщо недоступний
✅ Можна designate "main" сервер
```

**Недоліки:**
```
❌ Весь traffic на один сервер (якщо доступний)
❌ НЕ розподіляє навантаження
❌ Інші сервера простоюють
```

**Velocity нативно:**
```toml
[servers]
  lobby-primary = "10.0.1.10:30066"
  lobby-backup-1 = "10.0.1.11:30066"
  lobby-backup-2 = "10.0.1.12:30066"
  
  try = [
    "lobby-primary",    # Спочатку тут
    "lobby-backup-1",  # Якщо primary down
    "lobby-backup-2"   # Останній резерв
  ]
```

**Коли використовувати:**
```
✅ Один потужний + резервні (HA setup)
✅ Maintenance (primary down → backup)
❌ НЕ для load balancing (для failover!)
```

---

### 5. Latency-based (за пінгом)

**Як працює:**
```
Гравець з EU:
Ping to EU server: 15ms ← вибираємо
Ping to US server: 120ms

Гравець з US:
Ping to EU server: 115ms
Ping to US server: 20ms ← вибираємо
```

**Переваги:**
```
✅ Мінімальна латентність для гравців
✅ EU → EU, US → US автоматично
✅ Краще UX
```

**Плагін (з GeoIP):**

```java
// Velocity plugin:
@Subscribe
public void onServerPreConnect(ServerPreConnectEvent event) {
    Player player = event.getPlayer();
    InetAddress ip = player.getRemoteAddress().getAddress();
    
    // GeoIP lookup:
    String country = geoIP.getCountry(ip);
    
    // Route за регіоном:
    if (country.equals("US") || country.equals("CA")) {
        event.setResult(...usLobby);
    } else {
        event.setResult(...euLobby);
    }
}
```

**Коли використовувати:**
```
✅ Multi-region network (EU + US + Asia)
✅ Latency критична (PvP сервер)
✅ Великий бюджет (VPS у кожному регіоні)
```

---

## 🎮 Популярні Load Balancer плагіни

### 1. **LilyPad Connect** (BungeeCord)

```
Features:
✅ Dynamic server groups
✅ Least connection algorithm
✅ Auto-scaling (create servers on demand)
✅ Redis integration

Cons:
❌ Тільки BungeeCord
❌ Складне налаштування
```

### 2. **Velocity Load Balancer**

```
GitHub: github.com/example/VelocityLoadBalancer

Features:
✅ Multiple algorithms (Round Robin, Least, Weighted)
✅ Health checks (ping servers)
✅ Config reload без restart
✅ Metrics (Prometheus)

Install:
wget https://github.com/.../VelocityLoadBalancer.jar
→ velocity/plugins/
```

**Конфіг:**

```yaml
# VelocityLoadBalancer/config.yml
groups:
  lobby:
    algorithm: "least-connection"
    servers:
      - "lobby-1"
      - "lobby-2"
      - "lobby-3"
    health-check:
      enabled: true
      interval: 5  # seconds
      timeout: 2
  
  skywars:
    algorithm: "round-robin"
    servers:
      - "skywars-1"
      - "skywars-2"
      - "skywars-3"
```

### 3. **Custom плагін (Java API)**

```java
// Власний плагін:
@Plugin(id = "custombalancer", name = "Custom Load Balancer")
public class CustomBalancer {
    
    @Subscribe
    public void onPreConnect(ServerPreConnectEvent event) {
        Optional<RegisteredServer> target = event.getOriginalServer();
        
        // Якщо це lobby група:
        if (target.isPresent() && isLobbyGroup(target.get())) {
            RegisteredServer best = findBestLobby();
            event.setResult(ServerPreConnectEvent.ServerResult.allowed(best));
        }
    }
    
    private RegisteredServer findBestLobby() {
        // Ваша логіка:
        // - Least connection
        // - Check TPS via plugin messaging
        // - Check RAM via API
        // - GeoIP routing
        return bestServer;
    }
}
```

---

## 📈 Моніторинг Load Balancing

### Metrics для відстеження:

```
1. Розподіл гравців:
   - lobby-1: 35 players (33%)
   - lobby-2: 34 players (32%)
   - lobby-3: 36 players (35%)
   → Добре! Рівномірно!

2. TPS кожного сервера:
   - lobby-1: TPS 19.8
   - lobby-2: TPS 19.7
   - lobby-3: TPS 19.9
   → Відмінно!

3. CPU usage:
   - lobby-1: 45%
   - lobby-2: 48%
   - lobby-3: 44%
   → Збалансовано!

4. Connection time:
   - Average: 120ms
   - P95: 250ms
   - P99: 450ms
```

### Grafana Dashboard:

```
Panel 1: Players per server (real-time)
[Bar chart]
lobby-1: ████████████████████ 35
lobby-2: ███████████████████ 34
lobby-3: █████████████████████ 36

Panel 2: TPS (line chart)
[Shows all 3 lobbies trending ~19.8]

Panel 3: Connection distribution (pie chart)
lobby-1: 33%
lobby-2: 32%
lobby-3: 35%

Panel 4: Failed connections
Total: 2 (last 1h)
Reasons:
- Server full: 1
- Timeout: 1
```

---

## 🔧 Налаштування: Production setup

### Конфігурація з Least Connection:

```toml
# velocity.toml
[servers]
  lobby-1 = "10.0.1.10:30066"
  lobby-2 = "10.0.1.11:30066"
  lobby-3 = "10.0.1.12:30066"
  
  skywars-1 = "10.0.1.20:30067"
  skywars-2 = "10.0.1.21:30067"
  
  survival = "10.0.1.30:30068"
  
  try = ["lobby-1"]  # fallback

# VelocityLoadBalancer plugin config:
groups:
  lobby:
    algorithm: "least-connection"
    servers: ["lobby-1", "lobby-2", "lobby-3"]
    max-players-per-server: 100
    
  skywars:
    algorithm: "round-robin"
    servers: ["skywars-1", "skywars-2"]
    max-players-per-server: 12  # per game
```

### Health Checks:

```yaml
health-check:
  enabled: true
  interval: 10  # ping кожні 10 сек
  timeout: 3
  max-failures: 3  # 3 fails → mark offline
  
  actions:
    on-failure:
      - "alert-discord"  # webhook
      - "remove-from-rotation"
    
    on-recovery:
      - "add-to-rotation"
      - "log-event"
```

---

## 🎯 Best Practices

```
✅ Використовуйте health checks (видаляйте dead servers)
✅ Моніторте розподіл (має бути ~рівномірно)
✅ Least Connection для dynamic навантаження
✅ Round Robin для predictable навантаження
✅ Weighted якщо різні потужності серверів
✅ Latency-based для multi-region

❌ НЕ змішуйте різні game types у одну группу
   (lobby + skywars = погано)
❌ НЕ забувайте про max-players-per-server
❌ НЕ використовуйте Priority для load balancing
   (тільки для failover!)
```

---

## ✅ Домашнє завдання

1. **Налаштувати 3 lobby сервера**
2. **Встановити VelocityLoadBalancer plugin**
3. **Конфіг: Least Connection algorithm**
4. **Тест: 10 гравців підключаються → перевірити розподіл**
5. **Симуляція: вимкнути lobby-2 → перевірити failover**

---

**Далі: Dynamic Load Balancing (auto-scaling)!**',
    5400,
    5,
    false
  );

  RAISE NOTICE 'Module 3, Lesson 5 created!';
END $$;
