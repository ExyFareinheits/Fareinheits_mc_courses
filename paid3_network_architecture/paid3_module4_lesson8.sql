-- =====================================================
-- МОДУЛЬ 4, УРОК 8: Global Chat System + Квіз
-- =====================================================
-- Курс: paid-3 (Network Architecture: BungeeCord та Velocity)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
  v_quiz_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-3' AND order_index = 4;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 8;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_lesson_id,
    'Global Chat System: фільтри, модерація, spam protection',
    'text',
    '# Global Chat System: Production-Ready Implementation

## 🎯 Що потрібно для production chat?

```
Базовий Global Chat (Урок 7):
✅ Redis Pub/Sub
✅ Broadcast повідомлень

Production Chat потребує:
✅ Spam protection (rate limiting)
✅ Chat filters (лайка, капслок)
✅ Модерація (mute, ban)
✅ Channels (/local, /global, /staff)
✅ Permissions (хто може писати)
✅ Форматування (ранги, кольори)
✅ Logging (історія повідомлень)
✅ Cooldowns (не спамити)
```

---

## 🛡️ Spam Protection: Rate Limiting

### Проблема:

```
Спамер:
Player123: aaaa
Player123: aaaa
Player123: aaaa
Player123: aaaa
... (100 повідомлень за секунду!)

Результат:
- Чат захаращений
- Redis overload
- Інші гравці не бачать нормальні повідомлення
```

### Рішення: Rate Limiter з Redis

```java
public class RateLimiter {
    private static final String KEY_PREFIX = "ratelimit:chat:";
    private static final int MAX_MESSAGES = 3;    // 3 повідомлення
    private static final int TIME_WINDOW = 5;     // за 5 секунд
    
    public static boolean canSendMessage(UUID playerId) {
        String key = KEY_PREFIX + playerId.toString();
        
        try (Jedis jedis = RedisManager.getResource()) {
            // Отримуємо поточну кількість:
            String value = jedis.get(key);
            int count = (value == null) ? 0 : Integer.parseInt(value);
            
            if (count >= MAX_MESSAGES) {
                // Перевищено ліміт!
                return false;
            }
            
            // Інкрементуємо:
            jedis.incr(key);
            
            // Встановлюємо expire (якщо новий ключ):
            if (count == 0) {
                jedis.expire(key, TIME_WINDOW);
            }
            
            return true;
        }
    }
    
    public static int getRemainingTime(UUID playerId) {
        String key = KEY_PREFIX + playerId.toString();
        try (Jedis jedis = RedisManager.getResource()) {
            return jedis.ttl(key).intValue();
        }
    }
}
```

### Використання:

```java
@EventHandler
public void onChat(AsyncPlayerChatEvent event) {
    Player player = event.getPlayer();
    
    if (!RateLimiter.canSendMessage(player.getUniqueId())) {
        event.setCancelled(true);
        int remaining = RateLimiter.getRemainingTime(player.getUniqueId());
        player.sendMessage("§cСлишком багато повідомлень! Почекайте " + remaining + " секунд.");
        return;
    }
    
    // Відправити повідомлення...
}
```

---

## 🔇 Chat Filters: Profanity та Spam

### BadWordFilter.java:

```java
public class BadWordFilter {
    private static final Set<String> BAD_WORDS = new HashSet<>(Arrays.asList(
        "badword1", "badword2", "badword3"
        // Завантажити з файлу: badwords.txt
    ));
    
    public static boolean containsBadWord(String message) {
        String lower = message.toLowerCase();
        
        for (String badWord : BAD_WORDS) {
            if (lower.contains(badWord)) {
                return true;
            }
        }
        
        return false;
    }
    
    public static String censorMessage(String message) {
        String result = message;
        
        for (String badWord : BAD_WORDS) {
            // Заміна на ***
            String replacement = "*".repeat(badWord.length());
            result = result.replaceAll("(?i)" + badWord, replacement);
        }
        
        return result;
    }
    
    // Advanced: Regex patterns для обходу фільтра
    public static boolean containsBadWordAdvanced(String message) {
        String normalized = message.toLowerCase()
            .replaceAll("[^a-z]", "");  // Видалити спецсимволи
        
        // "b@dw0rd" → "badword"
        normalized = normalized
            .replace("0", "o")
            .replace("1", "i")
            .replace("3", "e")
            .replace("4", "a")
            .replace("5", "s")
            .replace("7", "t")
            .replace("@", "a");
        
        for (String badWord : BAD_WORDS) {
            if (normalized.contains(badWord)) {
                return true;
            }
        }
        
        return false;
    }
}
```

