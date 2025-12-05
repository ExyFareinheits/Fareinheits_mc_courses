-- =====================================================
-- МОДУЛЬ 1, УРОК 2: Налаштування Vulcan 2.8+ (Production Config)
-- =====================================================
-- Курс: paid-4 (Advanced Anti-Cheat та Security Systems)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 1;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 2;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Налаштування Vulcan 2.8+: від встановлення до production',
    'text',
    '# Vulcan Anti-Cheat 2.8+: Production Setup Guide

## 📦 Встановлення Vulcan

### 1. Купівля та Download

```
Офіційний сайт: https://www.spigotmc.org/resources/vulcan-anti-cheat.83626/

Ціна (2025):
- Lifetime: $25 (одноразово)
- Monthly: $8/міс (підписка)

Рекомендація: Lifetime (окупається за 3 місяці)

Файли:
- Vulcan-2.8.5.jar (основний плагін)
- VulcanAPI-2.8.5.jar (для розробників)
```

### 2. Перевірка Ліцензії

```
⚠️ ВАЖЛИВО: Vulcan має ліцензійну перевірку!

Процес активації:
1. Покупка на SpigotMC
2. Download файлу
3. Перший запуск → автоматична перевірка через SpigotMC API
4. License key прив''''язується до server IP

Ліміти:
- 1 ліцензія = 1 server IP
- Зміна IP: тікет до підтримки (1-2 дні)
- Dev servers: можна використовувати localhost
```

---

## 🛠️ Перший Запуск

### Структура папок:

```
plugins/
├── Vulcan-2.8.5.jar
└── Vulcan/
    ├── config.yml          (основні налаштування)
    ├── checks.yml          (конфіг перевірок)
    ├── messages.yml        (повідомлення)
    ├── violations.yml      (punishment рівні)
    └── logs/
        └── violations.log  (історія порушень)
```

---

## ⚙️ config.yml: Основні Налаштування

```yaml
# Vulcan 2.8.5 Config (2025 Production)

# Основна інформація
server-name: MyServer
license-key: auto  # Автоматично з SpigotMC

# Performance налаштування
performance:
  max-players-per-check: 100      # Скільки гравців одночасно перевіряти
  check-interval: 1               # Tick interval (1 = кожен tick)
  async-processing: true          # Async обробка (рекомендовано)
  thread-pool-size: 4             # Кількість потоків (CPU cores - 2)

# Cloud Features (спільний detection між серверами)
cloud:
  enabled: true                   # Увімкнути cloud sync
  share-violations: true          # Ділитися violations
  auto-update-checks: true        # Автооновлення check signatures
  api-key: ''your-api-key''         # З dashboard

# Alerts
alerts:
  enabled: true
  min-vl: 20                      # Мінімальний VL для alert (20 = 4 порушення)
  sound: true                     # Звук для staff
  title: true                     # Title alert
  
  # Permission для alerts
  permission: vulcan.alerts

# Webhooks (Discord/Telegram)
webhooks:
  discord:
    enabled: true
    url: https://discord.com/api/webhooks/...
    min-vl: 50                    # VL для webhook (серйозні порушення)
    embed-color: #ff0000
  
  telegram:
    enabled: false
    bot-token: YOUR_BOT_TOKEN
    chat-id: -1001234567890

# Punishment система
punishments:
  enabled: true
  mode: wave                    # instant або wave
  wave-interval: 4320             # 3 дні (minutes)
  
  commands:
    50: kick %player% Vulcan Anti-Cheat
    100: tempban %player% 1d Cheating (Vulcan)
    200: ban %player% Cheating (Vulcan)

# Logging
logging:
  enabled: true
  log-to-file: true
  log-to-console: false           # Не спамити console
  max-log-size: 10                # MB
```

---

## 🎯 checks.yml: Detection Checks

### Killaura (Автоматична атака)

```yaml
killaura:
  enabled: true
  
  # Type A: Angle detection (кут атаки)
  a:
    enabled: true
    max-vl: 10                    # VL за violation
    cancel-hit: true              # Скасувати удар
    
    # Поріг кута (градуси)
    max-angle: 35                 # >35° = неможливо без чіту
    
  # Type B: Pattern detection (ML-based)
  b:
    enabled: true
    max-vl: 15
    
    # ML model confidence
    min-confidence: 0.85          # 85%+ впевненість
    
  # Type C: Multi-target detection
  c:
    enabled: true
    max-vl: 20
    
    # Атака 2+ гравців за <100ms
    max-targets: 1
    time-window: 100              # milliseconds
    
  # Type D: Aim smoothness
  d:
    enabled: true
    max-vl: 12
    
    # Людина рухає мишкою плавно, чіт - різко
    smoothness-threshold: 0.3     # Lower = різкіше
    
  # Type E: AutoBlock detection (блок під час атаки)
  e:
    enabled: true
    max-vl: 8
    
  # Type F: Post-dead hit (атака після смерті)
  f:
    enabled: true
    max-vl: 25
    
  # Type G: Rotation (impossible head rotation)
  g:
    enabled: true
    max-vl: 18
    max-rotation-speed: 180       # °/tick
    
  # Type H: Criticals (fake critical hits)
  h:
    enabled: true
    max-vl: 10
```

