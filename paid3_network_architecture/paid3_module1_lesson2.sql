-- =====================================================
-- МОДУЛЬ 1, УРОК 2: Налаштування Velocity з нуля
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  -- Отримуємо ID модуля
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
    '# Налаштування Velocity: покрокова інструкція

## 🎯 Що встановимо

```
Архітектура:
┌──────────────────────────────────────┐
│         Velocity Proxy               │
│    (Сервер 1: 1.2.3.4:25565)        │
└────────┬─────────────┬───────────────┘
         │             │
    ┌────▼────┐   ┌────▼────┐
    │ Lobby   │   │ Survival│
    │ Server  │   │  Server │
    │ :30066  │   │  :30067 │
    └─────────┘   └─────────┘

Результат:
✅ Гравці підключаються до 1.2.3.4:25565
✅ Proxy розподіляє їх між серверами
✅ Безшовні переходи між світами
```

---

## 📋 Передумови

### Що потрібно:

```bash
# Мінімальні вимоги:
- 2 VPS сервери (або 1 потужний)
- Ubuntu 22.04 LTS
- 2GB RAM кожен (мінімум)
- Java 17 або 21

# Рекомендовано:
- 3 VPS (proxy окремо від backend)
- Ubuntu 22.04 LTS
- 4GB RAM для proxy
- 4-8GB RAM для backend серверів
- Java 21 (найсвіжіша LTS)
```

### Перевірка середовища:

```bash
# Версія Ubuntu
lsb_release -a
# Output: Ubuntu 22.04.3 LTS

# Доступна RAM
free -h
# Output: total 4.0Gi

# Java версія
java -version
# Якщо немає:
sudo apt update
sudo apt install -y openjdk-21-jre-headless

# Перевірка ще раз:
java -version
# Output: openjdk version "21.0.1"
```

---

## 📥 Встановлення Velocity

### Крок 1: Створення структури директорій

```bash
# Заходимо як звичайний користувач (НЕ root!)
cd ~

# Створюємо директорії
mkdir -p minecraft/velocity
mkdir -p minecraft/servers/lobby
mkdir -p minecraft/servers/survival

# Структура:
minecraft/
├── velocity/          # Proxy сервер
├── servers/
│   ├── lobby/        # Backend: Lobby
│   └── survival/     # Backend: Survival
```

### Крок 2: Завантаження Velocity

```bash
cd ~/minecraft/velocity

# Завантажуємо останню версію (перевірте актуальну на papermc.io)
wget https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/388/downloads/velocity-3.3.0-SNAPSHOT-388.jar -O velocity.jar

# Альтернатива (якщо wget не працює):
curl -o velocity.jar https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/388/downloads/velocity-3.3.0-SNAPSHOT-388.jar

# Перевірка:
ls -lh velocity.jar
# Output: -rw-r--r-- 1 user user 8.2M Dec  2 10:30 velocity.jar
```

### Крок 3: Перший запуск (генерація конфігів)

```bash
# Запускаємо Velocity вперше
java -Xms512M -Xmx512M -jar velocity.jar

# Що відбувається:
# 1. Створюється velocity.toml
# 2. Створюється forwarding.secret
# 3. Velocity запускається

# Побачите:
[INFO] Velocity 3.3.0-SNAPSHOT
[INFO] Listening on /0.0.0.0:25577
[WARN] +---------------------+
[WARN] | NO BACKEND SERVERS! |
[WARN] +---------------------+

# Це нормально! Поки немає backend серверів
# Натискаємо Ctrl+C для зупинки
```

### Крок 4: Огляд створених файлів

```bash
ls -la

# Бачимо:
velocity.jar          # Сам Velocity
velocity.toml         # ГОЛОВНИЙ КОНФІГ ← редагуємо це!
forwarding.secret     # Secret для безпеки
logs/                 # Логи
plugins/              # Папка для плагінів
```

---