### CapsFilter.java:

```java
public class CapsFilter {
    private static final double MAX_CAPS_RATIO = 0.7;  // 70% caps = spam
    
    public static boolean isCapsSpam(String message) {
        if (message.length() < 5) {
            return false;  // Короткі повідомлення OK
        }
        
        int capsCount = 0;
        for (char c : message.toCharArray()) {
            if (Character.isUpperCase(c)) {
                capsCount++;
            }
        }
        
        double ratio = (double) capsCount / message.length();
        return ratio > MAX_CAPS_RATIO;
    }
    
    public static String normalizeCaps(String message) {
        // "HELLO WORLD" → "Hello world"
        if (isCapsSpam(message)) {
            return message.substring(0, 1).toUpperCase() + 
                   message.substring(1).toLowerCase();
        }
        return message;
    }
}
```

### Використання filters:

```java
@EventHandler
public void onChat(AsyncPlayerChatEvent event) {
    Player player = event.getPlayer();
    String message = event.getMessage();
    
    // 1. Rate limit:
    if (!RateLimiter.canSendMessage(player.getUniqueId())) {
        event.setCancelled(true);
        player.sendMessage("§cПочекайте перед наступним повідомленням!");
        return;
    }
    
    // 2. Bad words:
    if (BadWordFilter.containsBadWord(message)) {
        event.setCancelled(true);
        player.sendMessage("§cВаше повідомлення містить заборонені слова!");
        
        // Log для модераторів:
        logToModerators(player.getName() + " спробував написати: " + message);
        return;
    }
    
    // 3. Caps spam:
    if (CapsFilter.isCapsSpam(message)) {
        message = CapsFilter.normalizeCaps(message);
        player.sendMessage("§eПовідомлення нормалізовано (забагато КАПСЛОКУ)");
    }
    
    // Відправити через Redis...
    event.setCancelled(true);
    MessagePublisher.sendGlobalChat(player.getName(), message, serverName);
}
```

---

## 🔨 Модерація: Mute та Chat Bans

### MuteManager.java з Redis:

```java
public class MuteManager {
    private static final String KEY_PREFIX = "mute:";
    
    // Mute гравця на певний час:
    public static void mutePlayer(UUID playerId, int seconds, String reason) {
        String key = KEY_PREFIX + playerId.toString();
        
        try (Jedis jedis = RedisManager.getResource()) {
            // Зберігаємо причину:
            jedis.set(key, reason);
            
            // Встановлюємо TTL:
            jedis.expire(key, seconds);
        }
        
        // Broadcast до всіх серверів:
        MuteEvent event = new MuteEvent(playerId, seconds, reason);
        MessagePublisher.publishJson("network:mute", event);
    }
    
    // Permanent mute:
    public static void mutePlayerPermanent(UUID playerId, String reason) {
        String key = KEY_PREFIX + playerId.toString();
        
        try (Jedis jedis = RedisManager.getResource()) {
            jedis.set(key, reason);
            // Без expire = permanent
        }
        
        MuteEvent event = new MuteEvent(playerId, -1, reason);
        MessagePublisher.publishJson("network:mute", event);
    }
    
    // Unmute:
    public static void unmutePlayer(UUID playerId) {
        String key = KEY_PREFIX + playerId.toString();
        
        try (Jedis jedis = RedisManager.getResource()) {
            jedis.del(key);
        }
        
        UnmuteEvent event = new UnmuteEvent(playerId);
        MessagePublisher.publishJson("network:unmute", event);
    }
    
    // Перевірка чи muted:
    public static boolean isMuted(UUID playerId) {
        String key = KEY_PREFIX + playerId.toString();
        
        try (Jedis jedis = RedisManager.getResource()) {
            return jedis.exists(key);
        }
    }
    
    // Отримати причину mute:
    public static String getMuteReason(UUID playerId) {
        String key = KEY_PREFIX + playerId.toString();
        
        try (Jedis jedis = RedisManager.getResource()) {
            return jedis.get(key);
        }
    }
    
    // Скільки залишилось:
    public static int getRemainingTime(UUID playerId) {
        String key = KEY_PREFIX + playerId.toString();
        
        try (Jedis jedis = RedisManager.getResource()) {
            Long ttl = jedis.ttl(key);
            return ttl.intValue();
        }
    }
}
```

