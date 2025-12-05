-- =====================================================
-- МОДУЛЬ 1, УРОК 2: Налаштування Velocity з нуля
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-3' AND order_index = 1;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 2;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_lesson_id,
    'Налаштування Velocity: від встановлення до production',
    'text',
    '# Налаштування Velocity: повний гайд

## 🎯 Що налаштуємо

В цьому уроці:
```
✅ Встановлення Velocity
✅ Налаштування config.toml
✅ Підключення backend серверів (Paper/Spigot)
✅ IP Forwarding та security
✅ Перші плагіни
✅ Troubleshooting типових помилок
```

---

## 📦 Встановлення Velocity

### Системні вимоги

**Мінімальні:**
```
OS: Linux (Ubuntu 22.04 LTS рекомендовано)
RAM: 512MB (для proxy)
CPU: 1 core
Java: 17+
Network: 100Mbps
```

**Рекомендовані (100+ гравців):**
```
OS: Linux Ubuntu 22.04 LTS
RAM: 2GB
CPU: 2 cores
Java: 21 LTS
Network: 1Gbps
Storage: 5GB SSD
```

### Крок 1: Встановлення Java 21

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y openjdk-21-jre-headless

# Перевірка
java -version
# openjdk version "21.0.1" 2023-10-17

# Альтернатива: Oracle GraalVM (швидше!)
# https://www.graalvm.org/downloads/
```

**⚠️ Важливо:** Velocity потребує Java 17+, але Java 21 дає +15% performance!

### Крок 2: Завантаження Velocity

```bash
# Створюємо директорію
mkdir -p ~/velocity
cd ~/velocity

# Завантажуємо останню версію
wget https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/386/downloads/velocity-3.3.0-SNAPSHOT-386.jar -O velocity.jar

# Альтернатива: через curl
curl -L -o velocity.jar https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/386/downloads/velocity-3.3.0-SNAPSHOT-386.jar

# Перевірка розміру (має бути ~10-12 MB)
ls -lh velocity.jar
```

**Перевірка checksums (безпека):**
```bash
# Завантажуємо checksum
wget https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/386/downloads/velocity-3.3.0-SNAPSHOT-386.jar.sha256

# Перевіряємо
sha256sum -c velocity-3.3.0-SNAPSHOT-386.jar.sha256
# velocity.jar: OK ✅
```

### Крок 3: Перший запуск

```bash
# Запускаємо
java -Xms512M -Xmx512M -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -jar velocity.jar

# Що відбувається:
# 1. Створюється velocity.toml
# 2. Створюється папка plugins/
# 3. Генерується forwarding secret
# 4. Сервер запускається на порту 25577

# Очікуваний output:
[INFO] Booting Velocity 3.3.0-SNAPSHOT...
[INFO] Loading configuration from velocity.toml
[INFO] Loaded 0 plugins
[INFO] Done (1.2s)! Listening on /0.0.0.0:25577
```

**Перші помилки та рішення:**

❌ **Помилка 1:**
```
Error: A JNI error has occurred
```
**Рішення:** Java версія < 17, оновіть Java!

❌ **Помилка 2:**
```
Address already in use: bind
```
**Рішення:** Порт 25577 зайнятий, змініть у config або:
```bash
# Знайти процес
sudo lsof -i :25577
# Вбити процес
sudo kill -9 <PID>
```

❌ **Помилка 3:**
```
java.lang.OutOfMemoryError: Java heap space
```
**Рішення:** Збільшити RAM:
```bash
java -Xms1G -Xmx1G ... -jar velocity.jar
```

---

## ⚙️ Налаштування config.toml

### Структура файлу

```toml
# velocity.toml - основний конфіг

[основні параметри]
bind = "0.0.0.0:25565"
motd = "..."
show-max-players = 500

