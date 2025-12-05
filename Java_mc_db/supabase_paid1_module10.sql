-- =============================================
-- Модуль 10: Публікація плагінів та Best Practices
-- =============================================

-- Урок 10.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-10', 'lesson-10-1',
  'GitHub - версіонування та співпраця',
  '18 хв', 'text',
  '# Git та GitHub для Minecraft плагінів

Версіонування коду та співпраця з іншими розробниками.

## Налаштування Git

```bash
# Встановити Git
# Завантажити з: https://git-scm.com/

# Налаштувати ім''я та email
git config --global user.name "Ваше Ім''я"
git config --global user.email "your.email@example.com"

# Перевірити конфігурацію
git config --list
```

## .gitignore для Minecraft плагінів

```gitignore
# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml

# Gradle
.gradle/
build/
out/

# IDE
.idea/
*.iml
.vscode/
.settings/
.project
.classpath

# OS
.DS_Store
Thumbs.db

# Compiled
*.class
*.jar

# Logs
logs/
*.log

# Config (містить паролі БД)
config.yml
database.yml

# Test servers
test-server/
```

## Ініціалізація репозиторію

```bash
# Створити новий репозиторій
cd /path/to/your/plugin
git init

# Додати .gitignore
# (створити файл .gitignore з вмістом вище)

# Додати всі файли
git add .

# Перший commit
git commit -m "Initial commit: Project structure"

# Підключити до GitHub
git remote add origin https://github.com/username/plugin-name.git
git branch -M main
git push -u origin main
```

## Структура README.md

```markdown
# MyAwesomePlugin

[![Build Status](https://img.shields.io/github/workflow/status/username/plugin/build)](https://github.com/username/plugin/actions)
[![Version](https://img.shields.io/github/v/release/username/plugin)](https://github.com/username/plugin/releases)
[![Downloads](https://img.shields.io/github/downloads/username/plugin/total)](https://github.com/username/plugin/releases)

## 📖 Опис

MyAwesomePlugin - потужний плагін для Minecraft серверів, який додає...

## ✨ Функції

- 🎮 Custom items з унікальними здібностями
- 💰 Повноцінна економіка
- 🏆 Система досягнень
- 🗃️ Підтримка MySQL та SQLite
- 🌐 Мультимовність (EN, UK, RU)

## 📋 Вимоги

- **Minecraft версії:** 1.18.x - 1.20.x
- **Spigot/Paper:** 1.18+
- **Java:** 17+
- **Залежності:** ProtocolLib (опціонально)

## 🔧 Встановлення

1. Завантажити останню версію з [Releases](https://github.com/username/plugin/releases)
2. Покласти `.jar` файл в папку `plugins/`
3. Перезапустити сервер
4. Налаштувати `config.yml`

## ⚙️ Конфігурація

```yaml
# config.yml приклад
database:
  type: mysql
  host: localhost
  port: 3306
  database: minecraft
  username: root
  password: password

economy:
  starting-balance: 1000
  currency-symbol: "$"
```

## 📝 Команди

| Команда | Опис | Пермісія |
|---------|------|----------|
| `/shop` | Відкрити магазин | `plugin.shop` |
| `/balance` | Переглянути баланс | `plugin.balance` |
| `/pay <гравець> <сума>` | Переказати гроші | `plugin.pay` |

## 🔐 Пермісії

- `plugin.*` - Всі пермісії
- `plugin.admin` - Адмін пермісії
- `plugin.vip` - VIP функції

## 🐛 Баг репорти

Знайшли баг? [Створіть Issue](https://github.com/username/plugin/issues/new)

## 💬 Підтримка

- **Discord:** [Приєднатись](https://discord.gg/...)
- **SpigotMC:** [Сторінка ресурсу](https://www.spigotmc.org/resources/...)

## 📊 Статистика

[![bStats](https://bstats.org/signatures/bukkit/MyAwesomePlugin.svg)](https://bstats.org/plugin/bukkit/MyAwesomePlugin)

## 📜 Ліцензія

Цей проєкт ліцензований під MIT License - див. [LICENSE](LICENSE)

## 🤝 Внесок

Pull requests вітаються! Для великих змін спочатку створіть issue.

## 👤 Автор

**Ваше Ім''я**
- GitHub: [@username](https://github.com/username)
- Discord: username#1234
```

