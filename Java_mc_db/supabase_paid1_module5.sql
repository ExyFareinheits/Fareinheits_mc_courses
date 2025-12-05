-- =============================================
-- Модуль 5: Робота з конфігами (YAML, JSON)
-- =============================================

-- Урок 5.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-5', 'lesson-5-1',
  'YAML конфігурація - основи',
  '16 хв', 'text',
  '# Робота з YAML конфігами

YAML - стандартний формат для налаштувань Minecraft плагінів.

## Структура config.yml

Створіть `src/main/resources/config.yml`:
```yaml
# Загальні налаштування
plugin:
  language: uk
  debug: false
  auto-save: true

# Повідомлення
messages:
  prefix: "&6[MyPlugin]&r"
  welcome: "&aВітаємо на сервері!"
  no-permission: "&cУ вас немає прав!"
  
# Налаштування spawn
spawn:
  world: world
  x: 0.5
  y: 64.0
  z: 0.5
  yaw: 0.0
  pitch: 0.0
  
# Список заборонених предметів
banned-items:
  - TNT
  - LAVA_BUCKET
  - BEDROCK
  
# Економіка
economy:
  starting-balance: 1000.0
  max-balance: 999999999.0
  currency-symbol: "$"
```

## Читання конфігу

```java
public class MyPlugin extends JavaPlugin {
    
    @Override
    public void onEnable() {
        // Зберегти config.yml з ресурсів якщо його немає
        saveDefaultConfig();
        
        // Читання значень
        String language = getConfig().getString("plugin.language");
        boolean debug = getConfig().getBoolean("plugin.debug");
        
        String prefix = getConfig().getString("messages.prefix");
        String welcome = getConfig().getString("messages.welcome");
        
        double startBalance = getConfig().getDouble("economy.starting-balance");
        
        // Список
        List<String> bannedItems = getConfig().getStringList("banned-items");
        
        getLogger().info("Мова: " + language);
        getLogger().info("Debug: " + debug);
        getLogger().info("Заборонених предметів: " + bannedItems.size());
    }
}
```

## Запис у конфіг

```java
public void savePlayerData(Player player) {
    String path = "players." + player.getUniqueId().toString();
    
    // Записати значення
    getConfig().set(path + ".name", player.getName());
    getConfig().set(path + ".level", 10);
    getConfig().set(path + ".balance", 1500.50);
    getConfig().set(path + ".vip", true);
    
    // Зберегти у файл
    saveConfig();
}
```

## Перевірка існування

```java
if (getConfig().contains("spawn.world")) {
    String world = getConfig().getString("spawn.world");
}

// З дефолтним значенням
String lang = getConfig().getString("plugin.language", "en");
int level = getConfig().getInt("player.level", 1);
```

## Робота зі складними об''єктами

```java
// Зберегти Location
public void saveLocation(String path, Location loc) {
    getConfig().set(path + ".world", loc.getWorld().getName());
    getConfig().set(path + ".x", loc.getX());
    getConfig().set(path + ".y", loc.getY());
    getConfig().set(path + ".z", loc.getZ());
    getConfig().set(path + ".yaw", loc.getYaw());
    getConfig().set(path + ".pitch", loc.getPitch());
    saveConfig();
}

// Завантажити Location
public Location loadLocation(String path) {
    if (!getConfig().contains(path + ".world")) {
        return null;
    }
    
    World world = Bukkit.getWorld(getConfig().getString(path + ".world"));
    double x = getConfig().getDouble(path + ".x");
    double y = getConfig().getDouble(path + ".y");
    double z = getConfig().getDouble(path + ".z");
    float yaw = (float) getConfig().getDouble(path + ".yaw");
    float pitch = (float) getConfig().getDouble(path + ".pitch");
    
    return new Location(world, x, y, z, yaw, pitch);
}
```

## ConfigurationSection

Для роботи з розділами:
```java
ConfigurationSection messagesSection = getConfig().getConfigurationSection("messages");

if (messagesSection != null) {
    // Отримати всі ключі в розділі
    Set<String> keys = messagesSection.getKeys(false);
    
    for (String key : keys) {
        String message = messagesSection.getString(key);
        getLogger().info(key + ": " + message);
    }
}
```