[servers] - список backend серверів
[forced-hosts] - domain routing
[advanced] - compression, timeouts
[query] - server list ping
```

### Детальне налаштування

**1. Основні параметри**

```toml
# config-version - НЕ ЧІПАТИ!
config-version = "2.7"

# Bind address
bind = "0.0.0.0:25565"
# 0.0.0.0 = всі інтерфейси
# Альтернативи:
# bind = "192.168.1.100:25565" - конкретний IP
# bind = "[::]:25565" - IPv6

# MOTD (Message of the Day)
motd = "<#09add3>A Velocity Server"
# Підтримує:
# - MiniMessage format
# - RGB colors: <#RRGGBB>
# - Gradients: <gradient:#ff0000:#0000ff>Gradient</gradient>

# Приклад красивого MOTD:
motd = "<gradient:#00ff87:#60efff>▌ My Network</gradient>\\n<gray>Survival • Minigames • Creative"

# Show max players
show-max-players = 500
# -1 = dynamic (показує онлайн з усіх серверів)
# Рекомендація: показуйте більше ніж реально
# Психологія: "500 slots" > "50 slots"
```

**2. Сервери (найважливіше!)**

```toml
[servers]
  # Format: name = "ip:port"
  lobby = "127.0.0.1:30066"
  survival = "192.168.1.101:25565"
  creative = "192.168.1.102:25565"
  minigames = "192.168.1.103:25565"
  
  # Try list - порядок підключення
  try = ["lobby"]
  # Гравець спочатку йде на lobby
  # Якщо lobby offline → відмова входу
  
  # Альтернатива: fallback chain
  try = ["lobby", "hub", "survival"]
  # lobby offline? → hub
  # hub offline? → survival
```

**⚠️ Типові помилки:**

❌ **Помилка:** Backend сервер на тому ж порту
```toml
bind = "0.0.0.0:25565"
[servers]
  lobby = "127.0.0.1:25565" # ❌ КОНФЛІКТ!
```

✅ **Рішення:** Backend на іншому порту
```toml
bind = "0.0.0.0:25565"
[servers]
  lobby = "127.0.0.1:30066" # ✅ OK
```

**3. Forced hosts (domain routing)**

```toml
[forced-hosts]
  # Format: "domain" = ["server"]
  "lobby.example.com" = ["lobby"]
  "survival.example.com" = ["survival"]
  "play.example.com" = ["lobby"]
  
  # Wildcard
  "*.creative.example.com" = ["creative"]
  
  # Multiple servers (load balance)
  "minigames.example.com" = ["mg1", "mg2", "mg3"]
```

**Кейс використання:**

```
DNS Records:
play.mynetwork.com      → 192.168.1.100 (Velocity)
survival.mynetwork.com  → 192.168.1.100 (Velocity)

Гравець підключається:
1. survival.mynetwork.com:25565
   → Velocity бачить hostname
   → Направляє на survival сервер ✅

2. play.mynetwork.com:25565  
   → Velocity бачить hostname
   → Направляє на lobby ✅

Один Velocity, різні входи!
```

**4. Advanced settings**

```toml
[advanced]
  # Compression threshold (bytes)
  compression-threshold = 256
  # -1 = вимкнено
  # 256 = compressed якщо > 256 bytes
  # Рекомендація: 256 (баланс CPU/network)
  
  # Compression level
  compression-level = -1
  # -1 = default (6)
  # 0-9: 0 = no compression, 9 = maximum
  # Рекомендація: -1 або 4
  
  # Connection timeout (ms)
  connection-timeout = 5000
  # Час очікування підключення до backend
  # 5000ms = 5 секунд (достатньо)
  
  # Read timeout (ms)
  read-timeout = 30000
  # Timeout читання від backend
  # 30s = запас для лагів
  
  # HAProxy protocol
  haproxy-protocol = false
  # Увімкнути якщо Velocity за HAProxy/Nginx
  
  # TCP fast open
  tcp-fast-open = false
  # Linux kernel optimization
  # Увімкнути на production!
  
  # BungeeCord plugin compatibility
  bungee-plugin-message-channel = true
  # Дозволяє legacy BungeeCord плагінам
  
  # Show ping requests
  show-ping-requests = false
  # Debug: показувати ping запити
  
  # Announce Forge
  announce-forge = false
  # false = приховує Forge від клієнта
  
  # Kick existing players
  kick-existing-players = false
  # true = кік старої сесії при reconnect
  
  # Ping passthrough (показувати backend MOTD)
  ping-passthrough = "DISABLED"
  # DISABLED, MODS, DESCRIPTION, ALL
  
  # Enable player address logging
  enable-player-address-logging = true
  # Логувати IP гравців (GDPR!)