### Reach (Дистанція атаки)

```yaml
reach:
  enabled: true
  
  # Type A: Basic reach
  a:
    enabled: true
    max-vl: 15
    
    # Максимальна дистанція
    max-reach: 3.1                # Vanilla = 3.0, +0.1 для ping
    
    # Ping compensation
    ping-compensation: true
    max-ping: 300                 # >300ms = ігнорувати
    
  # Type B: Average reach (середня за 10 hits)
  b:
    enabled: true
    max-vl: 20
    
    # Середня дистанція за 10 ударів
    avg-reach: 3.05
    sample-size: 10
    
  # Type C: Movement-based reach
  c:
    enabled: true
    max-vl: 18
    
    # Атака під час руху (складніше)
    moving-max-reach: 3.0
```

### Speed (Швидкість руху)

```yaml
speed:
  enabled: true
  
  # Type A: Ground speed
  a:
    enabled: true
    max-vl: 10
    
    # Максимальна швидкість на землі
    max-speed: 0.36               # blocks/tick (vanilla sprint jump)
    
  # Type B: Air speed
  b:
    enabled: true
    max-vl: 12
    
    max-air-speed: 0.42
    
  # Type C: Potion effects (speed, slowness)
  c:
    enabled: true
    max-vl: 15
    
    # Авто-detection potion multipliers
    auto-calculate: true
    
  # Type D: Vehicle speed (boat, horse)
  d:
    enabled: true
    max-vl: 10
    
  # Type E: Elytra speed
  e:
    enabled: true
    max-vl: 20
    max-elytra-speed: 2.5         # blocks/tick
    
  # Type F: Ice/Slime speed
  f:
    enabled: true
    max-vl: 8
```

### Fly (Політ)

```yaml
fly:
  enabled: true
  
  # Type A: Basic fly (no vertical movement)
  a:
    enabled: true
    max-vl: 25
    
  # Type B: Hover (стоїть в повітрі)
  b:
    enabled: true
    max-vl: 20
    max-hover-time: 10            # ticks
    
  # Type C: Glide (повільне падіння)
  c:
    enabled: true
    max-vl: 15
    min-fall-speed: 0.08          # blocks/tick
    
  # Type D: Jump height
  d:
    enabled: true
    max-vl: 18
    max-jump-height: 1.25         # blocks (vanilla + jump boost)
    
  # Type E: Ground spoof (фейк onGround)
  e:
    enabled: true
    max-vl: 30
```

### Scaffold (Автоматичні блоки)

```yaml
scaffold:
  enabled: true
  
  # Type A: Rotation (не дивиться на блок)
  a:
    enabled: true
    max-vl: 12
    
  # Type B: Speed (швидкість розміщення)
  b:
    enabled: true
    max-vl: 15
    max-place-speed: 10           # blocks/second
    
  # Type C: Tower (вертикальне будування)
  c:
    enabled: true
    max-vl: 10
    
  # Type D: Expand (далеко від гравця)
  d:
    enabled: true
    max-vl: 18
    max-distance: 5.5             # blocks
    
  # Type E: Safewalk (не падати)
  e:
    enabled: true
    max-vl: 8
    
  # Type F: Downwards (вниз під час падіння)
  f:
    enabled: true
    max-vl: 20
```

---

## 🚨 violations.yml: Punishment Levels

```yaml
# VL (Violation Level) система

# Як працює VL:
# - Кожна detection додає VL
# - VL зменшується з часом (decay)
# - При досягненні порогу - punishment

violations:
  # VL Decay (зменшення з часом)
  decay:
    enabled: true
    rate: 0.5                     # -0.5 VL кожні 5 хвилин
    interval: 300                 # seconds
    
  # VL Thresholds
  thresholds:
    # Level 1: Warning
    10:
      type: ''alert''
      message: ''&c[Vulcan] &7%player% might be cheating (VL: %vl%)''
      
    # Level 2: Kick
    50:
      type: ''command''
      command: ''kick %player% &cVulcan Anti-Cheat\\n\\n&7Suspected cheating''
      
    # Level 3: Temp Ban
    100:
      type: ''command''
      command: ''tempban %player% 1d &cCheating (Vulcan VL: %vl%)''
      
    # Level 4: Permanent Ban
    200:
      type: ''command''
      command: ''ban %player% &cCheating\\n\\n&7VL: %vl%\\n&7Check: %check%''
      broadcast: true
      
  # Per-check VL multipliers
  multipliers:
    killaura: 1.5                 # Serious = higher multiplier
    reach: 1.3
    fly: 2.0                      # Very serious
    speed: 1.2
    scaffold: 1.0
    timer: 1.8
```

---

## 🎨 messages.yml: Customization

