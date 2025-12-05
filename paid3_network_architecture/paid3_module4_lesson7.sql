-- =====================================================
-- МОДУЛЬ 4, УРОК 7: Redis Messaging для Cross-Server Communication
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  -- Перевіряємо чи існує модуль 4
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-3' AND order_index = 4;
  
  -- Якщо не існує - створюємо
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-3',
      'module-4',
      'Redis та Cross-Server Communication',
      'Redis Pub/Sub, messaging між серверами, синхронізація даних, global chat',
      4
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 7;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_lesson_id,
    'Redis Pub/Sub: налаштування та messaging між серверами',
    'text',
    '# Redis для Cross-Server Communication

## 🎯 Проблема: ізольовані сервери

### Без Redis:

```
Мережа:
Velocity
├─ Lobby-1 (30 гравців)
├─ Lobby-2 (25 гравців)
├─ Survival (15 гравців)
└─ Creative (10 гравців)

Проблеми:
❌ Гравець на Lobby-1 пише у чат → бачать тільки 30 на Lobby-1
❌ Друзі не бачать online status (різні сервери)
❌ Бан на Survival → гравець може зайти на Lobby
❌ Немає синхронізації даних
❌ /glist показує тільки локальних гравців
```

### З Redis:

```
Всі сервери підключені до Redis:
         ┌────────────┐
         │   REDIS    │ ← Central messaging hub
         └─────┬──────┘
    ┌────┬─────┼─────┬────┐
    │    │     │     │    │
Lobby-1 Lobby-2 Surv Crea Event

✅ Повідомлення у чат → всі сервери бачать
✅ Friends status синхронізований
✅ Global bans працюють
✅ /glist показує всіх (80 гравців)
✅ Party system працює між серверами
```

---

## 📚 Що таке Redis?

**Redis** = Remote Dictionary Server (in-memory database)

```
Характеристики:
- Зберігає дані у RAM (швидко!)
- Key-Value store
- Підтримує Pub/Sub (messaging)
- Персистентність (може зберігати на диск)
- Швидкість: 100,000+ ops/sec

Використання у Minecraft:
✅ Pub/Sub messaging
✅ Cache (часто запитувані дані)
✅ Session storage
✅ Leaderboards (sorted sets)
✅ Rate limiting
```

---

## 🔧 Встановлення Redis

### Ubuntu/Debian:

```bash
# Оновлюємо пакети:
sudo apt update

# Встановлюємо Redis:
sudo apt install redis-server -y

# Перевіряємо версію:
redis-server --version
# Output: Redis server v=7.0.12

# Запускаємо:
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Статус:
sudo systemctl status redis-server
# Output: active (running)

# Тест підключення:
redis-cli ping
# Output: PONG ← працює!
```

### Docker (рекомендовано):

```yaml
# docker-compose.yml
version: "3.8"

services:
  redis:
    image: redis:7-alpine
    container_name: minecraft-redis
    ports:
      - "6379:6379"
    volumes:
      - ./redis-data:/data
      - ./redis.conf:/usr/local/etc/redis/redis.conf
    command: redis-server /usr/local/etc/redis/redis.conf
    restart: unless-stopped
    networks:
      - minecraft

networks:
  minecraft:
    driver: bridge
```

```bash
# Запуск:
docker-compose up -d redis

# Перевірка:
docker exec -it minecraft-redis redis-cli ping
# PONG
```

### redis.conf (конфігурація):

```
# redis.conf
bind 0.0.0.0
protected-mode yes
port 6379

# Пароль (ОБОВ''''ЯЗКОВО для production!)
requirepass your_secure_password_here_min_32_chars

# Persistence (зберігати на диск)
save 900 1      
save 300 10     
save 60 10000   

# Максимальна пам''''ять
maxmemory 256mb
maxmemory-policy allkeys-lru

# Logging
loglevel notice
logfile /var/log/redis/redis-server.log

# Pub/Sub
timeout 0
tcp-keepalive 300
```

---

## 📡 Redis Pub/Sub: Концепція

### Як працює Pub/Sub:

```
Publisher (відправник):
Lobby-1 → PUBLISH "global-chat" "Player123: Hello!"

Channel (канал):
"global-chat" ← назва каналу

Subscribers (отримувачі):
Lobby-1, Lobby-2, Survival, Creative → SUBSCRIBE "global-chat"

Всі підписники отримують:
"Player123: Hello!"
```

### Приклад: Global Chat

