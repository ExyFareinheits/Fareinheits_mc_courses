-- =============================================
-- Модуль 2: Spigot/Paper API глибоке вивчення
-- =============================================

-- Урок 2.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-2', 'lesson-2-1',
  'Bukkit vs Spigot vs Paper',
  '12 хв', 'text',
  '# Різниця між Bukkit, Spigot та Paper

Розберемо еволюцію серверного API для Minecraft.

## Історія

### Bukkit (2010-2014)
- Перший популярний API для плагінів
- Створив стандарт розробки
- Проект закритий у 2014 через DMCA

### Spigot (2012-зараз)
- Fork Bukkit з оптимізаціями
- Зворотно сумісний з Bukkit API
- Додав власні можливості (SpigotAPI)
- Активно підтримується

### Paper (2016-зараз)
- Fork Spigot з ще більшими оптимізаціями
- Виправлення багів Mojang
- Додаткові API можливості (PaperAPI)
- Найкраща продуктивність
- Рекомендовано для продакшн серверів

## Порівняння API

```java
// Bukkit API (доступно скрізь)
import org.bukkit.Bukkit;
import org.bukkit.entity.Player;
import org.bukkit.event.player.PlayerJoinEvent;

// Spigot API (тільки на Spigot+)
import org.spigotmc.SpigotConfig;
import net.md_5.bungee.api.ChatColor;

// Paper API (тільки на Paper)
import com.destroystokyo.paper.event.player.PlayerJumpEvent;
import io.papermc.paper.entity.LookAnchor;
```

## Що використовувати?

### Для максимальної сумісності:
```xml
<dependency>
    <groupId>org.bukkit</groupId>
    <artifactId>bukkit</artifactId>
    <version>1.20.4-R0.1-SNAPSHOT</version>
</dependency>
```
✅ Працює на Bukkit, Spigot, Paper, Purpur

### Для оптимізацій Spigot:
```xml
<dependency>
    <groupId>org.spigotmc</groupId>
    <artifactId>spigot-api</artifactId>
    <version>1.20.4-R0.1-SNAPSHOT</version>
</dependency>
```
✅ Працює на Spigot, Paper, Purpur

### Для просунутих можливостей:
```xml
<dependency>
    <groupId>io.papermc.paper</groupId>
    <artifactId>paper-api</artifactId>
    <version>1.20.4-R0.1-SNAPSHOT</version>
</dependency>
```
✅ Працює тільки на Paper, Purpur

## Практичні відмінності

### Компоненти (Paper)
```java
// Spigot API
player.sendMessage("§aПривіт!");

// Paper API (краще)
player.sendMessage(Component.text("Привіт!", NamedTextColor.GREEN));
```

### Async операції (Paper)
```java
// Paper має кращу підтримку async
Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
    // Важка операція
});

// Paper specific
plugin.getServer().getAsyncScheduler().runNow(() -> {
    // Ще краща async підтримка
});
```

## Рекомендації для курсу

Ми будемо використовувати **Spigot API** як базу:
- ✅ Широка сумісність
- ✅ Доступні оптимізації
- ✅ Працює на більшості серверів

З можливістю upgrade до Paper API у спеціальних випадках.

## Налаштування проекту

Оновіть ваш `pom.xml`:
```xml
<repositories>
    <repository>
        <id>spigot-repo</id>
        <url>https://hub.spigotmc.org/nexus/content/repositories/snapshots/</url>
    </repository>
</repositories>

<dependencies>
    <dependency>
        <groupId>org.spigotmc</groupId>
        <artifactId>spigot-api</artifactId>
        <version>1.20.4-R0.1-SNAPSHOT</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

**Important:** `scope>provided</scope>` означає що API вже є на сервері!',
  1, FALSE
);

-- Урок 2.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-2', 'lesson-2-2',
  'Основні класи та інтерфейси',
  '18 хв', 'text',
  '# Основні класи Bukkit API

Розберемо найважливіші класи для розробки плагінів.

## JavaPlugin - Головний клас

```java
public class MyPlugin extends JavaPlugin {
    