```yaml
# Alerts для staff

alerts:
  format: &8[&cVulcan&8] &7%player% &cfailed &7%check% &8(&7VL: &c%vl%&8)
  hover: |
    &7Player: &c%player%
    &7Check: &c%check% &8(&7Type %type%&8)
    &7VL: &c%vl%
    &7Ping: &e%ping%ms
    &7TPS: &e%tps%
    &7Client: &e%client%
    
    &7Click to teleport
  
  click-action: teleport
  click-command: /tp %player%

# Команди для staff
commands:
  alerts:
    - /vulcan alerts - toggle alerts
    - /vulcan info <player> - гравець інфо
    - /vulcan logs <player> - історія violations
    - /vulcan resetvl <player> - reset VL
    - /vulcan gui - GUI config editor
```

---

## 🔧 Налаштування для різних типів серверів

### 1.8 PvP Server (Hardcore)

```yaml
# checks.yml modifications

killaura:
  a:
    max-angle: 30                 # Строгіше (1.8 = жорсткий PvP)
  d:
    smoothness-threshold: 0.25    # Детектувати навіть м''''які чіти

reach:
  a:
    max-reach: 3.05               # 1.8 має менший reach
    ping-compensation: true
    max-ping: 250

speed:
  a:
    max-speed: 0.34               # 1.8 sprint jump

# violations.yml
violations:
  decay:
    rate: 0.3                     # Повільніший decay (жорсткіше)
  
  thresholds:
    30: kick                      # Швидший kick
    80: tempban 3d
    150: ban
```

### Survival/SMP Server (Casual)

```yaml
# checks.yml modifications

killaura:
  a:
    max-angle: 40                 # М''''якше (не PvP фокус)

reach:
  a:
    max-reach: 3.15               # +0.15 для lag compensation
    max-ping: 350

speed:
  c:
    auto-calculate: true          # Potions важливі для PvE

# violations.yml
violations:
  decay:
    rate: 0.7                     # Швидший decay
  
  thresholds:
    50: kick
    120: tempban 1d
    250: ban
```

### Mini-games Network (BedWars, SkyWars)

```yaml
# checks.yml modifications

scaffold:
  b:
    max-place-speed: 12           # BedWars = швидке будування
  d:
    max-distance: 6.0             # Дозволити довші bridge

fly:
  d:
    max-jump-height: 1.35         # Jump boost часто

# violations.yml
violations:
  wave-punishment: true           # Ban waves (не одразу)
  wave-interval: 10080            # 1 тиждень
```

---

## 📊 Моніторинг та Статистика

### /vulcan info <player>

```
/vulcan info Player123

Output:
╔══════════════════════════════════════╗
║  Vulcan Info: Player123              ║
╠══════════════════════════════════════╣
║  Total VL: 45                        ║
║  Killaura VL: 25                     ║
║  Reach VL: 15                        ║
║  Speed VL: 5                         ║
║                                      ║
║  Violations (Last 24h): 12           ║
║  First Seen: 2025-01-15 14:23        ║
║  Play Time: 3h 45m                   ║
║                                      ║
║  Client: Vanilla (probably)          ║
║  Version: 1.20.4                     ║
║  Ping: 85ms                          ║
╚══════════════════════════════════════╝
```

### /vulcan logs <player>

```
/vulcan logs Player123 10

Last 10 violations:
[14:23:45] Killaura (Type A) - VL +10 → 45
[14:22:12] Reach (Type A) - VL +5 → 35
[14:20:33] Killaura (Type D) - VL +12 → 30
...
```

### /vulcan top

```
Top 10 Cheaters (by VL):

1. Player123 - VL 145 (Killaura, Reach)
2. Hacker456 - VL 132 (Fly, Speed)
3. Cheater789 - VL 98 (Scaffold)
...
```

---

## 🚀 Production Checklist

```
□ Ліцензія активована (SpigotMC)
□ config.yml налаштований (performance)
□ checks.yml tuned для вашого типу сервера
□ violations.yml punishment levels встановлені
□ Webhooks налаштовані (Discord/Telegram)
□ Cloud features увімкнені
□ Staff має permission vulcan.alerts
□ Протестовано на test server (1-2 дні)
□ False positives перевірені
□ Backup конфігів зроблено
```

---

## ⚠️ Типові Помилки

### 1. Забагато False Positives

**Причина:** Дефолтні пороги занадто строгі

**Рішення:**
```yaml
# Підняти thresholds
killaura:
  a:
    max-angle: 35 → 40
    
reach:
  a:
    max-reach: 3.1 → 3.15
```

### 2. Lag спайки при перевірках

**Причина:** Занадто багато гравців одночасно

**Рішення:**
```yaml
performance:
  max-players-per-check: 100 → 50
  thread-pool-size: 4 → 6
```

### 3. Webhooks не працюють

**Причина:** Некоректний URL або firewall

**Рішення:**
```
1. Перевірити URL в Discord
2. Test: curl -X POST <webhook-url>
3. Перевірити firewall rules (allow outbound 443)
```

---

**Вітаю! Vulcan налаштовано! 🎉**

**Наступний модуль:** Як працюють чіти (kernel-mode, drivers, bypass)'
,
    6000,
    2,
    false
  );

  RAISE NOTICE 'Module 1, Lesson 2 created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-4' AND m.order_index = 1
ORDER BY l.order_index;