```

**5. Query (Server list ping)**

```toml
[query]
  # Enable query protocol
  enabled = false
  # true = дозволяє server list ping
  
  # Query port
  port = 25577
  # Має бути відкритий в firewall
  
  # Show plugins
  show-plugins = false
  # false = приховує список плагінів
```

---

## 🔐 IP Forwarding Setup

### Чому це важливо?

```
Без forwarding:
Player connects → Velocity → Backend
Backend бачить IP: 127.0.0.1 (Velocity)
❌ Всі гравці мають той самий IP!
❌ IP bans не працюють
❌ Region protection (IP-based) ламається

З forwarding:
Player connects → Velocity → Backend (+ real IP)
Backend бачить: 94.123.45.67 (real player IP)
✅ IP bans працюють
✅ Region protection OK
✅ Analytics правильні
```

### Крок 1: Velocity config

```toml
[advanced]
  # Forwarding mode
  forwarding-mode = "modern"
  # Options:
  # - "none" = ні forwarding (небезпечно!)
  # - "legacy" = BungeeCord compatibility
  # - "modern" = Velocity native (рекомендовано)
  
  # Forwarding secret
  forwarding-secret = "abc123def456ghi789"
  # ⚠️ ГЕНЕРУЙТЕ УНІКАЛЬНИЙ!
  # ⚠️ ТРИМАЙТЕ В СЕКРЕТІ!
```

**Генерація безпечного secret:**

```bash
# Linux/Mac
openssl rand -hex 32
# Output: d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5

# Windows PowerShell
-join ((48..57) + (97..102) | Get-Random -Count 64 | % {[char]$_})

# Вставте в config:
forwarding-secret = "d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5"
```

### Крок 2: Backend сервери (Paper)

**paper-global.yml:**

```yaml
proxies:
  velocity:
    enabled: true
    online-mode: true
    secret: "d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5"
    # ☝️ ТОЙ САМИЙ secret як у Velocity!
```

**server.properties:**

```properties
# ОБОВ''ЯЗКОВО!
online-mode=false
# Якщо true → гравці не зможуть зайти через proxy
```

**⚠️ КРИТИЧНА ПОМИЛКА:**

```yaml
# velocity.toml
forwarding-secret = "secret123"

# paper-global.yml  
secret: "secret456" # ❌ РІЗНІ SECRETS!

Результат:
[ERROR] Invalid player connection! Forwarding secret mismatch
Гравець: "Can''t connect to server"
```

✅ **Рішення:** Secrets МАЮТЬ бути ідентичні!

---

## 🛡️ Firewall налаштування

### Базова безпека

```bash
# Ubuntu UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Дозволити SSH (щоб не заблокувати себе!)
sudo ufw allow 22/tcp

# Дозволити Velocity
sudo ufw allow 25565/tcp

# Backend сервери (ТІЛЬКИ локально!)
# НЕ відкривайте 30066, 30067 назовні!

# Увімкнути firewall
sudo ufw enable

# Перевірка
sudo ufw status
```

**⚠️ НЕБЕЗПЕЧНА ПОМИЛКА:**

```bash
# ❌ НІКОЛИ ТАК НЕ РОБІТЬ!
sudo ufw allow 30066/tcp # відкриває backend!