    @Override
    public void onEnable() {
        // Викликається при увімкненні
        getLogger().info("Plugin enabled!");
        
        // Реєстрація команд
        getCommand("heal").setExecutor(new HealCommand());
        
        // Реєстрація подій
        getServer().getPluginManager().registerEvents(new JoinListener(), this);
        
        // Завантаження конфігу
        saveDefaultConfig();
    }
    
    @Override
    public void onDisable() {
        // Викликається при вимкненні
        getLogger().info("Plugin disabled!");
        
        // Збереження даних
        saveConfig();
    }
    
    @Override
    public void onLoad() {
        // Викликається ДО onEnable
        // Рідко використовується
    }
}
```

## Bukkit - Статичний доступ

```java
// Доступ до сервера
Server server = Bukkit.getServer();

// Гравці онлайн
Collection<? extends Player> players = Bukkit.getOnlinePlayers();

// Конкретний гравець
Player player = Bukkit.getPlayer("Steve");
Player playerByUUID = Bukkit.getPlayer(uuid);

// Світи
World world = Bukkit.getWorld("world");
List<World> worlds = Bukkit.getWorlds();

// Scheduler (таймери)
BukkitScheduler scheduler = Bukkit.getScheduler();

// Плагін менеджер
PluginManager pm = Bukkit.getPluginManager();
```

## Player - Робота з гравцем

```java
public void handlePlayer(Player player) {
    // Базова інформація
    String name = player.getName();
    UUID uuid = player.getUniqueId();
    String displayName = player.getDisplayName();
    
    // Здоров''я та їжа
    double health = player.getHealth();
    player.setHealth(20.0);
    int foodLevel = player.getFoodLevel();
    player.setFoodLevel(20);
    
    // Gamemode
    GameMode mode = player.getGameMode();
    player.setGameMode(GameMode.CREATIVE);
    
    // Локація
    Location loc = player.getLocation();
    World world = player.getWorld();
    player.teleport(new Location(world, 0, 64, 0));
    
    // Інвентар
    PlayerInventory inv = player.getInventory();
    ItemStack hand = player.getInventory().getItemInMainHand();
    
    // Ефекти
    player.addPotionEffect(new PotionEffect(
        PotionEffectType.SPEED, 200, 1
    ));
    
    // Повідомлення
    player.sendMessage("Привіт!");
    player.sendTitle("Заголовок", "Підзаголовок", 10, 70, 20);
    player.playSound(player.getLocation(), Sound.ENTITY_PLAYER_LEVELUP, 1.0f, 1.0f);
    
    // Права
    boolean isOp = player.isOp();
    boolean hasPerm = player.hasPermission("myplugin.admin");
}
```

## Location - Позиція у світі

```java
// Створення локації
World world = Bukkit.getWorld("world");
Location loc = new Location(world, 100, 64, 200);

// З напрямком (yaw/pitch)
Location spawn = new Location(world, 0, 64, 0, 90.0f, 0.0f);

// Отримання координат
double x = loc.getX();
double y = loc.getY();
double z = loc.getZ();
int blockX = loc.getBlockX(); // Цілі координати

// Робота з блоками
Block block = loc.getBlock();
block.setType(Material.DIAMOND_BLOCK);

// Відстань між точками
double distance = loc.distance(otherLoc);

// Направлення
Vector direction = loc.getDirection();
```

## World - Світ

```java
World world = Bukkit.getWorld("world");

// Час та погода
world.setTime(6000); // Полудень
world.setStorm(true);
world.setThundering(true);

// Spawn point
Location spawn = world.getSpawnLocation();
world.setSpawnLocation(100, 64, 200);

// Сутності
List<Entity> entities = world.getEntities();
world.spawn(location, Zombie.class);

// Блоки
Block block = world.getBlockAt(100, 64, 200);

// Звуки та ефекти
world.playSound(location, Sound.ENTITY_ENDER_DRAGON_GROWL, 1.0f, 1.0f);
world.spawnParticle(Particle.HEART, location, 10);

// Difficulty
world.setDifficulty(Difficulty.HARD);
```

## ItemStack - Предмет

```java
// Створення предмету
ItemStack sword = new ItemStack(Material.DIAMOND_SWORD);
ItemStack apples = new ItemStack(Material.APPLE, 64);