## Workflow для commit messages

```bash
# Семантичні commit messages:

# feat: нова функція
git commit -m "feat: add custom crafting system"

# fix: виправлення бага
git commit -m "fix: resolve inventory duplication bug"

# docs: документація
git commit -m "docs: update installation guide"

# refactor: рефакторинг
git commit -m "refactor: reorganize command structure"

# perf: оптимізація
git commit -m "perf: optimize database queries"

# test: тести
git commit -m "test: add unit tests for economy"

# chore: інше
git commit -m "chore: update dependencies"
```

## Branching Strategy

```bash
# Головна гілка
main (або master)

# Гілка розробки
git checkout -b develop

# Гілка нової функції
git checkout -b feature/custom-items

# Працюємо над функцією...
git add .
git commit -m "feat: implement custom item system"

# Повертаємось в develop
git checkout develop
git merge feature/custom-items

# Видалити гілку після merge
git branch -d feature/custom-items

# Hotfix
git checkout -b hotfix/critical-bug
git commit -m "fix: critical duplication exploit"
git checkout main
git merge hotfix/critical-bug
git push origin main
```

## GitHub Actions для автоматичної збірки

`.github/workflows/build.yml`:
```yaml
name: Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: ''17''
        distribution: ''temurin''
    
    - name: Build with Maven
      run: mvn clean package
    
    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: plugin-jar
        path: target/*.jar
```

## Release процес

```bash
# 1. Оновити версію в pom.xml
<version>1.2.0</version>

# 2. Commit змін
git add pom.xml
git commit -m "chore: bump version to 1.2.0"

# 3. Створити tag
git tag -a v1.2.0 -m "Release version 1.2.0"

# 4. Push tag
git push origin v1.2.0

# 5. Створити Release на GitHub
# - Перейти в Releases
# - Create new release
# - Вибрати tag v1.2.0
# - Написати changelog
# - Прикріпити .jar файл
# - Publish
```

## Changelog формат

```markdown
# Changelog

## [1.2.0] - 2024-12-01

### Added
- Custom crafting system
- Player statistics tracking
- New GUI for shop

### Changed
- Improved database performance
- Updated config structure

### Fixed
- Item duplication bug
- NPE in command handler
- Memory leak in scheduler

### Removed
- Deprecated economy API

## [1.1.0] - 2024-11-15

...
```

## Collaborators workflow

```bash
# Fork репозиторій на GitHub

# Clone свій fork
git clone https://github.com/YOUR_USERNAME/plugin-name.git

# Додати upstream
git remote add upstream https://github.com/ORIGINAL_OWNER/plugin-name.git

# Синхронізувати з upstream
git fetch upstream
git checkout main
git merge upstream/main

# Створити feature branch
git checkout -b feature/my-feature

# Працювати та commit
git add .
git commit -m "feat: add my feature"

# Push в свій fork
git push origin feature/my-feature

# Створити Pull Request на GitHub
```

## GitHub Issues Templates

`.github/ISSUE_TEMPLATE/bug_report.md`:
```markdown
---
name: Bug Report
about: Report a bug
---

## Bug Description
<!-- Опишіть баг -->

## Steps to Reproduce
1. 
2. 
3. 

## Expected Behavior
<!-- Що має відбуватись -->

## Actual Behavior
<!-- Що відбувається насправді -->

## Environment
- Plugin version: 
- Server software: Spigot/Paper
- Minecraft version: 
- Java version: 

## Logs
```
paste logs here
```
```

## Практичне завдання

Створіть GitHub репозиторій для вашого плагіну:
1. Ініціалізувати Git репозиторій
2. Створити .gitignore
3. Написати детальний README.md
4. Налаштувати GitHub Actions
5. Створити перший release
6. Додати CHANGELOG.md',
  1, FALSE
);

