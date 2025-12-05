-- =====================================================
-- МОДУЛЬ 2, УРОК 3: Network топології та архітектури
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  -- Перевіряємо чи існує модуль 2
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-3' AND order_index = 2;
  
  -- Якщо не існує - створюємо
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-3',
      'module-2',
      'Network Топології',
      'Різні архітектури мереж, IP forwarding, forced hosts, масштабування',
      2
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 3;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_lesson_id,
    'Network топології: Hub-Spoke, Mesh, Hybrid',
    'text',
    '# Network топології: як правильно організувати сервера?

## 🎯 Що таке Network Topology?

**Топологія** = структура зв''язків між серверами у мережі

```
Приклад життя:
🏢 Офіс компанії:
   - Reception (вхід) → розподіляє відвідувачів
   - Departments (відділи) → робоча зона

🎮 Minecraft Network:
   - Lobby (вхід) → розподіляє гравців
   - Game servers (ігри) → геймплей
```

---

## 📐 Топологія #1: Hub-Spoke (найпопулярніша)

### Концепція:

```
Hub = центральний сервер (Lobby)
Spokes = периферійні сервери (Games)

Діаграма:
              ┌───────────┐
              │   LOBBY   │ ← HUB (центр)
              │  (hub)    │
              └─────┬─────┘
        ┌──────┬────┴────┬──────┐
        │      │         │      │
   ┌────▼──┐ ┌─▼────┐ ┌──▼───┐ ┌▼─────┐
   │ SkyWars│ │Survival│ │BedWars│ │Creative│ ← SPOKES
   └────────┘ └──────┘ └──────┘ └──────┘

Гравці:
Players → Lobby → обирають гру → переходять на spoke
```

### Переваги Hub-Spoke:

```
✅ Простота:
   - Легко зрозуміти
   - Один entry point
   - Централізоване управління

✅ Гнучкість:
   - Додати spoke = 1 рядок у конфігу
   - Видалити spoke = видалити з конфігу
   - Не впливає на інші spokes

✅ Масштабованість:
   - Можна мати 100+ spokes
   - Hub розподіляє навантаження
   
✅ Maintenance:
   - Рестарт spoke → гравці у hub
   - Рестарт hub → швидкий reconnect
```

### Недоліки Hub-Spoke:

```
❌ Single Point of Failure:
   Hub падає → ВСЯ мережа недоступна
   
❌ Hub = bottleneck:
   Всі переходи через hub
   Hub перевантажений → лаги
   
❌ Латентність:
   Spoke1 → Spoke2 = Spoke1 → Hub → Spoke2
   +1 hop (+латентність)
```

### Конфігурація Velocity:

```toml
[servers]
  # HUB
  lobby = "10.0.1.10:30066"
  
  # SPOKES (games)
  skywars = "10.0.1.20:30067"
  survival = "10.0.1.30:30068"
  bedwars = "10.0.1.40:30069"
  creative = "10.0.1.50:30070"
  
  # Try order: завжди hub першим!
  try = ["lobby"]
```

### Коли використовувати Hub-Spoke:

```
✅ Стандартна Minigames мережа
✅ SkyBlock/Prison сервери з lobby
✅ Невеликі/середні мережі (2-50 серверів)
✅ Коли треба централізоване управління
✅ Новачкам (найпростіша топологія)

❌ Величезні мережі (1000+ гравців)
❌ Коли Hub = bottleneck
❌ Коли потрібна надзвичайна відмовостійкість
```

---

## 🕸️ Топологія #2: Full Mesh (повне з''єднання)

### Концепція:

```
Mesh = кожен сервер з''єднаний з кожним

Діаграма:
    ┌─────────┐
    │ Survival│──┐
    └────┬────┘  │
         │    ┌──▼──────┐
    ┌────▼──┐ │ Creative│
    │ Lobby │─┤         │
    └───┬───┘ └────┬────┘
        │          │
        └──────┬───┘
          ┌────▼────┐
          │ SkyBlock│
          └─────────┘

Всі з''єднані з усіма!
```