## Приклад: Система кітів

config.yml:
```yaml
kits:
  starter:
    permission: "plugin.kit.starter"
    cooldown: 0
    items:
      - "STONE_SWORD:1"
      - "STONE_PICKAXE:1"
      - "BREAD:16"
      
  pvp:
    permission: "plugin.kit.pvp"
    cooldown: 3600
    items:
      - "DIAMOND_SWORD:1:SHARPNESS:5"
      - "DIAMOND_HELMET:1:PROTECTION:4"
      - "DIAMOND_CHESTPLATE:1:PROTECTION:4"
      - "GOLDEN_APPLE:5"
```

Код:
```java
public class KitManager {
    private final JavaPlugin plugin;
    
    public KitManager(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    public void giveKit(Player player, String kitName) {
        String path = "kits." + kitName;
        
        if (!plugin.getConfig().contains(path)) {
            player.sendMessage("§cКіт не існує!");
            return;
        }
        
        // Перевірка прав
        String permission = plugin.getConfig().getString(path + ".permission");
        if (permission != null && !player.hasPermission(permission)) {
            player.sendMessage("§cУ вас немає доступу!");
            return;
        }
        
        // Отримати предмети
        List<String> items = plugin.getConfig().getStringList(path + ".items");
        
        for (String itemString : items) {
            ItemStack item = parseItem(itemString);
            if (item != null) {
                player.getInventory().addItem(item);
            }
        }
        
        player.sendMessage("§aВи отримали кіт: §e" + kitName);
    }
    
    private ItemStack parseItem(String itemString) {
        String[] parts = itemString.split(":");
        
        Material material = Material.valueOf(parts[0]);
        int amount = Integer.parseInt(parts[1]);
        
        ItemStack item = new ItemStack(material, amount);
        
        // Якщо є enchantments
        if (parts.length > 2) {
            Enchantment enchant = Enchantment.getByName(parts[2]);
            int level = Integer.parseInt(parts[3]);
            item.addUnsafeEnchantment(enchant, level);
        }
        
        return item;
    }
}
```

## Перезавантаження конфігу

```java
public class ReloadCommand implements CommandExecutor {
    
    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        // Перезавантажити config.yml
        plugin.reloadConfig();
        
        // Повторно завантажити дані з конфігу
        plugin.loadConfigData();
        
        sender.sendMessage("§aКонфіг перезавантажено!");
        return true;
    }
}
```

## Резервна копія конфігу

```java
public void backupConfig() {
    File configFile = new File(getDataFolder(), "config.yml");
    File backupFile = new File(getDataFolder(), "config_backup_" + 
        System.currentTimeMillis() + ".yml");
    
    try {
        Files.copy(configFile.toPath(), backupFile.toPath());
        getLogger().info("Конфіг збережено у: " + backupFile.getName());
    } catch (IOException e) {
        getLogger().severe("Помилка створення backup: " + e.getMessage());
    }
}
```

## Практичне завдання

Створіть систему warp-ів:
- Зберігання точок телепортації в config.yml
- Команда `/setwarp <назва>` - створити warp
- Команда `/warp <назва>` - телепортуватись
- Команда `/delwarp <назва>` - видалити
- Зберігати: назву, world, координати, дозвіл',
  1, FALSE
);

-- Урок 5.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-5', 'lesson-5-2',
  'Custom конфіги - окремі YAML файли',
  '14 хв', 'text',
  '# Створення кастомних конфігів

Для великих плагінів зручно мати кілька конфігураційних файлів.

## Клас для роботи з custom конфігами