Проблема:
Гравці можуть підключитись напряму до backend
→ Обхід Velocity
→ Обхід forwarding
→ IP spoofing можливий!
```

✅ **Правильно:**

```bash
# Backend сервери слухають тільки localhost
# server.properties:
server-ip=127.0.0.1
server-port=30066

# Firewall: закрито назовні
# Тільки Velocity може підключитись!
```

---

## 🔌 Підключення першого backend

### Архітектура

```
[Player] 
   ↓ 25565
[Velocity Proxy]
   ↓ 127.0.0.1:30066
[Paper Server - Lobby]
```

### Крок 1: Paper сервер

```bash
# Окрема папка
mkdir ~/lobby
cd ~/lobby

# Завантажити Paper
wget https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/497/downloads/paper-1.20.4-497.jar -O paper.jar

# Запустити (прийняти EULA)
java -Xms2G -Xmx2G -jar paper.jar --nogui
# Зупинити після генерації

# Прийняти EULA
echo "eula=true" > eula.txt
```

### Крок 2: Налаштування Paper

**server.properties:**

```properties
online-mode=false
server-port=30066
server-ip=127.0.0.1
motd=Lobby Server
max-players=100
```

**paper-global.yml:**

```yaml
proxies:
  velocity:
    enabled: true
    online-mode: true
    secret: "YOUR_SECRET_HERE"
```

### Крок 3: Запуск

```bash
# Terminal 1: Velocity
cd ~/velocity
java -Xms512M -Xmx512M -jar velocity.jar

# Terminal 2: Lobby
cd ~/lobby  
java -Xms2G -Xmx2G -jar paper.jar --nogui

# Перевірка
# Velocity log:
[INFO] [/127.0.0.1:30066] <-> InitialHandler has connected
```

### Крок 4: Тест підключення

```
Minecraft Client:
Multiplayer → Add Server
Address: YOUR_SERVER_IP:25565

Connect:
1. Client → Velocity (25565)
2. Velocity → Lobby (30066)
3. Success! ✅

/server
# Shows: lobby

Chat:
"You are on lobby"
```

---

## 🐛 Troubleshooting: Типові помилки

### Помилка 1: Can''t connect to server

**Симптом:**
```
Minecraft: "Can''t connect to server"
Velocity log: [WARN] ... connection refused
```

**Причини та рішення:**

1. **Backend не запущений**
```bash
# Перевірка
ps aux | grep paper
# Немає процесу? Запустіть!
```

2. **Неправильний порт**
```toml
# velocity.toml
lobby = "127.0.0.1:30066"

# server.properties
server-port=30067 # ❌ різні!
```

3. **Backend не слухає localhost**
```properties
# server.properties
server-ip= # ❌ слухає всі інтерфейси

# Має бути:
server-ip=127.0.0.1 # ✅
```

### Помилка 2: Invalid player connection

**Симптом:**
```
Velocity: [ERROR] Invalid player connection!
Player: Kicked: "You are not authenticated"
```

**Причина:** Forwarding secret mismatch

**Рішення:**
```bash
# Velocity
grep forwarding-secret velocity.toml
forwarding-secret = "abc123"

# Paper
grep secret paper-global.yml
secret: "xyz789" # ❌ різні!

# Виправлення: скопіюйте secret з Velocity → Paper
```

### Помилка 3: Already connected to server

**Симптом:**
```
Player: "You are already connected to this server"
```

**Причина:** Спроба /server на той самий сервер

**Рішення:**
```
Це нормально! Не помилка.
Просто гравець вже на цьому сервері.
```

### Помилка 4: Outdated client/server

**Симптом:**
```
"Outdated client! Please use 1.20.4"
або
"Outdated server! I''m still on 1.20.1"
```

**Причина:** Version mismatch

**Рішення:**
```
1. ViaVersion + ViaBackwards
   → backward compatibility (1.8 → 1.20)