-- Урок 10.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-10', 'lesson-10-2',
  'SpigotMC - публікація плагіну',
  '16 хв', 'text',
  '# Публікація на SpigotMC

Як опублікувати свій плагін на найбільшому маркетплейсі.

## Підготовка до публікації

### 1. Перевірити якість коду

```java
// ✅ Добре
public class MyPlugin extends JavaPlugin {
    
    private ConfigManager config;
    private DatabaseManager database;
    
    @Override
    public void onEnable() {
        getLogger().info("Loading configuration...");
        config = new ConfigManager(this);
        
        getLogger().info("Connecting to database...");
        database = new DatabaseManager(this);
        database.connect();
        
        getLogger().info("MyPlugin v" + getDescription().getVersion() + " enabled!");
    }
    
    @Override
    public void onDisable() {
        if (database != null) {
            database.disconnect();
        }
        getLogger().info("MyPlugin disabled!");
    }
}

// ❌ Погано
public class MyPlugin extends JavaPlugin {
    @Override
    public void onEnable() {
        System.out.println("Plugin enabled"); // Не використовувати System.out
        // Немає обробки помилок
    }
}
```

### 2. Оптимізувати plugin.yml

```yaml
name: MyAwesomePlugin
version: 1.0.0
main: com.yourname.plugin.MyPlugin
api-version: 1.20
author: YourName
description: Amazing plugin that does amazing things
website: https://github.com/yourname/plugin

# Залежності
depend: []
softdepend: [Vault, PlaceholderAPI]

# Команди
commands:
  shop:
    description: Open the shop GUI
    usage: /<command>
    permission: plugin.shop
    aliases: [store, market]
  
  balance:
    description: Check your balance
    usage: /<command> [player]
    permission: plugin.balance
    aliases: [bal, money]

# Пермісії
permissions:
  plugin.*:
    description: All plugin permissions
    children:
      plugin.admin: true
      plugin.shop: true
      plugin.balance: true
  
  plugin.admin:
    description: Admin permissions
    default: op
    children:
      plugin.reload: true
      plugin.give: true
  
  plugin.shop:
    description: Use shop
    default: true
  
  plugin.balance:
    description: Check balance
    default: true
```

## Створення сторінки ресурсу

### Resource Icon (як створити)

Розмір: **256x256 пікселів**

Інструменти:
- Photoshop
- GIMP (безкоштовний)
- Canva
- Minecraft текстури

### Resource Title

✅ **Добрі назви:**
- "⚔️ CustomItems | Advanced Item System"
- "💰 VaultEconomy | MySQL Support"
- "🎮 MiniGames | 10+ Games Included"

❌ **Погані назви:**
- "my plugin"
- "BEST PLUGIN EVER!!!"
- "plugin v1"

### Resource Description (BBCode)