```java
import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.configuration.file.YamlConfiguration;

import java.io.File;
import java.io.IOException;

public class CustomConfig {
    
    private final JavaPlugin plugin;
    private final String fileName;
    private File file;
    private FileConfiguration config;
    
    public CustomConfig(JavaPlugin plugin, String fileName) {
        this.plugin = plugin;
        this.fileName = fileName;
        
        // Створити файл якщо не існує
        createFile();
    }
    
    private void createFile() {
        file = new File(plugin.getDataFolder(), fileName);
        
        if (!file.exists()) {
            file.getParentFile().mkdirs();
            
            // Зберегти з ресурсів якщо існує
            if (plugin.getResource(fileName) != null) {
                plugin.saveResource(fileName, false);
            } else {
                try {
                    file.createNewFile();
                } catch (IOException e) {
                    plugin.getLogger().severe("Не вдалось створити " + fileName);
                }
            }
        }
        
        config = YamlConfiguration.loadConfiguration(file);
    }
    
    public FileConfiguration getConfig() {
        return config;
    }
    
    public void save() {
        try {
            config.save(file);
        } catch (IOException e) {
            plugin.getLogger().severe("Помилка збереження " + fileName);
        }
    }
    
    public void reload() {
        config = YamlConfiguration.loadConfiguration(file);
    }
}
```

## Використання

```java
public class MyPlugin extends JavaPlugin {
    
    private CustomConfig messagesConfig;
    private CustomConfig dataConfig;
    private CustomConfig warpsConfig;
    
    @Override
    public void onEnable() {
        // Створити custom конфіги
        messagesConfig = new CustomConfig(this, "messages.yml");
        dataConfig = new CustomConfig(this, "data.yml");
        warpsConfig = new CustomConfig(this, "warps.yml");
        
        // Використання
        String welcome = messagesConfig.getConfig().getString("welcome");
        
        // Запис
        dataConfig.getConfig().set("players.count", 100);
        dataConfig.save();
    }
    
    public CustomConfig getMessagesConfig() {
        return messagesConfig;
    }
}
```

## Структура з папками

```java
public class PlayerDataManager {
    
    private final JavaPlugin plugin;
    private final File dataFolder;
    
    public PlayerDataManager(JavaPlugin plugin) {
        this.plugin = plugin;
        this.dataFolder = new File(plugin.getDataFolder(), "playerdata");
        
        if (!dataFolder.exists()) {
            dataFolder.mkdirs();
        }
    }
    
    public void savePlayerData(Player player) {
        UUID uuid = player.getUniqueId();
        File file = new File(dataFolder, uuid.toString() + ".yml");
        FileConfiguration config = YamlConfiguration.loadConfiguration(file);
        
        // Зберегти дані
        config.set("name", player.getName());
        config.set("level", 10);
        config.set("exp", 5000);
        config.set("last-login", System.currentTimeMillis());
        
        try {
            config.save(file);
        } catch (IOException e) {
            plugin.getLogger().severe("Помилка збереження даних " + player.getName());
        }
    }
    
    public FileConfiguration loadPlayerData(UUID uuid) {
        File file = new File(dataFolder, uuid.toString() + ".yml");
        
        if (!file.exists()) {
            return null;
        }
        
        return YamlConfiguration.loadConfiguration(file);
    }
    
    public void deletePlayerData(UUID uuid) {
        File file = new File(dataFolder, uuid.toString() + ".yml");
        
        if (file.exists()) {
            file.delete();
        }
    }
}
```

## messages.yml - мультимовність

```yaml
# messages.yml
uk:
  prefix: "&6[Плагін]&r"
  welcome: "&aВітаємо!"
  goodbye: "&cДо побачення!"
  no-permission: "&cНемає прав!"
  
en:
  prefix: "&6[Plugin]&r"
  welcome: "&aWelcome!"
  goodbye: "&cGoodbye!"
  no-permission: "&cNo permission!"
  
pl:
  prefix: "&6[Plugin]&r"
  welcome: "&aWitaj!"
  goodbye: "&cDo widzenia!"
  no-permission: "&cBrak uprawnień!"
```

Менеджер повідомлень:
```java
public class MessageManager {
    
    private final CustomConfig messagesConfig;
    private String currentLanguage;
    
    public MessageManager(JavaPlugin plugin) {
        this.messagesConfig = new CustomConfig(plugin, "messages.yml");
        this.currentLanguage = plugin.getConfig().getString("language", "uk");
    }
    
    public String getMessage(String key) {
        String path = currentLanguage + "." + key;
        String message = messagesConfig.getConfig().getString(path);
        
        if (message == null) {
            // Fallback на англійську
            message = messagesConfig.getConfig().getString("en." + key, key);
        }
        
        return ChatColor.translateAlternateColorCodes(''&'', message);
    }
    
    public String getPrefix() {
        return getMessage("prefix");
    }
    
    public void sendMessage(Player player, String key) {
        player.sendMessage(getPrefix() + " " + getMessage(key));
    }
    
    public void setLanguage(String language) {
        this.currentLanguage = language;
    }
}

// Використання
messageManager.sendMessage(player, "welcome");
```