### Переваги Mesh:

```
✅ Відмовостійкість:
   - Немає single point of failure
   - Будь-який сервер падає → інші працюють
   
✅ Прямі переходи:
   - Survival → SkyBlock (прямо)
   - Немає проміжного hub
   - Мінімальна латентність
   
✅ Load distribution:
   - Немає bottleneck
   - Навантаження розподілене
```

### Недоліки Mesh:

```
❌ Складність:
   - N серверів = N×(N-1)/2 з''єднань
   - 10 серверів = 45 connections!
   - Важко налаштовувати
   
❌ Масштабованість:
   - Додати сервер = оновити ВСІ конфіги
   - 100 серверів = 4950 connections
   - Непрактично для великих мереж
   
❌ Плутанина:
   - Гравці можуть йти куди завгодно
   - Важко контролювати flow
```

### Конфігурація Velocity (Mesh):

```toml
# На кожному backend потрібен окремий proxy!

# Proxy для Survival:
[servers]
  survival = "127.0.0.1:30066"
  lobby = "10.0.1.10:30067"
  creative = "10.0.1.20:30068"
  skyblock = "10.0.1.30:30069"
  try = ["survival"]

# Proxy для Lobby:
[servers]
  lobby = "127.0.0.1:30067"
  survival = "10.0.1.15:30066"
  creative = "10.0.1.20:30068"
  skyblock = "10.0.1.30:30069"
  try = ["lobby"]

# І так для кожного!
```

### Коли використовувати Mesh:

```
✅ Критична відмовостійкість (банки, enterprise)
✅ Дуже мала мережа (2-5 серверів)
✅ Прямі переходи обов''язкові
✅ Латентність критична

❌ Стандартні Minecraft мережі (overkill)
❌ Більше 10 серверів (занадто складно)
❌ Команда новачків (важко підтримувати)
```

---

## 🔀 Топологія #3: Hybrid (Hub-Spoke + Mesh)

### Концепція:

```
Комбінація Hub-Spoke та Mesh:
- Lobby = hub (entry point)
- Games = spokes
- Деякі games з''єднані напряму (mesh)

Діаграма:
              ┌───────────┐
              │   LOBBY   │
              │  (hub)    │
              └─────┬─────┘
        ┌──────┬────┴────┬──────┐
        │      │         │      │
   ┌────▼──┐ ┌─▼────┐ ┌──▼───┐ ┌▼─────┐
   │ Sky-  │ │ Sur-  │ │ Bed-  │ │ Crea-│
   │ Wars  │─│ vival │─│ Wars  │ │ tive │
   └───────┘ └───────┘ └───────┘ └──────┘
       ↑─────────┘

SkyWars ↔ Survival = прямий зв''язок (mesh)
Lobby → все = hub-spoke
```

### Переваги Hybrid:

```
✅ Найкраще з обох світів:
   - Простота hub-spoke для більшості
   - Швидкість mesh для критичних пар
   
✅ Оптимізація:
   - Часті переходи (Survival ↔ Nether) = mesh
   - Рідкі переходи (Lobby → Creative) = spoke
   
✅ Гнучкість:
   - Можна додавати mesh зв''язки поступово
   - Не перебудовувати всю мережу
```

### Реальний приклад: SMP Network

```
Структура:
┌────────┐
│ LOBBY  │ ← entry point (hub)
└───┬────┘
    ├─→ Survival (spoke)
    │    ├─→ Survival Nether (mesh link)
    │    └─→ Survival End (mesh link)
    │
    ├─→ Creative (spoke)
    ├─→ Resource World (spoke)
    │    └─→ Survival (mesh link) ← прямий доступ!
    │
    └─→ Event Server (spoke)

Чому так?
Survival ↔ Nether ↔ End = часті переходи → mesh
Survival ↔ Resource = щоденний фарм → mesh
Lobby → Creative = рідкісні → spoke (through hub)
```

### Конфігурація Velocity (Hybrid):