```bbcode
[CENTER][SIZE=7][B][COLOR=#FF6B6B]⚔️ MyAwesomePlugin ⚔️[/COLOR][/B][/SIZE]
[SIZE=5]The ultimate solution for your server![/SIZE]

[IMG]https://i.imgur.com/banner.png[/IMG]
[/CENTER]

[SIZE=6][B][COLOR=#4ECDC4]✨ Features[/COLOR][/B][/SIZE]

[LIST]
[*] 🎮 Custom Items with unique abilities
[*] 💰 Complete economy system
[*] 🏆 Achievement system
[*] 🗃️ MySQL & SQLite support
[*] 🌐 Multi-language (EN, UK, RU)
[*] 📊 PlaceholderAPI support
[*] ⚡ High performance
[/LIST]

[SIZE=6][B][COLOR=#4ECDC4]📋 Requirements[/COLOR][/B][/SIZE]

[LIST]
[*] [B]Minecraft:[/B] 1.18.x - 1.20.x
[*] [B]Spigot/Paper:[/B] Latest version recommended
[*] [B]Java:[/B] 17 or higher
[*] [B]Dependencies:[/B] None (Vault optional)
[/LIST]

[SIZE=6][B][COLOR=#4ECDC4]🔧 Installation[/COLOR][/B][/SIZE]

[CODE]
1. Download the plugin
2. Put the .jar file in plugins/ folder
3. Restart your server
4. Configure config.yml to your needs
5. Enjoy!
[/CODE]

[SIZE=6][B][COLOR=#4ECDC4]📝 Commands[/COLOR][/B][/SIZE]

[CODE]
/shop - Open shop GUI
/balance [player] - Check balance
/pay <player> <amount> - Transfer money
/myplugin reload - Reload configuration
[/CODE]

[SIZE=6][B][COLOR=#4ECDC4]🔐 Permissions[/COLOR][/B][/SIZE]

[CODE]
plugin.* - All permissions
plugin.admin - Admin commands
plugin.shop - Use shop
plugin.balance - Check balance
plugin.pay - Transfer money
[/CODE]

[SIZE=6][B][COLOR=#4ECDC4]⚙️ Configuration[/COLOR][/B][/SIZE]

[SPOILER="config.yml"]
[CODE]
# Database settings
database:
  type: mysql # or sqlite
  host: localhost
  port: 3306
  database: minecraft
  username: root
  password: password

# Economy settings
economy:
  starting-balance: 1000
  currency-symbol: "$"
  
# Language
language: en # en, uk, ru
[/CODE]
[/SPOILER]

[SIZE=6][B][COLOR=#4ECDC4]📸 Screenshots[/COLOR][/B][/SIZE]

[SPOILER="Shop GUI"]
[IMG]https://i.imgur.com/shop.png[/IMG]
[/SPOILER]

[SPOILER="Profile GUI"]
[IMG]https://i.imgur.com/profile.png[/IMG]
[/SPOILER]

[SIZE=6][B][COLOR=#4ECDC4]📊 Statistics[/COLOR][/B][/SIZE]

[CENTER][IMG]https://bstats.org/signatures/bukkit/MyAwesomePlugin.svg[/IMG][/CENTER]

[SIZE=6][B][COLOR=#4ECDC4]🐛 Bug Reports[/COLOR][/B][/SIZE]

Found a bug? [URL=https://github.com/username/plugin/issues]Report it on GitHub[/URL]

[SIZE=6][B][COLOR=#4ECDC4]💬 Support[/COLOR][/B][/SIZE]

Need help? Join our [URL=https://discord.gg/...]Discord[/URL]!

[SIZE=6][B][COLOR=#4ECDC4]⭐ Reviews[/COLOR][/B][/SIZE]

If you like this plugin, please leave a 5-star review! ⭐⭐⭐⭐⭐

[CENTER][SIZE=5][B]Thank you for using MyAwesomePlugin![/B][/SIZE][/CENTER]
```

## bStats (статистика)

### Додати до проєкту

pom.xml:
```xml
<repositories>
    <repository>
        <id>CodeMC</id>
        <url>https://repo.codemc.org/repository/maven-public</url>
    </repository>
</repositories>

<dependencies>
    <dependency>
        <groupId>org.bstats</groupId>
        <artifactId>bstats-bukkit</artifactId>
        <version>3.0.2</version>
        <scope>compile</scope>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-shade-plugin</artifactId>
            <version>3.5.0</version>
            <executions>
                <execution>
                    <phase>package</phase>
                    <goals>
                        <goal>shade</goal>
                    </goals>
                    <configuration>
                        <relocations>
                            <relocation>
                                <pattern>org.bstats</pattern>
                                <shadedPattern>com.yourpackage.bstats</shadedPattern>
                            </relocation>
                        </relocations>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

У коді:
```java
public class MyPlugin extends JavaPlugin {
    