## shops.yml - складна структура

```yaml
shops:
  blocks:
    display-name: "&6Магазин блоків"
    icon: STONE
    items:
      stone:
        material: STONE
        buy-price: 10.0
        sell-price: 5.0
        display-name: "&fКамінь"
        
      dirt:
        material: DIRT
        buy-price: 5.0
        sell-price: 2.0
        display-name: "&6Земля"
        
  tools:
    display-name: "&6Магазин інструментів"
    icon: DIAMOND_PICKAXE
    items:
      diamond_pickaxe:
        material: DIAMOND_PICKAXE
        buy-price: 1000.0
        enchantments:
          EFFICIENCY: 5
          UNBREAKING: 3
        display-name: "&bАлмазна кирка"
```

Менеджер магазинів:
```java
public class ShopManager {
    
    private final CustomConfig shopsConfig;
    
    public ShopManager(JavaPlugin plugin) {
        this.shopsConfig = new CustomConfig(plugin, "shops.yml");
    }
    
    public void openShop(Player player, String shopId) {
        ConfigurationSection shopSection = shopsConfig.getConfig()
            .getConfigurationSection("shops." + shopId);
        
        if (shopSection == null) {
            player.sendMessage("§cМагазин не знайдений!");
            return;
        }
        
        String displayName = shopSection.getString("display-name");
        Inventory inv = Bukkit.createInventory(null, 54, 
            ChatColor.translateAlternateColorCodes(''&'', displayName));
        
        ConfigurationSection itemsSection = shopSection.getConfigurationSection("items");
        
        if (itemsSection != null) {
            int slot = 0;
            
            for (String itemKey : itemsSection.getKeys(false)) {
                ConfigurationSection itemSection = itemsSection.getConfigurationSection(itemKey);
                
                Material material = Material.valueOf(itemSection.getString("material"));
                double buyPrice = itemSection.getDouble("buy-price");
                String itemName = itemSection.getString("display-name");
                
                ItemStack item = new ItemStack(material);
                ItemMeta meta = item.getItemMeta();
                meta.setDisplayName(ChatColor.translateAlternateColorCodes(''&'', itemName));
                
                List<String> lore = new ArrayList<>();
                lore.add("§7Ціна: §a$" + buyPrice);
                lore.add("§eНатисніть для покупки");
                meta.setLore(lore);
                
                item.setItemMeta(meta);
                inv.setItem(slot++, item);
            }
        }
        
        player.openInventory(inv);
    }
}
```

## Автозбереження

```java
public class AutoSaveTask extends BukkitRunnable {
    
    private final JavaPlugin plugin;
    private final List<CustomConfig> configs;
    
    public AutoSaveTask(JavaPlugin plugin, CustomConfig... configs) {
        this.plugin = plugin;
        this.configs = Arrays.asList(configs);
    }
    
    @Override
    public void run() {
        for (CustomConfig config : configs) {
            config.save();
        }
        
        plugin.getLogger().info("Конфіги збережено!");
    }
}

// Запуск (кожні 5 хвилин = 6000 тіків)
@Override
public void onEnable() {
    new AutoSaveTask(this, dataConfig, warpsConfig)
        .runTaskTimerAsynchronously(this, 6000L, 6000L);
}
```

## Міграція старих конфігів

```java
public void migrateConfig() {
    int version = getConfig().getInt("config-version", 1);
    
    if (version < 2) {
        // Міграція на версію 2
        getLogger().info("Міграція конфігу до версії 2...");
        
        // Перенести старі значення
        if (getConfig().contains("old-key")) {
            String value = getConfig().getString("old-key");
            getConfig().set("new-key", value);
            getConfig().set("old-key", null);
        }
        
        getConfig().set("config-version", 2);
        saveConfig();
    }
    
    if (version < 3) {
        // Міграція на версію 3
        getLogger().info("Міграція конфігу до версії 3...");
        // ...
        getConfig().set("config-version", 3);
        saveConfig();
    }
}
```