### /mute команда:

```java
public class MuteCommand implements CommandExecutor {
    @Override
    public boolean onCommand(CommandSender sender, Command cmd, String label, String[] args) {
        if (!sender.hasPermission("chat.mute")) {
            sender.sendMessage("§cНедостатньо прав!");
            return true;
        }
        
        if (args.length < 2) {
            sender.sendMessage("§cВикористання: /mute <гравець> <час> [причина]");
            return true;
        }
        
        String targetName = args[0];
        String timeStr = args[1];  // 10m, 1h, 1d, perm
        
        Player target = Bukkit.getPlayer(targetName);
        if (target == null) {
            sender.sendMessage("§cГравець не онлайн!");
            return true;
        }
        
        int seconds = parseTime(timeStr);
        String reason = args.length > 2 ? String.join(" ", Arrays.copyOfRange(args, 2, args.length)) : "Порушення правил";
        
        if (seconds == -1) {
            // Permanent:
            MuteManager.mutePlayerPermanent(target.getUniqueId(), reason);
            sender.sendMessage("§aГравця " + targetName + " permanently muted!");
        } else {
            MuteManager.mutePlayer(target.getUniqueId(), seconds, reason);
            sender.sendMessage("§aГравця " + targetName + " muted на " + timeStr + "!");
        }
        
        target.sendMessage("§cВас замутили! Причина: " + reason);
        
        return true;
    }
    
    private int parseTime(String str) {
        if (str.equalsIgnoreCase("perm") || str.equalsIgnoreCase("permanent")) {
            return -1;
        }
        
        char unit = str.charAt(str.length() - 1);
        int value = Integer.parseInt(str.substring(0, str.length() - 1));
        
        switch (unit) {
            case ''s'': return value;
            case ''m'': return value * 60;
            case ''h'': return value * 3600;
            case ''d'': return value * 86400;
            default: return value;  // assume seconds
        }
    }
}
```

### Перевірка mute у chat:

```java
@EventHandler
public void onChat(AsyncPlayerChatEvent event) {
    Player player = event.getPlayer();
    UUID playerId = player.getUniqueId();
    
    // Перевірка mute:
    if (MuteManager.isMuted(playerId)) {
        event.setCancelled(true);
        
        int remaining = MuteManager.getRemainingTime(playerId);
        String reason = MuteManager.getMuteReason(playerId);
        
        if (remaining > 0) {
            player.sendMessage("§cВи у mute! Залишилось: " + formatTime(remaining));
        } else {
            player.sendMessage("§cВи permanently muted!");
        }
        
        player.sendMessage("§7Причина: " + reason);
        return;
    }
    
    // Решта перевірок...
}
```

---

## 📺 Chat Channels: Multiple Chat Rooms

### Channel System:

```java
public enum ChatChannel {
    GLOBAL("network:global-chat", "§8[§bGLOBAL§8]", null),
    LOCAL("local-chat", "§8[§aLOCAL§8]", null),
    STAFF("network:staff-chat", "§8[§cSTAFF§8]", "chat.staff"),
    ADMIN("network:admin-chat", "§8[§4ADMIN§8]", "chat.admin"),
    DONOR("network:donor-chat", "§8[§6DONOR§8]", "chat.donor");
    
    private final String redisChannel;
    private final String prefix;
    private final String permission;
    
    ChatChannel(String redisChannel, String prefix, String permission) {
        this.redisChannel = redisChannel;
        this.prefix = prefix;
        this.permission = permission;
    }
    
    public boolean canUse(Player player) {
        return permission == null || player.hasPermission(permission);
    }
    
    // Getters...
}
```

### ChannelManager.java:

```java
public class ChannelManager {
    private static final Map<UUID, ChatChannel> playerChannels = new HashMap<>();
    
    public static void setChannel(UUID playerId, ChatChannel channel) {
        playerChannels.put(playerId, channel);
    }
    
    public static ChatChannel getChannel(UUID playerId) {
        return playerChannels.getOrDefault(playerId, ChatChannel.GLOBAL);
    }
    
    public static void sendMessage(Player player, String message) {
        ChatChannel channel = getChannel(player.getUniqueId());
        
        if (!channel.canUse(player)) {
            player.sendMessage("§cУ вас немає доступу до цього каналу!");
            return;
        }
        
        if (channel == ChatChannel.LOCAL) {
            // Local = тільки на цьому сервері
            for (Player online : Bukkit.getOnlinePlayers()) {
                online.sendMessage(channel.getPrefix() + " §f" + player.getName() + "§8: §7" + message);
            }
        } else {
            // Global channels через Redis:
            ChatMessage msg = new ChatMessage(
                player.getName(),
                message,
                serverName,
                channel
            );
            
            MessagePublisher.publishJson(channel.getRedisChannel(), msg);
        }
    }
}
```