    @Override
    public void onEnable() {
        // bStats
        int pluginId = 12345; // Отримати з https://bstats.org/
        Metrics metrics = new Metrics(this, pluginId);
        
        // Custom charts
        metrics.addCustomChart(new Metrics.SimplePie("used_language", () -> {
            return getConfig().getString("language", "en");
        }));
        
        metrics.addCustomChart(new Metrics.SimplePie("database_type", () -> {
            return getConfig().getString("database.type", "sqlite");
        }));
    }
}
```

## Ціноутворення

### Безкоштовний vs Платний

**Безкоштовний:**
- Більше завантажень
- Більше відгуків
- Більша популярність
- Можна додати donate

**Платний ($5-50):**
- Менше piracy
- Серйозніші користувачі
- Дохід від продажів
- Premium support

### Ліцензії

**MIT License** - найбільш відкрита
**GPL-3.0** - open source, modifications must be open
**All Rights Reserved** - закритий код
**Custom License** - власні умови

## Update Process

```bash
# 1. Оновити версію
<version>1.1.0</version>

# 2. Створити changelog
## Version 1.1.0

### Added
- New shop GUI
- MySQL support

### Fixed
- Item duplication bug

# 3. Build новий .jar
mvn clean package

# 4. Upload на SpigotMC
# - Edit Resource
# - New Version
# - Upload .jar
# - Paste changelog
# - Submit

# 5. Оновити GitHub Release
```

## Відповідь на відгуки

✅ **Гарна відповідь:**
```
Дякую за відгук! Щодо вашої проблеми:
1. Перевірте чи у вас остання версія плагіну
2. Переконайтесь що Java 17+ встановлена
3. Якщо проблема залишається, створіть issue на GitHub з логами

Радий що вам сподобався плагін! 😊
```

❌ **Погана відповідь:**
```
works for me
idk what ur doing wrong
```

## Практичне завдання

Підготуйте плагін до публікації:
1. Оптимізувати plugin.yml з пермісіями
2. Створити 256x256 icon
3. Написати BBCode опис
4. Додати bStats
5. Створити 3-5 скріншотів
6. Опублікувати на SpigotMC',
  2, FALSE
);

-- Урок 10.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-10', 'lesson-10-3',
  'Best Practices - чистий код та оптимізація',
  '20 хв', 'text',
  '# Best Practices для Minecraft плагінів

Професійні практики розробки якісних плагінів.

## Структура проєкту

```
MyPlugin/
├── src/main/java/com/yourname/plugin/
│   ├── MyPlugin.java                 # Main клас
│   ├── commands/                      # Команди
│   │   ├── CommandManager.java
│   │   ├── ShopCommand.java
│   │   └── BalanceCommand.java
│   ├── listeners/                     # Event listeners
│   │   ├── PlayerListener.java
│   │   └── InventoryListener.java
│   ├── gui/                           # GUI системи
│   │   ├── GUI.java
│   │   ├── ShopGUI.java
│   │   └── ProfileGUI.java
│   ├── managers/                      # Managers
│   │   ├── ConfigManager.java
│   │   ├── DatabaseManager.java
│   │   └── EconomyManager.java
│   ├── models/                        # Data models
│   │   ├── PlayerData.java
│   │   └── ShopItem.java
│   ├── utils/                         # Утиліти
│   │   ├── MessageUtil.java
│   │   ├── ItemBuilder.java
│   │   └── TimeUtil.java
│   └── api/                           # Public API
│       └── MyPluginAPI.java
├── src/main/resources/
│   ├── plugin.yml
│   ├── config.yml
│   ├── messages_en.yml
│   └── messages_uk.yml
└── pom.xml
```

## Naming Conventions

```java
// ✅ Добрі імена
public class PlayerDataManager { }
public interface EconomyProvider { }
public enum MessageType { }

private final JavaPlugin plugin;
private Map<UUID, PlayerData> playerCache;
private static final int MAX_BALANCE = 1_000_000;

public void loadPlayerData(UUID uuid) { }
public boolean hasPermission(Player player, String perm) { }
private void saveToDatabase(PlayerData data) { }

// ❌ Погані імена
public class pdm { }
public class Util { }  // Занадто загально