// ItemMeta - метадані
ItemMeta meta = sword.getItemMeta();
meta.setDisplayName(ChatColor.GOLD + "Legendary Sword");
meta.setLore(Arrays.asList(
    ChatColor.GRAY + "A powerful weapon",
    ChatColor.RED + "+10 Damage"
));
sword.setItemMeta(meta);

// Enchantments
sword.addEnchantment(Enchantment.SHARPNESS, 5);
sword.addUnsafeEnchantment(Enchantment.KNOCKBACK, 10);

// Перевірки
boolean isSword = sword.getType().toString().contains("SWORD");
int amount = sword.getAmount();
```

## Практичне завдання

Створіть клас `PlayerUtils` з методами:
```java
public class PlayerUtils {
    // Зцілити гравця повністю
    public static void healPlayer(Player player) {}
    
    // Дати стартовий кіт
    public static void giveStarterKit(Player player) {}
    
    // Телепортувати до іншого гравця
    public static void teleportTo(Player player, Player target) {}
    
    // Перевірити чи в безпечній зоні
    public static boolean isInSafeZone(Location loc) {}
}
```',
  2, FALSE
);

-- Урок 2.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-2', 'lesson-2-3',
  'Робота з конфігурацією плагіну',
  '15 хв', 'text',
  '# Конфігурація плагіну

FileConfiguration - система зберігання налаштувань.

## Створення config.yml

`src/main/resources/config.yml`:
```yaml
# Загальні налаштування
plugin:
  enabled: true
  debug-mode: false
  language: uk

# Повідомлення
messages:
  prefix: "&a[MyPlugin]&r"
  welcome: "&eВітаємо на сервері!"
  no-permission: "&cУ вас немає прав!"

# Економіка
economy:
  starting-balance: 1000
  currency-symbol: "$"
  
# Список світів
worlds:
  - world
  - world_nether
  - world_the_end

# Складні об''єкти
spawn:
  world: world
  x: 0
  y: 64
  z: 0
  yaw: 0
  pitch: 0
```

## Завантаження конфігу

```java
public class MyPlugin extends JavaPlugin {
    
    @Override
    public void onEnable() {
        // Створити config.yml якщо не існує
        saveDefaultConfig();
        
        // Перезавантажити конфіг
        reloadConfig();
        
        // Отримати значення
        FileConfiguration config = getConfig();
        
        boolean enabled = config.getBoolean("plugin.enabled");
        String language = config.getString("plugin.language");
        int startBalance = config.getInt("economy.starting-balance");
        
        // Список
        List<String> worlds = config.getStringList("worlds");
        
        // З дефолтним значенням
        double multiplier = config.getDouble("economy.multiplier", 1.0);
    }
}
```

## Робота зі значеннями

```java
FileConfiguration config = getConfig();

// Читання
String prefix = config.getString("messages.prefix");
boolean debug = config.getBoolean("plugin.debug-mode");
int balance = config.getInt("economy.starting-balance");
List<String> worlds = config.getStringList("worlds");

// Перевірка існування
if (config.contains("spawn.world")) {
    // Значення існує
}

// Отримання секції
ConfigurationSection spawn = config.getConfigurationSection("spawn");
String world = spawn.getString("world");
double x = spawn.getDouble("x");

// Запис
config.set("plugin.enabled", true);
config.set("messages.new-message", "Test");
saveConfig();
```

## Кастомні конфіг файли

```java
public class CustomConfigManager {
    private final JavaPlugin plugin;
    private File dataFile;
    private FileConfiguration dataConfig;
    
    public CustomConfigManager(JavaPlugin plugin) {
        this.plugin = plugin;
        createDataFile();
    }
    
    private void createDataFile() {
        dataFile = new File(plugin.getDataFolder(), "data.yml");
        if (!dataFile.exists()) {
            dataFile.getParentFile().mkdirs();
            plugin.saveResource("data.yml", false);
        }
        
        dataConfig = YamlConfiguration.loadConfiguration(dataFile);
    }
    
    public FileConfiguration getDataConfig() {
        return dataConfig;
    }
    