### /channel команда:

```java
public class ChannelCommand implements CommandExecutor {
    @Override
    public boolean onCommand(CommandSender sender, Command cmd, String label, String[] args) {
        if (!(sender instanceof Player)) return true;
        Player player = (Player) sender;
        
        if (args.length == 0) {
            player.sendMessage("§eДоступні канали:");
            for (ChatChannel ch : ChatChannel.values()) {
                if (ch.canUse(player)) {
                    player.sendMessage("§7- §a" + ch.name().toLowerCase());
                }
            }
            return true;
        }
        
        String channelName = args[0].toUpperCase();
        ChatChannel channel;
        
        try {
            channel = ChatChannel.valueOf(channelName);
        } catch (IllegalArgumentException e) {
            player.sendMessage("§cНевідомий канал!");
            return true;
        }
        
        if (!channel.canUse(player)) {
            player.sendMessage("§cНемає доступу до цього каналу!");
            return true;
        }
        
        ChannelManager.setChannel(player.getUniqueId(), channel);
        player.sendMessage("§aПерейшли у канал: " + channel.getPrefix());
        
        return true;
    }
}
```

---

## 🎨 Chat Formatting: Ранги та кольори

### FormattingManager.java:

```java
public class FormattingManager {
    
    public static String formatMessage(Player player, String message, ChatChannel channel) {
        // Отримуємо ранг з LuckPerms:
        String prefix = getPrefix(player);
        String suffix = getSuffix(player);
        
        // Колір імені:
        String nameColor = getNameColor(player);
        
        // Колір повідомлення (permission):
        String messageColor = "§7";  // Default gray
        if (player.hasPermission("chat.color")) {
            messageColor = "§f";  // White для донатерів
        }
        
        // Format:
        // [GLOBAL] [VIP] Player123: Hello world!
        return channel.getPrefix() + " " +
               prefix + " " +
               nameColor + player.getName() + suffix +
               "§8: " +
               messageColor + message;
    }
    
    private static String getPrefix(Player player) {
        // Integration з LuckPerms:
        User user = LuckPermsProvider.get().getUserManager().getUser(player.getUniqueId());
        if (user == null) return "";
        
        String prefix = user.getCachedData().getMetaData().getPrefix();
        return prefix != null ? prefix : "";
    }
    
    private static String getNameColor(Player player) {
        // VIP = gold, Admin = red, etc:
        if (player.hasPermission("chat.color.red")) return "§c";
        if (player.hasPermission("chat.color.gold")) return "§6";
        if (player.hasPermission("chat.color.green")) return "§a";
        return "§f";  // Default white
    }
    
    // Color codes для донатерів:
    public static String translateColorCodes(Player player, String message) {
        if (!player.hasPermission("chat.color")) {
            return message;
        }
        
        // &c → §c
        return ChatColor.translateAlternateColorCodes(''&'', message);
    }
}
```

---

## 📝 Chat Logging: Історія повідомлень

### ChatLogger.java з Redis Streams:

```java
public class ChatLogger {
    private static final String STREAM_KEY = "chat:logs";
    
    public static void logMessage(String player, String message, String server, ChatChannel channel) {
        try (Jedis jedis = RedisManager.getResource()) {
            Map<String, String> data = new HashMap<>();
            data.put("player", player);
            data.put("message", message);
            data.put("server", server);
            data.put("channel", channel.name());
            data.put("timestamp", String.valueOf(System.currentTimeMillis()));
            
            // Add to stream:
            jedis.xadd(STREAM_KEY, StreamEntryID.NEW_ENTRY, data);
            
            // Trim old entries (keep last 10000):
            jedis.xtrim(STREAM_KEY, 10000, true);
        }
    }
    
    // Отримати історію:
    public static List<ChatLogEntry> getRecentMessages(int count) {
        try (Jedis jedis = RedisManager.getResource()) {
            List<StreamEntry> entries = jedis.xrevrange(STREAM_KEY, null, null, count);
            
            return entries.stream()
                .map(ChatLogEntry::fromStreamEntry)
                .collect(Collectors.toList());
        }
    }
    
    // Пошук повідомлень гравця:
    public static List<ChatLogEntry> getPlayerMessages(String playerName, int count) {
        List<ChatLogEntry> all = getRecentMessages(1000);
        
        return all.stream()
            .filter(e -> e.getPlayer().equalsIgnoreCase(playerName))
            .limit(count)
            .collect(Collectors.toList());
    }
}
```