2. Оновити всі сервери до однієї версії

Рекомендація: Option 1 (flexibility)
```

---

## 🎯 Перші плагіни

### Необхідний мінімум

**1. LuckPerms (permissions)**

```bash
cd ~/velocity/plugins
wget https://download.luckperms.net/1548/velocity/LuckPerms-Velocity-5.4.134.jar
```

**2. SignedVelocity (verification)**

```bash
wget https://github.com/4drian3d/SignedVelocity/releases/download/1.3.0/SignedVelocity-1.3.0.jar
```

**3. MiniMOTD (красивий MOTD)**

```bash
wget https://modrinth.com/plugin/minimotd/version/2.1.0-velocity
```

**4. Maintenance (maintenance mode)**

```bash
wget https://hangar.papermc.io/kennytv/Maintenance/versions/4.2.1
```

### Перевірка

```bash
# Перезапустити Velocity
# Log:
[INFO] Loaded plugin luckperms 5.4.134
[INFO] Loaded plugin signedvelocity 1.3.0
[INFO] Loaded plugin minimotd 2.1.0
[INFO] Loaded plugin maintenance 4.2.1

# In-game
/lpv
# LuckPerms menu відкривається ✅
```

---

## 📋 Production Checklist

### Перед запуском мережі:

```
□ Java 21 встановлена
□ Velocity 3.3+ downloaded
□ config.toml налаштований
□ Forwarding secret унікальний (32+ chars)
□ Backend servers: online-mode=false
□ paper-global.yml: velocity secret збігається
□ Firewall: тільки 25565 відкритий
□ Backend: server-ip=127.0.0.1
□ Тест підключення: OK
□ /server працює
□ IP forwarding: backend бачить real IP
□ LuckPerms встановлений
□ Backup config.toml
□ Monitoring налаштований (наступний урок)
```

---

## 🚀 Оптимізація для production

### Startup flags (512MB-2GB RAM)

```bash
#!/bin/bash
# start.sh

java -Xms512M -Xmx512M \\
  -XX:+UseG1GC \\
  -XX:G1HeapRegionSize=4M \\
  -XX:+UnlockExperimentalVMOptions \\
  -XX:+ParallelRefProcEnabled \\
  -XX:+AlwaysPreTouch \\
  -XX:MaxInlineLevel=15 \\
  -jar velocity.jar
```

### Systemd service (auto-restart)

```bash
# /etc/systemd/system/velocity.service
[Unit]
Description=Velocity Proxy
After=network.target

[Service]
User=minecraft
WorkingDirectory=/home/minecraft/velocity
ExecStart=/usr/bin/java -Xms512M -Xmx512M -jar velocity.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Увімкнути
sudo systemctl enable velocity
sudo systemctl start velocity

# Перевірка
sudo systemctl status velocity
```

---

## ✅ Домашнє завдання

1. **Встановити Velocity**
   - Java 21
   - Velocity 3.3+
   - Перший запуск

2. **Налаштувати config.toml**
   - Bind на 25565
   - Додати 1 backend сервер
   - Forwarding modern

3. **Підключити Paper сервер**
   - online-mode=false
   - paper-global.yml з secret
   - Запустити

4. **Тестування**
   - Підключитись
   - /server
   - Перевірити IP в Paper logs

5. **Backup**
   - velocity.toml
   - paper-global.yml
   - Зберегти forwarding-secret!

---

**Вітаю! Ви налаштували Velocity! 🎉**

**Результат:**
- ✅ Velocity proxy працює
- ✅ Backend сервер підключений
- ✅ IP forwarding налаштований
- ✅ Безпечний forwarding secret
- ✅ Firewall захищає backend

**Далі:** Network топології та архітектура (Модуль 2)!',
    6000,
    2,
    false
  );

  RAISE NOTICE 'Module 1, Lesson 2 created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-3' AND m.order_index = 1
ORDER BY l.order_index;