## ⚙️ Налаштування velocity.toml

### Базовий конфіг (velocity.toml):

```toml
# Config version - НЕ ЧІПАТИ!
config-version = "2.7"

# IP та порт для підключення гравців
bind = "0.0.0.0:25565"

# MOTD (що бачать гравці у списку серверів)
motd = "<#09add3>⚡ <bold>MyNetwork</bold> <reset><#7f8c8d>• Velocity Network"

# Максимум гравців (що показується у списку)
# -1 = необмежено
show-max-players = 100

# Онлайн режим (ЗАВЖДИ TRUE для production!)
online-mode = true

# Prevent client proxy connections
prevent-client-proxy-connections = true

# Player info forwarding mode
# ВАЖЛИВО: modern - найбезпечніший (Paper 1.13+)
player-info-forwarding-mode = "modern"

# Forwarding secret (генерується автоматично)
# forwarding-secret = "генерується_автоматично"

# Announce Forge/Fabric support
announce-forge = true

# Kick message
kick-existing-players = false

# Ping passthrough
ping-passthrough = "disabled"

# Enable player address logging
enable-player-address-logging = true

# =====================================================
# СЕРВЕРА (Backend)
# =====================================================
[servers]
  # Формат: назва = "IP:PORT"
  lobby = "127.0.0.1:30066"
  survival = "127.0.0.1:30067"
  
  # Try list - порядок спроби підключення
  try = [
    "lobby"
  ]

# =====================================================
# FORCED HOSTS (Subdomains)
# =====================================================
[forced-hosts]
  # Приклад: lobby.example.com → lobby сервер
  # "lobby.example.com" = ["lobby"]
  # "survival.example.com" = ["survival"]

# =====================================================
# ADVANCED
# =====================================================
[advanced]
  # Compression threshold (в байтах)
  # 256 - золота середина
  compression-threshold = 256
  
  # Compression level (-1 = default, 0-9)
  # -1 = adaptive (рекомендовано)
  compression-level = -1
  
  # Login ratelimit (мс між спробами)
  # Захист від bot floods
  login-ratelimit = 3000
  
  # Connection timeout
  connection-timeout = 5000
  
  # Read timeout
  read-timeout = 30000
  
  # Enable HAProxy protocol
  haproxy-protocol = false
  
  # TCP fast open
  tcp-fast-open = false
  
  # BungeeCord plugin message channel
  bungee-plugin-message-channel = true
  
  # Show ping requests
  show-ping-requests = false
  
  # Announce proxy commands
  announce-proxy-commands = true
  
  # Log command executions
  log-command-executions = false
  
  # Log player connections
  log-player-connections = true

# =====================================================
# QUERY (Server list ping)
# =====================================================
[query]
  # Enable query protocol
  enabled = false
  
  # Query port
  port = 25577
  
  # Show plugins in query
  show-plugins = false

# =====================================================
# METRICS
# =====================================================
[metrics]
  # bStats metrics
  enabled = true
  
  # UUID (автоматично генерується)
  # id = "генерується_автоматично"
```

### Редагування конфігу:

```bash
# Відкриваємо в nano (простий редактор)
nano velocity.toml

# Що змінити:
# 1. bind = "0.0.0.0:25565" ← ваш порт
# 2. motd = "..." ← ваше MOTD
# 3. show-max-players = 100 ← ваш ліміт
# 4. [servers] секцію ← ваші сервера

# Збереження:
# Ctrl+O (save)
# Enter (confirm)
# Ctrl+X (exit)
```

---

## 🖥️ Налаштування Backend серверів

### Крок 1: Встановлення Paper сервера (Lobby)

```bash
cd ~/minecraft/servers/lobby

# Завантажуємо Paper 1.20.4
wget https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/497/downloads/paper-1.20.4-497.jar -O server.jar

# Перший запуск (eula)
java -Xms2G -Xmx2G -jar server.jar --nogui

# Приймаємо EULA
echo "eula=true" > eula.txt

# Зупиняємо (якщо вже запустився)
# Ctrl+C
```