```toml
# Main Velocity (entry point):
[servers]
  lobby = "10.0.1.10:30066"
  survival = "10.0.1.20:30067"
  creative = "10.0.1.30:30068"
  resource = "10.0.1.40:30069"
  event = "10.0.1.50:30070"
  try = ["lobby"]

# Survival сервер також має Velocity plugin:
# (для mesh links)
# Plugin обробляє: /world nether, /world end, /resource
```

### Коли використовувати Hybrid:

```
✅ SMP/Survival сервери з world teleports
✅ Великі мережі (50+ серверів)
✅ Є bottleneck у конкретних місцях
✅ Потрібна оптимізація певних переходів

✅ Наш випадок: найкраще для більшості!
```

---

## 📊 Порівняльна таблиця топологій

| Параметр | Hub-Spoke | Full Mesh | Hybrid |
|----------|-----------|-----------|--------|
| **Складність** | 🟢 Легко | 🔴 Складно | 🟡 Середньо |
| **Масштабованість** | 🟢 Чудово | 🔴 Погано | 🟢 Відмінно |
| **Латентність** | 🟡 +1 hop | 🟢 Мінімум | 🟢 Оптимізовано |
| **Відмовостійкість** | 🔴 SPOF (hub) | 🟢 Максимум | 🟡 Добре |
| **Maintenance** | 🟢 Просто | 🔴 Важко | 🟡 Нормально |
| **Для новачків** | 🟢 Так | 🔴 Ні | 🟡 З досвідом |
| **<10 серверів** | 🟢 Ідеально | 🟡 Можливо | 🟡 Overkill |
| **10-50 серверів** | 🟢 Відмінно | 🔴 Ні | 🟢 Чудово |
| **50+ серверів** | 🟡 Можливо | 🔴 Неможливо | 🟢 Ідеально |

**Висновок:**
- **Початківці:** Hub-Spoke
- **<10 серверів:** Hub-Spoke
- **SMP/World groups:** Hybrid
- **50+ серверів:** Hybrid
- **Enterprise:** Full Mesh (рідко для Minecraft)

---

## 🛠️ Практика: Налаштування топології

### Scenario 1: Minigames Network (Hub-Spoke)

```toml
# velocity.toml
[servers]
  # Hub
  lobby = "10.0.1.10:30066"
  
  # Spokes (PvP games)
  skywars-1 = "10.0.1.20:30067"
  skywars-2 = "10.0.1.21:30067"
  bedwars-1 = "10.0.1.30:30068"
  bedwars-2 = "10.0.1.31:30068"
  duels = "10.0.1.40:30069"
  
  # Spoke (Survival)
  survival = "10.0.1.50:30070"
  
  try = ["lobby"]

# Переходи:
# Player → Lobby → вибирає гру → Spoke
# Player на Spoke → /lobby → Hub
```

### Scenario 2: SMP Network (Hybrid)

```toml
# velocity.toml (main proxy)
[servers]
  lobby = "10.0.1.10:30066"
  survival = "10.0.1.20:30067"
  creative = "10.0.1.30:30068"
  try = ["lobby"]

# Survival сервер має плагін для mesh:
# - /world nether (прямий портал)
# - /world end (прямий портал)
# - /spawn (через proxy → lobby)

# На Survival backend:
# config.yml (custom plugin):
mesh_connections:
  nether: "10.0.1.20:30068"
  end: "10.0.1.20:30069"
proxy_connection:
  lobby: "через Velocity"
```

### Scenario 3: Multi-Region Network

```
Проблема: гравці з EU + US

Топологія:
         ┌──────────────┐
         │ Global Proxy │ (entry: play.server.com)
         └───────┬──────┘
         ┌───────┴────────┐
         │                │
   ┌─────▼─────┐    ┌────▼──────┐
   │  EU Proxy │    │  US Proxy │
   │(Amsterdam)│    │(New York) │
   └─────┬─────┘    └────┬──────┘
         │               │
    ┌────┴───┐      ┌────┴───┐
   EU       EU      US      US
  Lobby   Survival Lobby  Survival

Forwarding:
- EU гравці → EU proxy → EU servers (low ping)
- US гравці → US proxy → US servers (low ping)
```