private JavaPlugin p;
private Map<UUID, PlayerData> map1;
private static final int X = 1000000;  // Що це?

public void load(UUID u) { }  // Що завантажуємо?
public boolean check(Player p, String s) { }  // Що перевіряємо?
```

## Коментарі та документація

```java
/**
 * Manages player economy data.
 * 
 * This class handles all economy-related operations including
 * balance management, transactions, and database synchronization.
 * 
 * @author YourName
 * @version 1.0
 * @since 1.0
 */
public class EconomyManager {
    
    /**
     * Transfers money from one player to another.
     * 
     * @param from The UUID of the sender
     * @param to The UUID of the receiver
     * @param amount The amount to transfer
     * @return true if transaction successful, false otherwise
     * @throws IllegalArgumentException if amount is negative
     */
    public boolean transferMoney(UUID from, UUID to, double amount) {
        if (amount < 0) {
            throw new IllegalArgumentException("Amount cannot be negative");
        }
        
        // Get current balances
        double fromBalance = getBalance(from);
        double toBalance = getBalance(to);
        
        // Check sufficient funds
        if (fromBalance < amount) {
            return false;
        }
        
        // Perform transaction
        setBalance(from, fromBalance - amount);
        setBalance(to, toBalance + amount);
        
        // Log transaction
        logTransaction(from, to, amount);
        
        return true;
    }
}
```

## Error Handling

```java
// ✅ Правильна обробка помилок
public void loadConfig() {
    try {
        config.load();
        plugin.getLogger().info("Configuration loaded successfully");
    } catch (IOException e) {
        plugin.getLogger().severe("Failed to load configuration: " + e.getMessage());
        plugin.getLogger().severe("Using default configuration");
        config.loadDefaults();
    } catch (Exception e) {
        plugin.getLogger().severe("Unexpected error loading config: " + e.getMessage());
        e.printStackTrace();
        plugin.getServer().getPluginManager().disablePlugin(plugin);
    }
}

// ✅ Валідація вхідних даних
public boolean giveItem(Player player, ItemStack item) {
    if (player == null) {
        plugin.getLogger().warning("Attempted to give item to null player");
        return false;
    }
    
    if (!player.isOnline()) {
        plugin.getLogger().warning("Attempted to give item to offline player: " + player.getName());
        return false;
    }
    
    if (item == null || item.getType() == Material.AIR) {
        plugin.getLogger().warning("Attempted to give invalid item");
        return false;
    }
    
    player.getInventory().addItem(item);
    return true;
}

// ❌ Погана обробка
public void loadConfig() {
    try {
        config.load();
    } catch (Exception e) {
        // Пустий catch - ніколи не робіть так!
    }
}
```

## Performance Tips

```java
// ✅ Cache часто використовувані дані
public class PlayerCache {
    private final Map<UUID, PlayerData> cache = new ConcurrentHashMap<>();
    private final LoadingCache<UUID, PlayerData> loadingCache;
    
    public PlayerCache() {
        this.loadingCache = Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .maximumSize(1000)
            .build(uuid -> database.loadPlayer(uuid));
    }
    
    public PlayerData get(UUID uuid) {
        return loadingCache.get(uuid);
    }
}

// ✅ Batch операції замість циклів
public void saveAllPlayers(Collection<UUID> players) {
    // ❌ Погано - багато окремих запитів
    for (UUID uuid : players) {
        database.savePlayer(uuid);
    }
    
    // ✅ Добре - один batch запит
    database.savePlayers(players);
}

// ✅ Async операції для важких задач
public void generateReport(Player player) {
    Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
        // Важкі обчислення
        String report = calculateStatistics();
        
        // Повернутись на main thread
        Bukkit.getScheduler().runTask(plugin, () -> {
            player.sendMessage(report);
        });
    });
}

// ✅ Використовувати StringBuilder для конкатенації
// ❌ Погано
String message = "";
for (Player p : players) {
    message += p.getName() + ", ";
}