```
1. Player123 на Survival пише: "Hello everyone!"

2. Survival сервер:
   PUBLISH "global-chat" (JSON з даними гравця)

3. Redis broadcast до всіх підписників:
   - Lobby-1 (30 гравців)
   - Lobby-2 (25 гравців)
   - Survival (15 гравців) ← включно з відправником
   - Creative (10 гравців)

4. Кожен сервер обробляє:
   for (player : onlinePlayers) {
       player.sendMessage("[GLOBAL] [Survival] Player123: Hello everyone!");
   }

5. Результат:
   80 гравців бачать повідомлення!
```

---

## 🛠️ Jedis: Java клієнт для Redis

### Додавання залежності (Maven):

```xml
<!-- pom.xml -->
<dependencies>
    <!-- Jedis (Redis client) -->
    <dependency>
        <groupId>redis.clients</groupId>
        <artifactId>jedis</artifactId>
        <version>5.1.0</version>
    </dependency>
    
    <!-- Gson (JSON parsing) -->
    <dependency>
        <groupId>com.google.code.gson</groupId>
        <artifactId>gson</artifactId>
        <version>2.10.1</version>
    </dependency>
</dependencies>
```

### Gradle:

```gradle
dependencies {
    implementation ''redis.clients:jedis:5.1.0''
    implementation ''com.google.code.gson:gson:2.10.1''
}
```

---

## 💻 Базове підключення до Redis

### RedisManager.java:

```java
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class RedisManager {
    private static JedisPool jedisPool;
    
    public static void connect(String host, int port, String password) {
        JedisPoolConfig poolConfig = new JedisPoolConfig();
        poolConfig.setMaxTotal(20);
        poolConfig.setMaxIdle(10);
        poolConfig.setMinIdle(5);
        poolConfig.setTestOnBorrow(true);
        
        if (password != null && !password.isEmpty()) {
            jedisPool = new JedisPool(poolConfig, host, port, 2000, password);
        } else {
            jedisPool = new JedisPool(poolConfig, host, port);
        }
        
        // Тест підключення:
        try (Jedis jedis = jedisPool.getResource()) {
            String response = jedis.ping();
            System.out.println("Redis connected: " + response); // PONG
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public static Jedis getResource() {
        return jedisPool.getResource();
    }
    
    public static void close() {
        if (jedisPool != null) {
            jedisPool.close();
        }
    }
}
```

### У вашому plugin:

```java
@Override
public void onEnable() {
    // config.yml:
    String host = getConfig().getString("redis.host", "localhost");
    int port = getConfig().getInt("redis.port", 6379);
    String password = getConfig().getString("redis.password", "");
    
    RedisManager.connect(host, port, password);
    getLogger().info("Redis connected!");
}

@Override
public void onDisable() {
    RedisManager.close();
}
```

---

## 📨 Publishing Messages (відправка)

### MessagePublisher.java:

```java
import com.google.gson.Gson;
import redis.clients.jedis.Jedis;

public class MessagePublisher {
    private static final Gson gson = new Gson();
    
    // Publish simple string:
    public static void publishString(String channel, String message) {
        try (Jedis jedis = RedisManager.getResource()) {
            jedis.publish(channel, message);
        }
    }
    
    // Publish JSON object:
    public static void publishJson(String channel, Object object) {
        String json = gson.toJson(object);
        try (Jedis jedis = RedisManager.getResource()) {
            jedis.publish(channel, json);
        }
    }
    
    // Приклад: Global chat message
    public static void sendGlobalChat(String playerName, String message, String serverName) {
        ChatMessage msg = new ChatMessage(playerName, message, serverName, System.currentTimeMillis());
        publishJson("global-chat", msg);
    }
}

// ChatMessage model:
class ChatMessage {
    private String player;
    private String message;
    private String server;
    private long timestamp;
    
    public ChatMessage(String player, String message, String server, long timestamp) {
        this.player = player;
        this.message = message;
        this.server = server;
        this.timestamp = timestamp;
    }
    
    // Getters...
}
```

---

## 📥 Subscribing (отримання повідомлень)

### MessageSubscriber.java:

```java
import com.google.gson.Gson;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPubSub;
import org.bukkit.Bukkit;
import org.bukkit.entity.Player;

public class MessageSubscriber extends JedisPubSub {
    private static final Gson gson = new Gson();
    private final JavaPlugin plugin;
    
    public MessageSubscriber(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    @Override
    public void onMessage(String channel, String message) {
        // Обробляємо у Bukkit main thread:
        Bukkit.getScheduler().runTask(plugin, () -> {
            handleMessage(channel, message);
        });
    }
    
    private void handleMessage(String channel, String message) {
        switch (channel) {
            case "global-chat":
                handleGlobalChat(message);
                break;
            case "player-join":
                handlePlayerJoin(message);
                break;
            case "player-quit":
                handlePlayerQuit(message);
                break;
        }
    }
    
    private void handleGlobalChat(String json) {
        ChatMessage msg = gson.fromJson(json, ChatMessage.class);
        
        String formatted = String.format(
            "§8[§bGLOBAL§8] §7[§e%s§7] §f%s§8: §7%s",
            msg.getServer(),
            msg.getPlayer(),
            msg.getMessage()
        );
        
        for (Player player : Bukkit.getOnlinePlayers()) {
            player.sendMessage(formatted);
        }
    }
}
```

### Запуск Subscriber (окремий thread):

```java
public class RedisListener {
    private Thread listenerThread;
    private MessageSubscriber subscriber;
    
    public void start(JavaPlugin plugin) {
        subscriber = new MessageSubscriber(plugin);
        
        listenerThread = new Thread(() -> {
            try (Jedis jedis = RedisManager.getResource()) {
                // БЛОКУЮЧИЙ виклик (тому окремий thread!)
                jedis.subscribe(subscriber, "global-chat", "player-join", "player-quit");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }, "Redis-Subscriber");
        
        listenerThread.start();
    }
    
    public void stop() {
        if (subscriber != null) {
            subscriber.unsubscribe();
        }
        if (listenerThread != null) {
            listenerThread.interrupt();
        }
    }
}
```

### У main plugin class:

```java
private RedisListener redisListener;

@Override
public void onEnable() {
    RedisManager.connect("localhost", 6379, "password");
    
    redisListener = new RedisListener();
    redisListener.start(this);
}

@Override
public void onDisable() {
    redisListener.stop();
    RedisManager.close();
}
```

---

## 🎮 Приклад: Global Chat Plugin

### GlobalChatPlugin.java:

```java
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.AsyncPlayerChatEvent;

public class GlobalChatPlugin extends JavaPlugin implements Listener {
    
    @Override
    public void onEnable() {
        // Redis setup:
        RedisManager.connect(
            getConfig().getString("redis.host"),
            getConfig().getInt("redis.port"),
            getConfig().getString("redis.password")
        );
        
        // Start listener:
        new RedisListener().start(this);
        
        // Register event:
        getServer().getPluginManager().registerEvents(this, this);
    }
    
    @EventHandler
    public void onChat(AsyncPlayerChatEvent event) {
        String playerName = event.getPlayer().getName();
        String message = event.getMessage();
        String serverName = getConfig().getString("server.name", "unknown");
        
        // Cancel local event (ми обробимо через Redis):
        event.setCancelled(true);
        
        // Publish to Redis:
        MessagePublisher.sendGlobalChat(playerName, message, serverName);
    }
}
```

### config.yml:

```yaml
redis:
  host: "localhost"
  port: 6379
  password: "your_secure_password"

server:
  name: "Survival-1"  # ← УНІКАЛЬНА назва для кожного сервера!
```

### Результат:

```
На Survival-1:
Player123: Hello world!

Redis publish:
JSON: player=Player123, message=Hello world!, server=Survival-1, timestamp=1701234567890

На всіх серверах (Lobby-1, Lobby-2, Creative):
[GLOBAL] [Survival-1] Player123: Hello world!
```

---

## 📊 Channels (канали): Best Practices

### Структура каналів:

```
Рекомендована naming convention:

network:global-chat        ← Global chat
network:staff-chat         ← Staff тільки
network:player-join        ← Join notifications
network:player-quit        ← Quit notifications
network:player-switch      ← Server switch events

survival:local-chat        ← Survival тільки
lobby:announcements        ← Lobby announcements

minigame:skywars:start     ← SkyWars game start
minigame:skywars:end       ← SkyWars game end

admin:broadcast            ← Admin broadcasts
admin:command              ← Remote commands
```

### Wildcard subscriptions:

```java
// Subscribe to all network channels:
jedis.psubscribe(subscriber, "network:*");

// Subscribe to all minigame:skywars channels:
jedis.psubscribe(subscriber, "minigame:skywars:*");

// Pattern subscriber:
@Override
public void onPMessage(String pattern, String channel, String message) {
    if (pattern.equals("network:*")) {
        handleNetworkMessage(channel, message);
    }
}
```

---