## Практичне завдання

Створіть систему з 3 конфігами:
1. **config.yml** - основні налаштування
2. **kits.yml** - конфігурація наборів
3. **data/players/<uuid>.yml** - дані гравців

Реалізуйте:
- Завантаження всіх конфігів
- Автозбереження кожні 5 хвилин
- Команду `/reload` для перезавантаження',
  2, FALSE
);

-- Урок 5.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-5', 'lesson-5-3',
  'JSON конфігурація та інтеграція',
  '15 хв', 'text',
  '# Робота з JSON

JSON зручний для складних структур та API інтеграцій.

## Додати Gson до проекту

pom.xml:
```xml
<dependencies>
    <!-- Gson для JSON -->
    <dependency>
        <groupId>com.google.code.gson</groupId>
        <artifactId>gson</artifactId>
        <version>2.10.1</version>
    </dependency>
</dependencies>
```

## Основи Gson

```java
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class JsonExample {
    
    private static final Gson gson = new GsonBuilder()
        .setPrettyPrinting()
        .create();
    
    public void example() {
        // Об''єкт → JSON
        PlayerData data = new PlayerData("Steve", 10, 5000);
        String json = gson.toJson(data);
        
        // JSON → Об''єкт
        PlayerData loaded = gson.fromJson(json, PlayerData.class);
        
        System.out.println(json);
        // {
        //   "name": "Steve",
        //   "level": 10,
        //   "money": 5000.0
        // }
    }
}

class PlayerData {
    private String name;
    private int level;
    private double money;
    
    public PlayerData(String name, int level, double money) {
        this.name = name;
        this.level = level;
        this.money = money;
    }
    
    // getters/setters
}
```

## Збереження/Завантаження JSON файлу

```java
import java.io.*;
import java.nio.file.Files;

public class JsonFileManager {
    
    private static final Gson gson = new GsonBuilder()
        .setPrettyPrinting()
        .create();
    
    public static <T> void save(File file, T object) throws IOException {
        if (!file.exists()) {
            file.getParentFile().mkdirs();
            file.createNewFile();
        }
        
        try (Writer writer = new FileWriter(file)) {
            gson.toJson(object, writer);
        }
    }
    
    public static <T> T load(File file, Class<T> clazz) throws IOException {
        if (!file.exists()) {
            return null;
        }
        
        try (Reader reader = new FileReader(file)) {
            return gson.fromJson(reader, clazz);
        }
    }
}
```

## Приклад: Система гільдій

```java
public class Guild {
    private String name;
    private UUID ownerId;
    private List<UUID> members;
    private double bank;
    private Location home;
    private long createdAt;
    
    public Guild(String name, UUID ownerId) {
        this.name = name;
        this.ownerId = ownerId;
        this.members = new ArrayList<>();
        this.members.add(ownerId);
        this.bank = 0.0;
        this.createdAt = System.currentTimeMillis();
    }
    
    // getters/setters
}

public class GuildManager {
    
    private final JavaPlugin plugin;
    private final File guildsFolder;
    private final Map<String, Guild> guilds = new HashMap<>();
    
    public GuildManager(JavaPlugin plugin) {
        this.plugin = plugin;
        this.guildsFolder = new File(plugin.getDataFolder(), "guilds");
        
        if (!guildsFolder.exists()) {
            guildsFolder.mkdirs();
        }
        
        loadAllGuilds();
    }
    
    public void createGuild(String name, UUID ownerId) {
        Guild guild = new Guild(name, ownerId);
        guilds.put(name.toLowerCase(), guild);
        saveGuild(guild);
    }
    
    public void saveGuild(Guild guild) {
        File file = new File(guildsFolder, guild.getName().toLowerCase() + ".json");
        
        try {
            JsonFileManager.save(file, guild);
        } catch (IOException e) {
            plugin.getLogger().severe("Помилка збереження гільдії: " + guild.getName());
        }
    }
    
    public Guild loadGuild(String name) {
        File file = new File(guildsFolder, name.toLowerCase() + ".json");
        
        try {
            return JsonFileManager.load(file, Guild.class);
        } catch (IOException e) {
            plugin.getLogger().severe("Помилка завантаження гільдії: " + name);
            return null;
        }
    }
    
    private void loadAllGuilds() {
        File[] files = guildsFolder.listFiles((dir, name) -> name.endsWith(".json"));
        
        if (files == null) return;
        
        for (File file : files) {
            String guildName = file.getName().replace(".json", "");
            Guild guild = loadGuild(guildName);
            
            if (guild != null) {
                guilds.put(guildName, guild);
            }
        }
        
        plugin.getLogger().info("Завантажено гільдій: " + guilds.size());
    }
    
    public void saveAll() {
        for (Guild guild : guilds.values()) {
            saveGuild(guild);
        }
    }
}
```