// ✅ Добре
StringBuilder message = new StringBuilder();
for (Player p : players) {
    message.append(p.getName()).append(", ");
}
```

## Memory Management

```java
// ✅ Очищення ресурсів
public class MyPlugin extends JavaPlugin {
    
    private Map<UUID, PlayerData> playerData = new HashMap<>();
    private List<BukkitTask> tasks = new ArrayList<>();
    
    @Override
    public void onDisable() {
        // Зберегти дані
        playerData.values().forEach(data -> database.save(data));
        
        // Очистити cache
        playerData.clear();
        
        // Скасувати tasks
        tasks.forEach(BukkitTask::cancel);
        tasks.clear();
        
        // Закрити з''єднання
        if (database != null) {
            database.disconnect();
        }
        
        // Скасувати всі scheduler tasks
        Bukkit.getScheduler().cancelTasks(this);
    }
}

// ✅ Weak references для тимчасових даних
private final Map<UUID, WeakReference<Player>> recentPlayers = new HashMap<>();

public void rememberPlayer(Player player) {
    recentPlayers.put(player.getUniqueId(), new WeakReference<>(player));
}

// ✅ Automatic cleanup
private void startCleanupTask() {
    new BukkitRunnable() {
        @Override
        public void run() {
            // Видалити offline гравців
            playerData.entrySet().removeIf(entry -> {
                Player player = Bukkit.getPlayer(entry.getKey());
                return player == null || !player.isOnline();
            });
        }
    }.runTaskTimerAsynchronously(plugin, 6000L, 6000L); // Кожні 5 хвилин
}
```

## API Design

```java
/**
 * Public API for MyPlugin.
 * This API is stable and will maintain backwards compatibility.
 */
public interface MyPluginAPI {
    
    /**
     * Gets the economy manager.
     * 
     * @return The economy manager instance
     */
    EconomyManager getEconomy();
    
    /**
     * Gets player data.
     * 
     * @param uuid The player UUID
     * @return The player data, or empty if not found
     */
    Optional<PlayerData> getPlayerData(UUID uuid);
    
    /**
     * Registers a custom shop item.
     * 
     * @param item The shop item to register
     * @throws IllegalArgumentException if item is invalid
     */
    void registerShopItem(ShopItem item);
}

// Singleton для доступу
public class MyPlugin extends JavaPlugin implements MyPluginAPI {
    
    private static MyPlugin instance;
    
    public static MyPlugin getInstance() {
        return instance;
    }
    
    public static MyPluginAPI getAPI() {
        return instance;
    }
    
    @Override
    public void onEnable() {
        instance = this;
    }
}

// Використання іншими плагінами
public class OtherPlugin extends JavaPlugin {
    
    @Override
    public void onEnable() {
        if (Bukkit.getPluginManager().isPluginEnabled("MyPlugin")) {
            MyPluginAPI api = MyPlugin.getAPI();
            Optional<PlayerData> data = api.getPlayerData(someUUID);
        }
    }
}
```

## Configuration Best Practices

```java
public class ConfigManager {
    
    private final JavaPlugin plugin;
    private FileConfiguration config;
    
    // Default values
    private static final String DEFAULT_CURRENCY = "$";
    private static final double DEFAULT_STARTING_BALANCE = 1000.0;
    private static final int DEFAULT_MAX_HOMES = 5;
    
    public void loadConfig() {
        // Save default if not exists
        plugin.saveDefaultConfig();
        
        // Load
        config = plugin.getConfig();
        
        // Validate
        validateConfig();
    }
    
    private void validateConfig() {
        boolean modified = false;
        
        // Check missing values
        if (!config.contains("economy.currency-symbol")) {
            config.set("economy.currency-symbol", DEFAULT_CURRENCY);
            modified = true;
        }
        
        // Check invalid values
        double startBalance = config.getDouble("economy.starting-balance");
        if (startBalance < 0) {
            plugin.getLogger().warning("Invalid starting balance, using default");
            config.set("economy.starting-balance", DEFAULT_STARTING_BALANCE);
            modified = true;
        }
        
        if (modified) {
            plugin.saveConfig();
        }
    }
    