### Крок 2: Налаштування Paper для Velocity

**КРИТИЧНО ВАЖЛИВО!** Paper ПОВИНЕН знати про Velocity:

```bash
# Відкриваємо config/paper-global.yml
nano config/paper-global.yml

# Знаходимо секцію proxies:
proxies:
  velocity:
    enabled: true
    online-mode: true
    secret: "СКОПІЮВАТИ_З_velocity/forwarding.secret"

# Зберігаємо: Ctrl+O, Enter, Ctrl+X
```

**Як скопіювати forwarding.secret:**

```bash
# На Velocity сервері:
cat ~/minecraft/velocity/forwarding.secret

# Output (приклад):
# a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6

# Копіюємо і вставляємо у paper-global.yml
```

### Крок 3: Налаштування server.properties

```bash
nano server.properties

# ВАЖЛИВІ параметри:
server-port=30066          # ← порт з velocity.toml
online-mode=false          # ← ОБОВ'ЯЗКОВО FALSE!
                           # (Velocity перевіряє, не Paper)

# Інші:
max-players=100
server-name=lobby
```

### Крок 4: Запуск Lobby сервера

```bash
# Start script
nano start.sh

# Вміст:
#!/bin/bash
java -Xms2G -Xmx2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -jar server.jar --nogui

# Робимо виконуваним:
chmod +x start.sh

# Запускаємо:
./start.sh
```

### Крок 5: Повторюємо для Survival

```bash
cd ~/minecraft/servers/survival

# Копіюємо все з lobby:
cp ~/minecraft/servers/lobby/server.jar .
cp ~/minecraft/servers/lobby/eula.txt .
cp ~/minecraft/servers/lobby/start.sh .

# Створюємо конфіги:
mkdir config

# paper-global.yml (ТАКИЙ САМИЙ forwarding.secret!)
nano config/paper-global.yml
# [вставляємо той самий конфіг]

# server.properties (ІНШИЙ ПОРТ!)
nano server.properties
# server-port=30067 ← ЗМІНЮЄМО!
# server-name=survival

# Запускаємо:
./start.sh
```

---

## 🚀 Запуск мережі

### Порядок запуску:

```bash
# 1. Спочатку backend сервера (Lobby + Survival)
cd ~/minecraft/servers/lobby
./start.sh &

cd ~/minecraft/servers/survival
./start.sh &

# Чекаємо 30-60 секунд (поки завантажаться)

# 2. Потім Velocity
cd ~/minecraft/velocity
java -Xms512M -Xmx512M -jar velocity.jar

# Логи Velocity:
[INFO] Attempting to connect to lobby...
[INFO] Established connection to lobby
[INFO] Attempting to connect to survival...
[INFO] Established connection to survival
[INFO] Listening on /0.0.0.0:25565
```

### Перевірка:

```bash
# У Velocity console:
glist

# Output:
[INFO] There are 0 players online across 2 servers:
[INFO] lobby (0):
[INFO] survival (0):
```

---

## 🧪 Тестування підключення

### Крок 1: Підключення гравця

```
Minecraft клієнт:
Multiplayer → Add Server
Address: ВАШ_IP:25565 (або localhost:25565)
```

### Крок 2: Перевірка логів

**Velocity лог:**
```
[INFO] [initial connection] /123.45.67.89:54321 connected
[INFO] [connected player] Player123 (/123.45.67.89:54321) connected
[INFO] [server connection] Player123 → lobby
```

**Lobby лог (Paper):**
```
[INFO] Player123[/127.0.0.1:54322] logged in
[INFO] Player123 joined the game
```

### Крок 3: Команди для тестування

