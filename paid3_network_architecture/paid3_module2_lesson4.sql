-- =====================================================
-- МОДУЛЬ 2, УРОК 4: IP Forwarding та Forced Hosts
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  -- Отримуємо ID модуля 2
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-3' AND order_index = 2;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 4;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_lesson_id,
    'IP Forwarding та Forced Hosts: subdomains і routing',
    'text',
    '# IP Forwarding та Forced Hosts: advanced routing

## 🎯 Що таке IP Forwarding?

### Проблема без forwarding:

```
Гравець підключається:
Player → Velocity (IP: 1.2.3.4) → Paper (IP: 127.0.0.1)

Paper бачить:
Connection from: 127.0.0.1 ← це Velocity, НЕ гравець!

Проблеми:
❌ IP бани не працюють (всі = 127.0.0.1)
❌ GeoIP плагіни ламаються
❌ Antiчит не розпізнає VPN
❌ Логи показують 127.0.0.1 для всіх
```

### Рішення: IP Forwarding

```
Velocity передає СПРАВЖНІЙ IP гравця:
Player (1.2.3.4) → Velocity → Paper

Paper тепер бачить:
Connection from: 1.2.3.4 ← справжній IP гравця!

Працює:
✅ IP бани
✅ GeoIP (країна гравця)
✅ Antiчит VPN detection
✅ Правильні логи
```

---

## 🔐 Методи IP Forwarding

### 1. Legacy (BungeeCord format)

**Що це:**
- Старий формат BungeeCord
- Текстовий протокол
- Легко підробити (небезпечно!)

**Конфігурація:**

```toml
# velocity.toml
player-info-forwarding-mode = "legacy"

# Paper (spigot.yml):
bungeecord: true
```

**Коли використовувати:**

```
✅ Legacy плагіни (вимагають BungeeCord)
✅ Старі Paper versions (<1.13)
✅ Сумісність з BungeeCord мережею

❌ Нові проекти (НЕБЕЗПЕЧНО!)
❌ Security критична
```

### 2. Modern (Velocity format)

**Що це:**
- Сучасний формат Velocity
- Криптографічний secret
- Неможливо підробити

**Конфігурація:**

```toml
# velocity.toml
player-info-forwarding-mode = "modern"
forwarding-secret = "генерується_автоматично"

# Paper (config/paper-global.yml):
proxies:
  velocity:
    enabled: true
    online-mode: true
    secret: "СКОПІЮВАТИ_З_velocity/forwarding.secret"
```

**Переваги modern:**

```
✅ Криптографічно безпечний
✅ Неможливо підробити (потрібен secret)
✅ Швидше за legacy
✅ Підтримка Paper 1.13+
✅ Рекомендовано 2024+
```

### 3. BungeeGuard (додатковий захист для legacy)

**Що це:**
- Плагін для захисту legacy forwarding
- Додає token authentication

**Установка:**

```bash
# На Velocity:
wget https://github.com/lucko/BungeeGuard/releases/download/v1.2/BungeeGuard-Velocity.jar -O plugins/BungeeGuard.jar

# На Paper:
wget https://github.com/lucko/BungeeGuard/releases/download/v1.2/BungeeGuard-Bukkit.jar -O plugins/BungeeGuard.jar

# Конфіг (BungeeGuard/config.yml):
token: "ваш_секретний_токен_тут"

# Синхронізуйте token між Velocity та Paper!
```

---

## 🌐 Forced Hosts: Routing за доменами

### Що таке Forced Hosts?

```
Forced Hosts = routing гравців за hostname

Приклад:
Player підключається до: lobby.server.com → Lobby
Player підключається до: survival.server.com → Survival
Player підключається до: creative.server.com → Creative

Один IP (сервер), різні domians → різні сервера!
```

### Налаштування DNS:

```
У DNS провайдера (Cloudflare, Namecheap):

A Record:
lobby.server.com     → 1.2.3.4 (Velocity IP)
survival.server.com  → 1.2.3.4 (Velocity IP)
creative.server.com  → 1.2.3.4 (Velocity IP)

SRV Record (optional, для custom ports):
_minecraft._tcp.lobby.server.com → lobby.server.com:25565

Всі вказують на ОДИН Velocity proxy!
Velocity розбирається який сервер запитували
```

### Конфігурація Velocity:

```toml
# velocity.toml

[servers]
  lobby = "10.0.1.10:30066"
  survival = "10.0.1.20:30067"
  creative = "10.0.1.30:30068"
  try = ["lobby"]  # fallback

# Forced Hosts:
[forced-hosts]
  "lobby.server.com" = ["lobby"]
  "survival.server.com" = ["survival"]
  "creative.server.com" = ["creative"]
  
  # З портом:
  "lobby.server.com:25565" = ["lobby"]
  
  # Multiple backends (load balance):
  "hub.server.com" = ["lobby-1", "lobby-2", "lobby-3"]
```

### Приклад: Multi-region routing

```toml
[servers]
  eu-lobby = "eu-server:30066"
  us-lobby = "us-server:30066"
  asia-lobby = "asia-server:30066"

[forced-hosts]
  "eu.server.com" = ["eu-lobby"]
  "us.server.com" = ["us-lobby"]
  "asia.server.com" = ["asia-lobby"]
  
  # Default (closest):
  "play.server.com" = ["eu-lobby", "us-lobby", "asia-lobby"]
```

### Тестування:

```bash
# У Minecraft клієнті:
Multiplayer → Add Server

Server Address: lobby.server.com
# → підключає до Lobby

Server Address: survival.server.com
# → підключає до Survival

# Перевірка у Velocity console:
[INFO] Player123 connected via lobby.server.com → lobby
[INFO] Player456 connected via survival.server.com → survival
```

---

## 🎮 Use Cases: Forced Hosts

### Use Case #1: Bedrock + Java (GeyserMC)

```
Проблема:
Bedrock гравці (Pocket Edition) → різний протокол
Java гравці → стандартний протокол

Рішення:
bedrock.server.com → Bedrock-Friendly серве (GeyserMC)
java.server.com → Java сервер
```

**Конфігурація:**

```toml
[servers]
  java-lobby = "10.0.1.10:30066"
  bedrock-lobby = "10.0.1.20:30066"  # має GeyserMC

[forced-hosts]
  "java.server.com" = ["java-lobby"]
  "bedrock.server.com" = ["bedrock-lobby"]
  "play.server.com" = ["java-lobby"]  # default Java
```

**DNS:**
```
A Record:
java.server.com    → 1.2.3.4:25565
bedrock.server.com → 1.2.3.4:19132

SRV Record:
_minecraft._tcp.bedrock → bedrock.server.com:19132
```

### Use Case #2: Whitelist subdomains

```
Проблема:
VIP гравці → окремий сервер
Public → звичайний сервер

Рішення:
vip.server.com → VIP server (whitelist)
play.server.com → Public server
```

**Конфігурація:**

```toml
[servers]
  public-lobby = "10.0.1.10:30066"
  vip-lobby = "10.0.1.20:30066"

[forced-hosts]
  "play.server.com" = ["public-lobby"]
  "vip.server.com" = ["vip-lobby"]
```

**VIP server (spigot.yml):**
```yaml
settings:
  bungeecord: true

# Paper (config):
white-list: true
```

**Whitelist:**
```bash
# На VIP server:
whitelist add VIPPlayer123
whitelist add Streamer456
```

### Use Case #3: Testing server (beta)

```
Проблема:
Потрібен testing сервер для beta тестів
Не хочемо показувати публіці

Рішення:
play.server.com → production
beta.server.com → testing (не рекламуємо)
```

**Конфігурація:**

```toml
[servers]
  production = "10.0.1.10:30066"
  beta = "10.0.1.20:30066"

[forced-hosts]
  "play.server.com" = ["production"]
  "beta.server.com" = ["beta"]
  
# У Discord тільки для beta-testers:
# "Beta server: beta.server.com"
```

### Use Case #4: Event server

```
Проблема:
Під час події (турнір) потрібен окремий сервер
Після події - вимкнути

Рішення:
play.server.com → звичайний
event.server.com → event server (тимчасово)
```

**Конфігурація:**

```toml
[servers]
  lobby = "10.0.1.10:30066"
  event-lobby = "10.0.1.30:30066"

[forced-hosts]
  "play.server.com" = ["lobby"]
  "event.server.com" = ["event-lobby"]

# Після події:
# Видаляємо event-lobby з [servers]
# Видаляємо з [forced-hosts]
# velocity reload (або restart)
```

---

## 🔧 Advanced: Wildcard subdomains

### Wildcard DNS:

```
У DNS:
*.server.com → 1.2.3.4

Результат:
anything.server.com → 1.2.3.4
random.server.com → 1.2.3.4
test123.server.com → 1.2.3.4
```

### Dynamic routing з wildcard:

```toml
# Не підтримується нативно у Velocity!
# Потрібен плагін: MultiProxy або similar

# Приклад плагіну (pseudo-code):
[forced-hosts]
  "*.server.com" = "dynamic"

# Plugin логіка:
if hostname matches "eu-*.server.com":
    route to EU servers
if hostname matches "us-*.server.com":
    route to US servers
if hostname matches "player-*.server.com":
    route to personal island (player name)
```

**Use case: Personal islands**

```
Гравці отримують:
player123.server.com → їх острів
player456.server.com → їх острів

Plugin динамічно створює сервер:
/island create → новий Paper instance
Hostname: playerName.server.com
Routing: автоматично через wildcard
```

---

## 🛡️ Безпека: IP Whitelist

### Проблема:

```
Paper сервер відкритий:
backend.server.com:30066 → ПУБЛІЧНО доступний

Хакер може:
1. Підключитись прямо (обійти Velocity)
2. Підробити IP forwarding (якщо legacy)
3. Зайти як адмін
```

### Рішення #1: Firewall (UFW)

```bash
# Дозволяємо тільки Velocity IP:
sudo ufw allow from 1.2.3.4 to any port 30066
sudo ufw deny 30066

# Перевірка:
sudo ufw status

# Output:
To                   Action   From
30066                ALLOW    1.2.3.4
30066                DENY     Anywhere
```

### Рішення #2: Paper whitelist (spigot.yml)

```yaml
# spigot.yml (НЕ server.properties!)
settings:
  bungeecord: true

# За замовчуванням Paper перевіряє IP forwarding
# Якщо не пройде перевірку → kick
```

### Рішення #3: Advanced - IPWhitelist plugin

```bash
# Завантажуємо плагін:
wget https://github.com/example/IPWhitelist/releases/download/v1.0/IPWhitelist.jar -O plugins/IPWhitelist.jar

# Конфіг (plugins/IPWhitelist/config.yml):
allowed-ips:
  - "1.2.3.4"        # Velocity IP
  - "10.0.1.0/24"    # Local network

kick-message: "Connect via play.server.com"

# Restart Paper
```

---

## 📊 Моніторинг: Forced Hosts metrics

### Velocity плагін для аналітики:

```java
// VelocityMetrics plugin (pseudo-code)

@Subscribe
public void onServerPreConnect(ServerPreConnectEvent event) {
    Player player = event.getPlayer();
    String hostname = player.getVirtualHost()
        .map(InetSocketAddress::getHostString)
        .orElse("unknown");
    
    // Log hostname usage:
    metrics.increment("forced_host." + hostname);
    
    // Example output (Prometheus):
    // forced_host.lobby.server.com = 150 connections
    // forced_host.survival.server.com = 75 connections
    // forced_host.play.server.com = 500 connections
}
```

### Grafana Dashboard:

```
Panel 1: Connections by Hostname
- lobby.server.com: 150
- survival.server.com: 75
- play.server.com: 500

Panel 2: Top hostnames (last 7 days)
1. play.server.com (85%)
2. lobby.server.com (10%)
3. event.server.com (5%)

Panel 3: Unknown hostnames (potential attacks)
- random123.server.com: 5 attempts (blocked)
```

---

## 🐛 Troubleshooting

### Problem #1: Forced host не працює

**Симптоми:**
```
Підключення до survival.server.com → йде у lobby
```

**Діагностика:**

```bash
# Velocity console:
[INFO] Player123 connected via survival.server.com → lobby

# Бачимо hostname, але routing не працює
```

**Причини:**

```
1. Опечатка у velocity.toml:
[forced-hosts]
  "survivall.server.com" = ["survival"]  # опечатка!

2. DNS не налаштований:
survival.server.com → не резолвиться

3. Player використав IP:
1.2.3.4 → немає hostname → fallback to try=

4. Cache DNS (старий IP):
survival.server.com → старий IP → не працює
```

**Рішення:**