    // Type-safe getters
    public String getCurrencySymbol() {
        return config.getString("economy.currency-symbol", DEFAULT_CURRENCY);
    }
    
    public double getStartingBalance() {
        return Math.max(0, config.getDouble("economy.starting-balance", DEFAULT_STARTING_BALANCE));
    }
}
```

## Testing

```java
// Unit test приклад (JUnit)
public class EconomyManagerTest {
    
    private EconomyManager economy;
    
    @Before
    public void setUp() {
        economy = new EconomyManager();
    }
    
    @Test
    public void testTransfer() {
        UUID from = UUID.randomUUID();
        UUID to = UUID.randomUUID();
        
        economy.setBalance(from, 1000);
        economy.setBalance(to, 500);
        
        boolean result = economy.transferMoney(from, to, 200);
        
        assertTrue(result);
        assertEquals(800, economy.getBalance(from), 0.01);
        assertEquals(700, economy.getBalance(to), 0.01);
    }
    
    @Test
    public void testInsufficientFunds() {
        UUID from = UUID.randomUUID();
        UUID to = UUID.randomUUID();
        
        economy.setBalance(from, 100);
        
        boolean result = economy.transferMoney(from, to, 200);
        
        assertFalse(result);
        assertEquals(100, economy.getBalance(from), 0.01);
    }
}
```

## Практичне завдання

Рефакторинг вашого плагіну:
1. Організувати код в пакети (commands, listeners, managers, etc.)
2. Додати JavaDoc коментарі
3. Додати error handling
4. Оптимізувати performance (cache, async, batch)
5. Створити public API
6. Написати unit tests',
  3, FALSE
);

-- Квіз для Модуля 10
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-10', 'lesson-10-4',
  'Тест: Публікація та Best Practices',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-10-4",
    "questions": [
      {
        "id": "q1",
        "question": "Що має містити .gitignore для Minecraft плагіну?",
        "options": [
          "Тільки target/",
          "target/, .idea/, *.jar, config.yml з паролями БД",
          "Нічого, все треба commit''ити",
          "Тільки .class файли"
        ],
        "correctAnswer": 1,
        "explanation": ".gitignore має виключати compiled файли, IDE налаштування, та конфіги з чутливими даними"
      },
      {
        "id": "q2",
        "question": "Який розмір має бути icon для SpigotMC ресурсу?",
        "options": [
          "128x128",
          "256x256",
          "512x512",
          "Будь-який"
        ],
        "correctAnswer": 1,
        "explanation": "SpigotMC вимагає icon розміром 256x256 пікселів для resource page"
      },
      {
        "id": "q3",
        "question": "Навіщо використовувати bStats?",
        "options": [
          "Для безпеки",
          "Для збору анонімної статистики використання плагіну",
          "Обов''язкова вимога SpigotMC",
          "Для оптимізації"
        ],
        "correctAnswer": 1,
        "explanation": "bStats збирає анонімну статистику (версія MC, к-сть серверів, налаштування) для розуміння аудиторії"
      },
      {
        "id": "q4",
        "question": "Що краще для performance: cache чи кожен раз запит до БД?",
        "options": [
          "Завжди запит до БД",
          "Cache з expiration time",
          "Немає різниці",
          "Залежить від фази місяця"
        ],
        "correctAnswer": 1,
        "explanation": "Cache з TTL (time to live) дає кращий performance при збереженні актуальності даних"
      },
      {
        "id": "q5",
        "question": "Чому важливо додати JavaDoc до public API?",
        "options": [
          "Для краси коду",
          "Щоб інші розробники розуміли як використовувати ваш API",
          "Обов''язкова вимога Java",
          "Для швидшої роботи"
        ],
        "correctAnswer": 1,
        "explanation": "JavaDoc документує public API і допомагає іншим розробникам інтегруватись з вашим плагіном"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 10 додано! 4 уроки створено. КУРС ЗАВЕРШЕНО!' as status;