## 🔥 Advanced: Request-Response Pattern

### Проблема:

```
Хочемо дізнатись online гравців на іншому сервері:
Lobby-1 → "Скільки гравців на Survival?"
Survival → "15 гравців"

Але Pub/Sub = one-way! Немає response!
```

### Рішення: Request-Response з унікальним ID:

```java
public class RequestResponseManager {
    private static final Map<String, CompletableFuture<String>> pendingRequests = new ConcurrentHashMap<>();
    
    // Send request:
    public static CompletableFuture<String> sendRequest(String targetServer, String command) {
        String requestId = UUID.randomUUID().toString();
        CompletableFuture<String> future = new CompletableFuture<>();
        
        pendingRequests.put(requestId, future);
        
        // Timeout after 5 seconds:
        Bukkit.getScheduler().runTaskLater(plugin, () -> {
            CompletableFuture<String> removed = pendingRequests.remove(requestId);
            if (removed != null) {
                removed.completeExceptionally(new TimeoutException("Request timeout"));
            }
        }, 100L); // 5 sec
        
        // Publish request:
        Request req = new Request(requestId, getServerName(), targetServer, command);
        MessagePublisher.publishJson("network:request", req);
        
        return future;
    }
    
    // Handle incoming request:
    public static void handleRequest(String json) {
        Request req = gson.fromJson(json, Request.class);
        
        if (!req.getTargetServer().equals(getServerName())) {
            return; // Not for us
        }
        
        // Execute command and get result:
        String result = executeCommand(req.getCommand());
        
        // Send response:
        Response res = new Response(req.getRequestId(), getServerName(), result);
        MessagePublisher.publishJson("network:response", res);
    }
    
    // Handle incoming response:
    public static void handleResponse(String json) {
        Response res = gson.fromJson(json, Response.class);
        
        CompletableFuture<String> future = pendingRequests.remove(res.getRequestId());
        if (future != null) {
            future.complete(res.getResult());
        }
    }
}
```

### Використання:

```java
// На Lobby-1:
RequestResponseManager.sendRequest("Survival-1", "player-count")
    .thenAccept(result -> {
        sender.sendMessage("Survival has " + result + " players!");
    })
    .exceptionally(ex -> {
        sender.sendMessage("Request failed: " + ex.getMessage());
        return null;
    });
```

---

## 📈 Performance Optimization

### Connection pooling:

```java
JedisPoolConfig config = new JedisPoolConfig();

// Max connections:
config.setMaxTotal(50);        // Max 50 connections
config.setMaxIdle(20);         // Max 20 idle
config.setMinIdle(5);          // Min 5 idle

// Timeouts:
config.setMaxWaitMillis(3000); // Wait max 3 sec for connection

// Health checks:
config.setTestOnBorrow(true);   // Test before use
config.setTestOnReturn(true);   // Test after use
config.setTestWhileIdle(true);  // Test idle connections

// Eviction (clean old):
config.setTimeBetweenEvictionRunsMillis(30000); // Every 30 sec
config.setMinEvictableIdleTimeMillis(60000);    // Evict after 60 sec idle
```

### Batch operations:

```java
// ❌ Погано (N network calls):
for (String key : keys) {
    jedis.get(key);  // 1000 keys = 1000 network calls!
}

// ✅ Добре (1 network call):
List<String> values = jedis.mget(keys.toArray(new String[0]));

// ❌ Погано:
for (Entry<String, String> entry : data.entrySet()) {
    jedis.set(entry.getKey(), entry.getValue());
}

// ✅ Добре:
jedis.mset(flattenMap(data));
```

### Pipeline (ще швидше):

```java
try (Jedis jedis = RedisManager.getResource()) {
    Pipeline pipeline = jedis.pipelined();
    
    for (int i = 0; i < 1000; i++) {
        pipeline.set("key" + i, "value" + i);
    }
    
    pipeline.sync(); // Execute all at once!
}
```

---

## ✅ Домашнє завдання

1. **Встановити Redis** (Docker або нативно)
2. **Створити GlobalChat plugin** з Pub/Sub
3. **Налаштувати 2 Paper сервери** (обидва підключені до Redis)
4. **Тест:** написати повідомлення на Server1 → побачити на Server2
5. **Bonus:** Додати /staffchat команду (окремий channel)

---

**Далі: Урок 8 - Реалізація Global Chat System з фільтрами та модерацією!**',
    6000,
    7,
    false
  );

  RAISE NOTICE 'Module 4, Lesson 7 created!';
END $$;