## Custom серіалізація

```java
public class LocationAdapter implements JsonSerializer<Location>, JsonDeserializer<Location> {
    
    @Override
    public JsonElement serialize(Location loc, Type type, JsonSerializationContext context) {
        JsonObject obj = new JsonObject();
        obj.addProperty("world", loc.getWorld().getName());
        obj.addProperty("x", loc.getX());
        obj.addProperty("y", loc.getY());
        obj.addProperty("z", loc.getZ());
        obj.addProperty("yaw", loc.getYaw());
        obj.addProperty("pitch", loc.getPitch());
        return obj;
    }
    
    @Override
    public Location deserialize(JsonElement json, Type type, JsonDeserializationContext context) {
        JsonObject obj = json.getAsJsonObject();
        
        World world = Bukkit.getWorld(obj.get("world").getAsString());
        double x = obj.get("x").getAsDouble();
        double y = obj.get("y").getAsDouble();
        double z = obj.get("z").getAsDouble();
        float yaw = obj.get("yaw").getAsFloat();
        float pitch = obj.get("pitch").getAsFloat();
        
        return new Location(world, x, y, z, yaw, pitch);
    }
}

// Реєстрація адаптера
private static final Gson gson = new GsonBuilder()
    .setPrettyPrinting()
    .registerTypeAdapter(Location.class, new LocationAdapter())
    .create();
```

## Серіалізація ItemStack

```java
public class ItemStackAdapter implements JsonSerializer<ItemStack>, JsonDeserializer<ItemStack> {
    
    @Override
    public JsonElement serialize(ItemStack item, Type type, JsonSerializationContext context) {
        JsonObject obj = new JsonObject();
        obj.addProperty("type", item.getType().name());
        obj.addProperty("amount", item.getAmount());
        
        if (item.hasItemMeta()) {
            ItemMeta meta = item.getItemMeta();
            
            if (meta.hasDisplayName()) {
                obj.addProperty("displayName", meta.getDisplayName());
            }
            
            if (meta.hasLore()) {
                obj.add("lore", context.serialize(meta.getLore()));
            }
            
            if (meta.hasEnchants()) {
                JsonObject enchants = new JsonObject();
                for (Map.Entry<Enchantment, Integer> entry : meta.getEnchants().entrySet()) {
                    enchants.addProperty(entry.getKey().getKey().getKey(), entry.getValue());
                }
                obj.add("enchantments", enchants);
            }
        }
        
        return obj;
    }
    
    @Override
    public ItemStack deserialize(JsonElement json, Type type, JsonDeserializationContext context) {
        JsonObject obj = json.getAsJsonObject();
        
        Material material = Material.valueOf(obj.get("type").getAsString());
        int amount = obj.get("amount").getAsInt();
        
        ItemStack item = new ItemStack(material, amount);
        ItemMeta meta = item.getItemMeta();
        
        if (obj.has("displayName")) {
            meta.setDisplayName(obj.get("displayName").getAsString());
        }
        
        if (obj.has("lore")) {
            List<String> lore = context.deserialize(obj.get("lore"), 
                new TypeToken<List<String>>(){}.getType());
            meta.setLore(lore);
        }
        
        if (obj.has("enchantments")) {
            JsonObject enchants = obj.getAsJsonObject("enchantments");
            for (Map.Entry<String, JsonElement> entry : enchants.entrySet()) {
                Enchantment enchant = Enchantment.getByKey(NamespacedKey.minecraft(entry.getKey()));
                int level = entry.getValue().getAsInt();
                meta.addEnchant(enchant, level, true);
            }
        }
        
        item.setItemMeta(meta);
        return item;
    }
}
```