**Конфігурація:**

```toml
# Global Proxy (load balancer):
[servers]
  eu-proxy = "eu.server.com:25565"
  us-proxy = "us.server.com:25565"

[forced-hosts]
  "eu.server.com" = ["eu-proxy"]
  "us.server.com" = ["us-proxy"]

# EU Proxy:
[servers]
  eu-lobby = "10.0.1.10:30066"
  eu-survival = "10.0.1.20:30067"
  try = ["eu-lobby"]

# US Proxy:
[servers]
  us-lobby = "10.0.2.10:30066"
  us-survival = "10.0.2.20:30067"
  try = ["us-lobby"]
```

---

## 🎯 Вибір топології: Decision Tree

```
START
│
├─ У вас <5 серверів?
│  └─ YES → Hub-Spoke (найпростіше)
│
├─ У вас SMP з world groups?
│  └─ YES → Hybrid
│      ├─ Lobby = hub
│      └─ Worlds = mesh links
│
├─ У вас 50+ серверів?
│  └─ YES → Hybrid
│      ├─ Lobby = hub
│      └─ Popular pairs = mesh
│
├─ Потрібна максимальна відмовостійкість?
│  └─ YES → Full Mesh
│      └─ (рідко для Minecraft)
│
└─ Інше → Hub-Spoke (золота середина)
```

---

## 🔥 Поширені помилки

### Помилка #1: Mesh для всього

```
❌ Погано:
10 серверів → 45 connections
Додати 11-й → оновити 10 конфігів

✅ Добре:
Hub-Spoke + mesh тільки для часових переходів
Survival ↔ Nether = mesh
Lobby → Creative = spoke
```

### Помилка #2: Один величезний Hub

```
❌ Погано:
Lobby 1 сервер → bottleneck
500 гравців проходять через нього

✅ Добре:
Lobby Group (3 сервери) + load balancer
lobby-1, lobby-2, lobby-3
Velocity розподіляє автоматично
```

### Помилка #3: Забули про latency

```
❌ Погано:
EU гравці → US proxy → EU server
Ping: +100ms (proxy overhead)

✅ Добре:
EU гравці → EU proxy → EU server
Ping: +5ms (локально)
```

---

## 📚 Наступні кроки

### Модуль 2 продовжується:

```
✅ Lesson 3: Топології (завершено)

→ Lesson 4: IP Forwarding та Forced Hosts
   - Subdomains → різні сервера
   - GeyserMC (Bedrock гравці)
   - IP whitelist
```

### Модуль 3: Load Balancing

```
- Автоматичний розподіл гравців
- Lobby groups (5 lobby серверів)
- Game balancers (10 SkyWars серверів)
```

---

## ✅ Домашнє завдання

1. **Визначити вашу топологію**
   - Скільки серверів?
   - Які переходи найчастіші?
   - Обрати: Hub-Spoke / Hybrid

2. **Намалювати діаграму**
   - Використати draw.io або папір
   - Показати всі сервера
   - Показати зв''язки
   - Визначити hub vs spokes

3. **Оцінити bottlenecks**
   - Де можуть бути проблеми?
   - Чи Hub витримає навантаження?
   - Які переходи найповільніші?

4. **Розрахувати connections**
   - Hub-Spoke: N-1 connections
   - Full Mesh: N×(N-1)/2
   - Ваш випадок: ?

5. **Підготуватись до наступного уроку**
   - Придумати subdomains (eu.server.com, us.server.com)
   - Планувати forced hosts

---

**Вітаю! Ви розумієте network топології! 🎉**

**Головне:**
- Hub-Spoke = стандарт (простота + масштабованість)
- Full Mesh = рідко (складно, але надійно)
- Hybrid = оптимально (найкраще з обох)

**Правило:** Почніть з Hub-Spoke → додайте mesh де потрібно!

**Далі:** IP forwarding та advanced routing!',
    5400,
    3,
    false
  );

  RAISE NOTICE 'Module 2, Lesson 3 created!';
END $$;