```bash
# У Velocity console:
glist           # Список гравців
glist lobby     # Гравці на lobby
glist survival  # Гравці на survival

# У грі (як гравець):
/server         # Список серверів
/server lobby   # Переключитись на lobby
/server survival # Переключитись на survival
```

---

## 🔒 Безпека: forwarding.secret

### Чому це важливо?

```
Без forwarding.secret:
❌ Хакер може підключитись прямо до Paper (30066)
❌ Обійти Velocity → fake UUID
❌ Зайти як будь-який гравець (навіть адмін!)

З forwarding.secret:
✅ Paper перевіряє secret
✅ Якщо secret не співпадає → кік
✅ Підключатись можна ТІЛЬКИ через Velocity
```

### Перевірка захисту:

```bash
# Спроба підключитись прямо до Paper (30066):
# Minecraft клієнт → Add Server → localhost:30066

# Результат:
# "Invalid forwarding secret"
# Kicked from server ✅

# Це добре! Захист працює!
```

### Firewall rules (додатковий захист):

```bash
# Дозволяємо тільки Velocity → Paper

# На Paper сервері:
sudo ufw allow from VELOCITY_IP to any port 30066
sudo ufw allow from VELOCITY_IP to any port 30067

# Забороняємо інші:
sudo ufw deny 30066
sudo ufw deny 30067

# Дозволяємо Velocity порт (зовнішній):
sudo ufw allow 25565

# Активуємо:
sudo ufw enable
```

---

## 🔧 Поширені проблеми та рішення

### Проблема 1: "Can''t connect to server"

**Симптоми:**
```
Velocity лог:
[WARN] Unable to connect to lobby
[WARN] java.net.ConnectException: Connection refused
```

**Причини та рішення:**

```bash
# 1. Paper сервер не запущений
ps aux | grep java
# Якщо немає → запустіть ./start.sh

# 2. Неправильний порт у velocity.toml
cat velocity.toml | grep lobby
# Має бути: lobby = "127.0.0.1:30066"

# 3. Paper слухає інший IP
# У server.properties:
server-ip=
# Має бути ПОРОЖНЬО (або 0.0.0.0)

# 4. Firewall блокує
sudo ufw status
sudo ufw allow 30066
```

### Проблема 2: "Invalid forwarding secret"

**Симптоми:**
```
Paper лог:
[WARN] Rejected connection from /127.0.0.1:54321
[WARN] Invalid forwarding secret
```

**Рішення:**

```bash
# 1. Порівняємо secrets
cat ~/minecraft/velocity/forwarding.secret
cat ~/minecraft/servers/lobby/config/paper-global.yml | grep secret

# Якщо НЕ співпадають:
# Копіюємо правильний secret:
SECRET=$(cat ~/minecraft/velocity/forwarding.secret)

# Оновлюємо paper-global.yml:
sed -i "s/secret: .*/secret: \"$SECRET\"/" ~/minecraft/servers/lobby/config/paper-global.yml

# Перезапускаємо Paper:
# У Paper console: stop
# Потім: ./start.sh
```

### Проблема 3: "Took too long to login"

**Симптоми:**
```
Velocity лог:
[WARN] Player123 took too long to login
```

**Причини:**
```
1. Повільна мережа між Velocity ↔ Paper
2. Paper перевантажений (TPS < 10)
3. Timeout занадто малий
```

**Рішення:**

```toml
# У velocity.toml:
[advanced]
  connection-timeout = 10000  # Було: 5000
  read-timeout = 60000        # Було: 30000
```

### Проблема 4: UUID не збергається

**Симптоми:**
```
Гравець заходить → новий UUID кожен раз
Інвентар втрачається
Permissions зникають
```

**Причина:**
```
online-mode = false у velocity.toml
АБО
online-mode = true у server.properties
```

**Рішення:**

```toml
# velocity.toml:
online-mode = true  # ← ОБОВ'ЯЗКОВО TRUE

# server.properties:
online-mode=false   # ← ОБОВ'ЯЗКОВО FALSE
```