---

## ✅ Production Checklist

```
□ Rate limiting (3 повідомлення / 5 секунд)
□ Bad word filter (+ advanced detection)
□ Caps spam filter
□ Mute system (temporary + permanent)
□ Multiple channels (global, local, staff)
□ Permissions per channel
□ Chat formatting (ранги, кольори)
□ Logging до Redis Streams
□ /mute, /unmute команди
□ Модераційні повідомлення
□ Cross-server sync (Redis)
```

---

## 🎯 Performance Tips

```
1. Async processing:
   - Всі Redis операції async
   - Не блокувати main thread

2. Connection pooling:
   - JedisPool з правильними налаштуваннями
   - Reuse connections

3. Caching:
   - Cache mute status локально (5 sec)
   - Cache permissions локально

4. Batch operations:
   - Multiple Redis ops → pipeline

5. Monitoring:
   - Track message rate
   - Alert на spam attacks
```

---

**Вітаю! Ви створили production-ready Global Chat! 🎉**

**Далі: Модуль 5 - MySQL Replication та HikariCP!**',
    5400,
    8,
    false
  );

  RAISE NOTICE 'Module 4, Lesson 8 (text) created!';
  
  -- Тепер створюємо КВІЗ для уроку 8
  v_quiz_id := gen_random_uuid()::text;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-3',
    v_module_id,
    v_quiz_id,
    'Квіз: Redis та Global Chat Systems',
    'quiz',
    '[
      {
        "question": "Яка основна перевага використання Redis для cross-server communication?",
        "options": [
          "Дешевше за MySQL",
          "In-memory зберігання (швидкість 100000+ ops/sec)",
          "Не потребує налаштування",
          "Автоматично масштабується"
        ],
        "correctAnswer": 1,
        "explanation": "Redis зберігає дані у RAM, що дає швидкість 100,000+ операцій за секунду - ідеально для real-time messaging між серверами."
      },
      {
        "question": "Що таке Pub/Sub у Redis?",
        "options": [
          "Тип бази даних",
          "Система зберігання файлів",
          "Messaging pattern: Publisher відправляє → Subscribers отримують",
          "Backup система"
        ],
        "correctAnswer": 2,
        "explanation": "Pub/Sub (Publish/Subscribe) - це pattern де Publisher відправляє повідомлення у channel, а всі Subscribers цього каналу отримують його одночасно."
      },
      {
        "question": "Скільки повідомлень за 5 секунд рекомендовано для rate limiting?",
        "options": [
          "1 повідомлення",
          "3 повідомлення",
          "10 повідомлень",
          "Необмежено"
        ],
        "correctAnswer": 1,
        "explanation": "3 повідомлення за 5 секунд - оптимальний баланс між захистом від спаму та комфортним спілкуванням."
      },
      {
        "question": "Чому Redis subscriber запускається у окремому thread?",
        "options": [
          "Для швидкості",
          "jedis.subscribe() - БЛОКУЮЧИЙ виклик",
          "Так вимагає Bukkit API",
          "Для економії пам''яті"
        ],
        "correctAnswer": 1,
        "explanation": "jedis.subscribe() є блокуючим викликом - він чекає повідомлень нескінченно. Тому запускаємо у окремому thread, щоб не блокувати main thread."
      },
      {
        "question": "Яка правильна naming convention для Redis channels?",
        "options": [
          "chat, staff, admin",
          "network:global-chat, network:staff-chat",
          "ch1, ch2, ch3",
          "Будь-яка назва"
        ],
        "correctAnswer": 1,
        "explanation": "Використовуємо hierarchical naming: network:global-chat, network:staff-chat. Це дозволяє використовувати wildcard subscriptions (network:*)."
      },
      {
        "question": "Що таке JedisPool і навіщо він потрібен?",
        "options": [
          "Backup для Redis",
          "Connection pool для reuse підключень",
          "Тип бази даних",
          "Альтернатива Redis"
        ],
        "correctAnswer": 1,
        "explanation": "JedisPool - це connection pool. Створює pool підключень до Redis і reuse їх, замість створювати нове підключення для кожної операції (швидше + ефективніше)."
      },
      {
        "question": "Як правильно зберігати mute у Redis?",
        "options": [
          "У звичайній базі MySQL",
          "У файлі config.yml",
          "Redis key з TTL (автоматичне видалення)",
          "У пам''яті сервера"
        ],
        "correctAnswer": 2,
        "explanation": "Використовуємо Redis key з TTL (Time To Live). Redis автоматично видалить ключ після закінчення часу mute. Для permanent mute - без TTL."
      },
      {
        "question": "Що робить CapsFilter?",
        "options": [
          "Видаляє капслок",
          "Перевіряє ratio КАПСЛОКУ (>70% = spam)",
          "Конвертує у lowercase",
          "Блокує всі великі літери"
        ],
        "correctAnswer": 1,
        "explanation": "CapsFilter перевіряє відсоток КАПСЛОКУ у повідомленні. Якщо >70% - це вважається спамом і нормалізується (Hello world замість HELLO WORLD)."
      },
      {
        "question": "Навіщо потрібен BadWordFilter.containsBadWordAdvanced()?",
        "options": [
          "Для швидкості",
          "Виявляє обходи фільтра (b@dw0rd → badword)",
          "Для інших мов",
          "Для зберігання слів"
        ],
        "correctAnswer": 1,
        "explanation": "Advanced фільтр нормалізує текст (видаляє спецсимволи, замінює цифри на літери) щоб виявити спроби обійти фільтр типу b@dw0rd або bad_word."
      },
      {
        "question": "Що таке Redis Streams і для чого використовуємо?",
        "options": [
          "Video streaming",
          "Log структура для зберігання chat історії",
          "Альтернатива Pub/Sub",
          "Система backup"
        ],
        "correctAnswer": 1,
        "explanation": "Redis Streams - це log-like структура даних. Ідеально для зберігання chat історії: додаємо нові записи, можемо читати останні N повідомлень, автоматично trim старих."
      },
      {
        "question": "Чому async chat event (AsyncPlayerChatEvent)?",
        "options": [
          "Для краси коду",
          "Chat обробляється async → не блокує server tick",
          "Вимога Spigot",
          "Для Redis підключення"
        ],
        "correctAnswer": 1,
        "explanation": "AsyncPlayerChatEvent виконується в async thread, не блокуючи main server thread. Це дозволяє виконувати повільні операції (Redis, database) без впливу на TPS."
      },
      {
        "question": "Як реалізувати LOCAL chat (тільки цей сервер)?",
        "options": [
          "Окремий Redis channel",
          "Не публікувати у Redis, тільки Bukkit broadcast",
          "MySQL таблиця",
          "Velocity plugin"
        ],
        "correctAnswer": 1,
        "explanation": "LOCAL chat не публікується у Redis. Просто broadcast повідомлення всім гравцям на поточному сервері через Bukkit API."
      },
      {
        "question": "Що робить jedis.expire(key, seconds)?",
        "options": [
          "Видаляє ключ",
          "Встановлює TTL - auto-delete через X секунд",
          "Оновлює значення",
          "Backup ключа"
        ],
        "correctAnswer": 1,
        "explanation": "expire() встановлює TTL (Time To Live). Через вказану кількість секунд Redis автоматично видалить цей ключ. Ідеально для temporary mute, cooldowns, rate limiting."
      },
      {
        "question": "Навіщо Bukkit.getScheduler().runTask() у onMessage()?",
        "options": [
          "Для швидкості",
          "Redis callback у async thread → треба перейти у main thread",
          "Обов''язкова вимога Redis",
          "Для logging"
        ],
        "correctAnswer": 1,
        "explanation": "Redis subscriber працює в окремому thread. onMessage() викликається у Redis thread, але Bukkit API (sendMessage, etc) треба викликати у main thread. runTask() переносить виконання у main thread."
      },
      {
        "question": "Яка перевага pipeline у Redis?",
        "options": [
          "Автоматичний backup",
          "1000 операцій за 1 network roundtrip (швидше)",
          "Більше пам''яті",
          "Кращий logging"
        ],
        "correctAnswer": 1,
        "explanation": "Pipeline дозволяє згрупувати багато операцій і відправити їх за один network roundtrip. Замість 1000 network calls робимо 1 call з 1000 командами - набагато швидше!"
      }
    ]',
    600,
    8,
    false
  );

  RAISE NOTICE 'Module 4 completed with Quiz!';
END $$;