    public void saveData() {
        try {
            dataConfig.save(dataFile);
        } catch (IOException e) {
            plugin.getLogger().severe("Could not save data.yml!");
        }
    }
    
    public void reloadData() {
        dataConfig = YamlConfiguration.loadConfiguration(dataFile);
    }
}

// Використання
CustomConfigManager dataManager = new CustomConfigManager(this);
FileConfiguration data = dataManager.getDataConfig();
data.set("players." + uuid + ".kills", 10);
dataManager.saveData();
```

## Збереження Location у конфіг

```java
public class LocationUtil {
    
    public static void saveLocation(FileConfiguration config, String path, Location loc) {
        config.set(path + ".world", loc.getWorld().getName());
        config.set(path + ".x", loc.getX());
        config.set(path + ".y", loc.getY());
        config.set(path + ".z", loc.getZ());
        config.set(path + ".yaw", loc.getYaw());
        config.set(path + ".pitch", loc.getPitch());
    }
    
    public static Location loadLocation(FileConfiguration config, String path) {
        String worldName = config.getString(path + ".world");
        World world = Bukkit.getWorld(worldName);
        
        if (world == null) return null;
        
        double x = config.getDouble(path + ".x");
        double y = config.getDouble(path + ".y");
        double z = config.getDouble(path + ".z");
        float yaw = (float) config.getDouble(path + ".yaw");
        float pitch = (float) config.getDouble(path + ".pitch");
        
        return new Location(world, x, y, z, yaw, pitch);
    }
}

// Використання
LocationUtil.saveLocation(config, "spawn", spawnLocation);
Location spawn = LocationUtil.loadLocation(config, "spawn");
```

## Практичне завдання

Створіть систему варпів (телепортів):
- Збереження варпів у конфіг
- Команда `/setwarp <name>` - створити варп
- Команда `/warp <name>` - телепортуватися
- Команда `/delwarp <name>` - видалити варп
- Команда `/warps` - список всіх варпів',
  3, FALSE
);

-- Квіз для Модуля 2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-2', 'lesson-2-4',
  'Тест: Spigot API',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-2-4",
    "questions": [
      {
        "id": "q1",
        "question": "Яка різниця між Spigot та Paper?",
        "options": [
          "Paper - це старіша версія Spigot",
          "Paper має кращу оптимізацію та більше API",
          "Spigot швидший за Paper",
          "Різниці немає"
        ],
        "correctAnswer": 1,
        "explanation": "Paper - це fork Spigot з додатковими оптимізаціями, виправленнями багів та розширеним API"
      },
      {
        "id": "q2",
        "question": "Який метод викликається першим при завантаженні плагіну?",
        "options": ["onEnable()", "onLoad()", "onStart()", "initialize()"],
        "correctAnswer": 1,
        "explanation": "onLoad() викликається перед onEnable(), але рідко використовується"
      },
      {
        "id": "q3",
        "question": "Як отримати всіх гравців онлайн?",
        "options": [
          "Bukkit.getPlayers()",
          "Bukkit.getOnlinePlayers()",
          "Server.getPlayers()",
          "Player.getAll()"
        ],
        "correctAnswer": 1,
        "explanation": "Bukkit.getOnlinePlayers() повертає колекцію всіх гравців онлайн"
      },
      {
        "id": "q4",
        "question": "Що означає scope provided у Maven?",
        "options": [
          "Залежність буде включена в JAR",
          "Залежність вже є на сервері",
          "Залежність опціональна",
          "Залежність тільки для тестів"
        ],
        "correctAnswer": 1,
        "explanation": "provided означає що залежність (Spigot API) вже є на сервері і не потрібно включати її в плагін"
      },
      {
        "id": "q5",
        "question": "Який файл використовується для налаштувань плагіну?",
        "options": ["settings.yml", "plugin.yml", "config.yml", "data.yml"],
        "correctAnswer": 2,
        "explanation": "config.yml - стандартний файл для налаштувань плагіну, а plugin.yml - для метаданих"
      }
    ]
  }'::jsonb,
  4, FALSE
);

-- =============================================
-- Перевірка
-- =============================================

SELECT 'Модуль 2 додано! 4 уроки створено.' as status;