---

## 📊 Моніторинг мережі

### Команди Velocity:

```bash
# У Velocity console:

glist               # Загальна статистика
# Output:
# There are 15 players online across 2 servers:
# lobby (10): Player1, Player2, ...
# survival (5): Player3, Player4, ...

velocity dump       # Dump debug info
velocity plugins    # Список плагінів
velocity info       # Інфо про Velocity
velocity reload     # Перезавантажити конфіг (НЕ рекомендовано)
```

### Логи:

```bash
# Velocity логи:
tail -f ~/minecraft/velocity/logs/latest.log

# Paper логи:
tail -f ~/minecraft/servers/lobby/logs/latest.log
tail -f ~/minecraft/servers/survival/logs/latest.log

# Фільтрація помилок:
grep -i error ~/minecraft/velocity/logs/latest.log
grep -i warn ~/minecraft/velocity/logs/latest.log
```

---

## 🎯 Production Checklist

### Перед запуском для гравців:

```
□ online-mode = true у velocity.toml
□ server-properties: online-mode = false
□ forwarding.secret скопійований у всі Paper
□ Firewall налаштований (тільки Velocity → Paper)
□ Backup скрипти налаштовані
□ Моніторинг працює (логи, метрики)
□ Тестове підключення успішне
□ Переключення між серверами працює
□ UUID зберігається при reconnect
□ Інвентар синхронізується
□ Permissions працюють (LuckPerms)
```

### Автозапуск (systemd):

```bash
# Velocity systemd service
sudo nano /etc/systemd/system/velocity.service

# Вміст:
[Unit]
Description=Velocity Proxy
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/home/minecraft/minecraft/velocity
ExecStart=/usr/bin/java -Xms512M -Xmx512M -jar velocity.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

# Активація:
sudo systemctl daemon-reload
sudo systemctl enable velocity
sudo systemctl start velocity

# Перевірка:
sudo systemctl status velocity

# Логи:
sudo journalctl -u velocity -f
```

---

## 📚 Наступні кроки

### Ви встановили базову мережу! Далі:

```
✅ Модуль 1 завершено:
   - Обрали Velocity
   - Встановили та налаштували
   - Підключили 2 backend сервера

→ Модуль 2: Network топології
   - Різні архітектури (Hub-Spoke, Mesh)
   - Коли використовувати яку
   - Масштабування до 10+ серверів

→ Модуль 3: Load Balancing
   - Автоматичний розподіл гравців
   - Dynamic server groups
   - Balancer плагіни

→ Модуль 4: Redis Messaging
   - Cross-server communication
   - Global chat
   - Friends списки
```

---

## ✅ Домашнє завдання

1. **Встановити мережу**
   - Velocity proxy
   - 2 Paper сервера (lobby + survival)
   - Перевірити forwarding.secret

2. **Тестування**
   - Підключитись як гравець
   - Переключитись між серверами 10 разів
   - Перевірити UUID (однаковий?)
   - Reconnect → UUID збергся?

3. **Firewall**
   - Налаштувати ufw rules
   - Спробувати підключитись прямо до Paper (має кікнути!)

4. **Автозапуск**
   - Створити systemd services
   - Перезавантажити VPS → все автостартує?

5. **Документація**
   - Записати всі IP:PORT
   - Зберегти forwarding.secret (бекап!)
   - Задокументувати topology

---

**Вітаю! Ваша перша Velocity мережа працює! 🎉**

**Результат:**
- ✅ 1 Velocity proxy (entry point)
- ✅ 2 Paper backend сервери
- ✅ Безпечний forwarding
- ✅ Seamless server switching

**Далі:** складніші топології та load balancing!',
    4800,
    2,
    false
  );

  RAISE NOTICE 'Module 1, Lesson 2 created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type, l.is_free_preview
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-3' AND m.order_index = 1
ORDER BY l.order_index;