```bash
# 1. Перевірте конфіг:
cat velocity.toml | grep -A 5 forced-hosts

# 2. Перевірте DNS:
nslookup survival.server.com
# Output має показувати Velocity IP

# 3. Перевірте Velocity лог:
tail -f logs/latest.log | grep "connected via"

# 4. Очистіть DNS cache (Windows):
ipconfig /flushdns

# 5. Тест з curl:
curl -I http://survival.server.com
```

### Problem #2: IP Forwarding не працює

**Симптоми:**
```
Paper лог:
[INFO] Player123[/127.0.0.1:54321] joined
            ^^^^^^^^^^^ локальний IP (неправильно!)
```

**Діагностика:**

```bash
# Перевірте Velocity config:
cat velocity.toml | grep player-info-forwarding-mode
# Output: player-info-forwarding-mode = "modern"

# Перевірте Paper config:
cat config/paper-global.yml | grep -A 5 velocity
# Output:
# velocity:
#   enabled: true
#   secret: "..."
```

**Причини:**

```
1. Modern forwarding вимкнений:
player-info-forwarding-mode = "none"

2. Secret не співпадає:
Velocity secret ≠ Paper secret

3. Legacy mode + Paper modern:
Velocity: legacy
Paper: velocity.enabled = true (конфлікт!)

4. server.properties:
online-mode=true (має бути false!)
```

**Рішення:**

```bash
# 1. Перевірте forwarding mode:
# velocity.toml:
player-info-forwarding-mode = "modern"

# 2. Скопіюйте secret:
cat ~/minecraft/velocity/forwarding.secret
# Вставте у paper-global.yml

# 3. server.properties:
online-mode=false

# 4. Restart Velocity + Paper

# 5. Тест:
# Підключіться як гравець
# Paper лог має показати СПРАВЖНІЙ IP:
[INFO] Player123[/123.45.67.89:54321] joined
                   ^^^^^^^^^^^^^ справжній IP!
```

---

## 🎯 Best Practices

### Forwarding:

```
✅ Використовуйте "modern" (не legacy!)
✅ Зберігайте forwarding.secret безпечно
✅ Синхронізуйте secret між серверами
✅ Firewall: дозволяйте тільки Velocity IP
✅ Моніторьте failed forwarding attempts
```

### Forced Hosts:

```
✅ Короткі, легко запам''ятовувані domains
✅ lobby.server.com (добре)
❌ legacy-server-lobby-new-2024.server.com (погано)

✅ Використовуйте subdomains (не шляхи)
✅ survival.server.com (добре)
❌ server.com/survival (не працює у Minecraft)

✅ Документуйте всі hostnames:
# domains.txt:
play.server.com → lobby (публічний)
eu.server.com → eu-lobby (EU регіон)
beta.server.com → beta (приватний)
```

---

## 📚 Наступні кроки

### Модуль 2 завершено:

```
✅ Lesson 3: Топології
✅ Lesson 4: IP Forwarding + Forced Hosts

→ Модуль 3: Load Balancing
   - Автоматичний розподіл гравців
   - Load balancer plugins
   - Dynamic server groups
```

---

## ✅ Домашнє завдання

1. **Налаштувати Modern Forwarding**
   - Velocity: modern mode
   - Paper: velocity.enabled + secret
   - Тест: перевірити Paper лог (реальний IP?)

2. **DNS + Forced Hosts**
   - Купити домен (або використати subdomain)
   - Налаштувати A records
   - Додати forced hosts у velocity.toml
   - Тест: підключитись через subdomain

3. **Firewall**
   - UFW rules: дозволити тільки Velocity IP
   - Тест: спроба підключення прямо до Paper (має блокувати!)

4. **Моніторинг**
   - Записати всі hostname у Excel/Google Sheets
   - Відслідковувати usage (Velocity лог)
   - Виявити найпопулярніший hostname

5. **Security audit**
   - Перевірити: forwarding.secret скопійований правильно?
   - Перевірити: online-mode правильно налаштований?
   - Перевірити: firewall блокує публічний доступ?

---

**Вітаю! Ви налаштували IP Forwarding та Forced Hosts! 🎉**

**Результат:**
- ✅ Paper бачить справжні IP гравців
- ✅ Subdomains routing працює
- ✅ Безпечний forwarding з криптографією
- ✅ Firewall захищає backend

**Далі:** автоматизація розподілу гравців з Load Balancing!',
    5400,
    4,
    false
  );

  RAISE NOTICE 'Module 2, Lesson 4 created!';
END $$;