## API запити з JSON

```java
import java.net.HttpURLConnection;
import java.net.URL;

public class ApiClient {
    
    private static final Gson gson = new Gson();
    
    public static PlayerProfile fetchPlayerProfile(String username) {
        try {
            URL url = new URL("https://api.example.com/player/" + username);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            
            if (conn.getResponseCode() == 200) {
                try (Reader reader = new InputStreamReader(conn.getInputStream())) {
                    return gson.fromJson(reader, PlayerProfile.class);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return null;
    }
}

class PlayerProfile {
    private String username;
    private String uuid;
    private long joinDate;
    private Map<String, Object> stats;
    
    // getters
}
```

## Порівняння YAML vs JSON

**YAML переваги:**
- Легше читати людям
- Підтримується нативно в Bukkit
- Стандарт для Minecraft плагінів
- Коментарі

**JSON переваги:**
- Швидша обробка
- Менший розмір файлів
- Краще для складних структур
- Зручніше для API
- Сувора структура (менше помилок)

**Коли використовувати:**
- **YAML**: config.yml, messages.yml, прості налаштування
- **JSON**: дані гравців, складні об''єкти, кеш, API

## Практичне завдання

Створіть систему статистики гравців:
- Клас `PlayerStats` (kills, deaths, playtime, etc.)
- Збереження у JSON (playerdata/<uuid>.json)
- Адаптери для Location та ItemStack
- Топ-10 гравців за різними параметрами
- API endpoint для отримання статистики',
  3, FALSE
);

-- Квіз для Модуля 5
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-5', 'lesson-5-4',
  'Тест: Конфігурації YAML та JSON',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-5-4",
    "questions": [
      {
        "id": "q1",
        "question": "Який метод зберігає дефолтний config.yml з ресурсів?",
        "options": ["createConfig()", "saveDefaultConfig()", "saveConfig()", "loadConfig()"],
        "correctAnswer": 1,
        "explanation": "saveDefaultConfig() копіює config.yml з ресурсів плагіну у data folder"
      },
      {
        "id": "q2",
        "question": "Як отримати значення з config.yml з дефолтним fallback?",
        "options": [
          "getConfig().get(\"key\", default)",
          "getConfig().getString(\"key\", default)",
          "getConfig().getOrDefault(\"key\", default)",
          "getConfig().value(\"key\", default)"
        ],
        "correctAnswer": 1,
        "explanation": "getString(key, defaultValue) повертає значення або дефолт якщо ключ не існує"
      },
      {
        "id": "q3",
        "question": "Який клас використовується для роботи з JSON у Java?",
        "options": ["Jackson", "Gson", "JSON-Simple", "Bukkit JSON"],
        "correctAnswer": 1,
        "explanation": "Gson від Google - найпопулярніша бібліотека для роботи з JSON"
      },
      {
        "id": "q4",
        "question": "Що робить FileConfiguration.save()?",
        "options": [
          "Зберігає конфіг у пам''ять",
          "Зберігає конфіг у файл на диску",
          "Перезавантажує конфіг",
          "Створює backup конфігу"
        ],
        "correctAnswer": 1,
        "explanation": "save() записує зміни з пам''яті у YAML файл на диску"
      },
      {
        "id": "q5",
        "question": "Коли краще використовувати JSON замість YAML?",
        "options": [
          "Для основних налаштувань плагіну",
          "Для повідомлень гравцям",
          "Для складних структур даних та API",
          "Завжди краще YAML"
        ],
        "correctAnswer": 2,
        "explanation": "JSON кращий для складних об''єктів, швидкої обробки, API інтеграцій та серіалізації"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 5 додано! 4 уроки створено.' as status;
