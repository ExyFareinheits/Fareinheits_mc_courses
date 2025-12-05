-- =============================================
-- Контент для курсу paid-1: Професійна Розробка Плагінів
-- =============================================

-- Додати модулі курсу
INSERT INTO course_modules (course_id, module_id, title, description, order_index)
VALUES 
  ('paid-1', 'module-1', 'Основи Java для Minecraft', 'Вивчіть Java з нуля для розробки плагінів', 1),
  ('paid-1', 'module-2', 'Spigot/Paper API глибоке вивчення', 'Повне розуміння Bukkit/Spigot API', 2),
  ('paid-1', 'module-3', 'Event система та Listeners', 'Робота з подіями та обробниками', 3),
  ('paid-1', 'module-4', 'Commands та TabCompleters', 'Створення складних систем команд', 4),
  ('paid-1', 'module-5', 'Робота з конфігами (YAML, JSON)', 'Збереження налаштувань плагіну', 5),
  ('paid-1', 'module-6', 'Databases (MySQL, SQLite, MongoDB)', 'Інтеграція баз даних для зберігання', 6),
  ('paid-1', 'module-7', 'Async/Sync обробка', 'Асинхронне програмування для продуктивності', 7),
  ('paid-1', 'module-8', 'Packet manipulation', 'Робота з пакетами для просунутих можливостей', 8),
  ('paid-1', 'module-9', 'Custom items та GUI', 'Створення кастомних предметів та меню', 9),
  ('paid-1', 'module-10', 'Публікація плагінів', 'Від GitHub до SpigotMC релізу', 10);

-- =============================================
-- Модуль 1: Основи Java для Minecraft
-- =============================================

-- Урок 1.1 (безкоштовний preview)
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-1', 'lesson-1-1',
  'Встановлення IntelliJ/VS Code та JDK',
  '12 хв', 'text',
  '# Встановлення середовища розробки

У цьому уроці ми встановимо все необхідне для розробки плагінів.

## Крок 1: Встановлення JDK 17

Minecraft 1.20+ потребує Java 17 або новішої версії.

### Windows:
1. Завантажте JDK 17 з [Adoptium](https://adoptium.net/)
2. Оберіть версію **Temurin 17 (LTS)**
3. Встановіть з опцією "Add to PATH"
4. Перевірте встановлення: `java -version`

### Linux:
```bash
sudo apt update
sudo apt install openjdk-17-jdk
java -version
```

### macOS:
```bash
brew install openjdk@17
java -version
```

## Крок 2: Встановлення IntelliJ IDEA

IntelliJ IDEA - найкраща IDE для Java розробки.

1. Завантажте [Community версію](https://www.jetbrains.com/idea/download/) (безкоштовна)
2. Встановіть з усіма опціями для Java
3. При першому запуску:
   - Оберіть тему (Darcula рекомендовано)
   - Встановіть плагіни: Minecraft Development

## Крок 3: Конфігурація IDEA

1. **File → Settings → Build, Execution, Deployment → Build Tools → Maven**
   - Вкажіть Maven home directory
2. **File → Settings → Editor → Code Style → Java**
   - Встановіть indent на 4 spaces
3. **Встановіть плагін Minecraft Development:**
   - File → Settings → Plugins
   - Пошук: "Minecraft Development"
   - Install → Restart IDE

## Перевірка

Створіть тестовий Java файл:
```java
public class Test {
    public static void main(String[] args) {
        System.out.println("Hello Minecraft!");
    }
}
```

Якщо код підсвічується правильно - все готово! ✅

## Наступні кроки

У наступному уроці ми створимо наш перший Maven проект для плагіну.',
  1, TRUE
);

-- Урок 1.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-1', 'lesson-1-2',
  'Основи Java синтаксису',
  '20 хв', 'text',
  '# Основи Java для Minecraft плагінів

Швидкий курс Java з фокусом на те, що потрібно для Minecraft.

## Змінні та типи даних

```java
// Примітивні типи
int playerCount = 10;
double health = 20.0;
boolean isOnline = true;
char grade = ''A'';

// Об''єкти
String playerName = "Notch";
Player player = Bukkit.getPlayer("Steve");
Location spawn = new Location(world, 0, 64, 0);
```

## Класи та об''єкти

```java
public class CustomItem {
    private String name;
    private int amount;
    
    // Конструктор
    public CustomItem(String name, int amount) {
        this.name = name;
        this.amount = amount;
    }
    
    // Getters та Setters
    public String getName() {
        return name;
    }
    
    public void setAmount(int amount) {
        this.amount = amount;
    }
}

// Використання
CustomItem sword = new CustomItem("Magic Sword", 1);
System.out.println(sword.getName()); // "Magic Sword"
```

## Умови та цикли

```java
// If-else
if (player.getHealth() <= 5.0) {
    player.sendMessage("Низьке здоров''я!");
} else if (player.getHealth() < 10.0) {
    player.sendMessage("Будьте обережні!");
} else {
    player.sendMessage("Все добре!");
}

// For цикл
for (Player online : Bukkit.getOnlinePlayers()) {
    online.sendMessage("Привіт!");
}

// While цикл
int countdown = 5;
while (countdown > 0) {
    player.sendMessage("" + countdown);
    countdown--;
}
```

## Колекції (Collections)

```java
// List - впорядкований список
List<String> players = new ArrayList<>();
players.add("Steve");
players.add("Alex");
players.remove("Steve");

// Map - ключ-значення
Map<UUID, Integer> kills = new HashMap<>();
kills.put(player.getUniqueId(), 10);
int playerKills = kills.get(player.getUniqueId());

// Set - унікальні значення
Set<Material> blocks = new HashSet<>();
blocks.add(Material.STONE);
blocks.add(Material.STONE); // Не додасться
```

## Методи

```java
public class PlayerUtils {
    
    // Метод без повернення
    public static void healPlayer(Player player) {
        player.setHealth(20.0);
        player.sendMessage("Ви зцілені!");
    }
    
    // Метод з поверненням
    public static boolean isVIP(Player player) {
        return player.hasPermission("server.vip");
    }
    
    // Метод з кількома параметрами
    public static void giveItems(Player player, Material material, int amount) {
        ItemStack item = new ItemStack(material, amount);
        player.getInventory().addItem(item);
    }
}

// Використання
PlayerUtils.healPlayer(player);
boolean vip = PlayerUtils.isVIP(player);
```

## Практичне завдання

Створіть клас `CooldownManager` з методами:
- `setCooldown(UUID player, int seconds)` - встановити кулдаун
- `hasCooldown(UUID player)` - перевірити чи є кулдаун
- `getRemainingTime(UUID player)` - отримати залишок часу

Підказка: використайте `HashMap<UUID, Long>` для зберігання.',
  2, FALSE
);

-- Урок 1.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-1', 'lesson-1-3',
  'Створення Maven проекту',
  '15 хв', 'text',
  '# Створення Maven проекту для плагіну

Maven - інструмент для збірки Java проектів і керування залежностями.

## Крок 1: Новий Maven проект

1. **File → New → Project**
2. Оберіть **Maven Archetype**
3. Налаштування:
   - Name: `MyFirstPlugin`
   - GroupId: `ua.yourname`
   - ArtifactId: `myfirstplugin`
   - Version: `1.0.0`

## Крок 2: Структура проекту

```
MyFirstPlugin/
├── src/
│   └── main/
│       ├── java/
│       │   └── ua/yourname/myfirstplugin/
│       │       └── MyFirstPlugin.java
│       └── resources/
│           └── plugin.yml
├── pom.xml
└── target/ (генерується після збірки)
```

## Крок 3: Налаштування pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>ua.yourname</groupId>
    <artifactId>myfirstplugin</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <repositories>
        <!-- Spigot repository -->
        <repository>
            <id>spigot-repo</id>
            <url>https://hub.spigotmc.org/nexus/content/repositories/snapshots/</url>
        </repository>
    </repositories>

    <dependencies>
        <!-- Spigot API -->
        <dependency>
            <groupId>org.spigotmc</groupId>
            <artifactId>spigot-api</artifactId>
            <version>1.20.4-R0.1-SNAPSHOT</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>${project.name}-${project.version}</finalName>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <filtering>true</filtering>
            </resource>
        </resources>
    </build>
</project>
```

## Крок 4: Створення головного класу

`src/main/java/ua/yourname/myfirstplugin/MyFirstPlugin.java`:

```java
package ua.yourname.myfirstplugin;

import org.bukkit.plugin.java.JavaPlugin;

public class MyFirstPlugin extends JavaPlugin {
    
    @Override
    public void onEnable() {
        getLogger().info("Плагін увімкнено!");
    }
    
    @Override
    public void onDisable() {
        getLogger().info("Плагін вимкнено!");
    }
}
```

## Крок 5: Створення plugin.yml

`src/main/resources/plugin.yml`:

```yaml
name: MyFirstPlugin
version: 1.0.0
main: ua.yourname.myfirstplugin.MyFirstPlugin
api-version: 1.20
author: YourName
description: Мій перший Minecraft плагін
```

## Крок 6: Збірка плагіну

1. Відкрийте Maven панель (справа)
2. Розгорніть **Lifecycle**
3. Двічі клацніть на **clean**
4. Потім двічі клацніть на **package**

Або через термінал:
```bash
mvn clean package
```

Готовий JAR файл буде в `target/MyFirstPlugin-1.0.0.jar`

## Крок 7: Тестування

1. Скопіюйте JAR в папку `plugins/` вашого тестового сервера
2. Запустіть сервер
3. У консолі побачите: "Плагін увімкнено!"

Вітаю! Ви створили свій перший плагін! 🎉',
  3, FALSE
);

-- Квіз для Модуля 1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-1', 'lesson-1-4',
  'Тест: Основи Java та Maven',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-1-4",
    "questions": [
      {
        "id": "q1",
        "question": "Яка версія Java потрібна для Minecraft 1.20+?",
        "options": ["Java 8", "Java 11", "Java 17", "Java 21"],
        "correctAnswer": 2,
        "explanation": "Minecraft 1.20+ вимагає Java 17 або новішу версію"
      },
      {
        "id": "q2",
        "question": "Що таке Maven?",
        "options": [
          "IDE для розробки",
          "Інструмент для збірки та керування залежностями",
          "Сервер для тестування",
          "Плагін для Minecraft"
        ],
        "correctAnswer": 1,
        "explanation": "Maven - build tool для автоматизації збірки та керування залежностями Java проектів"
      },
      {
        "id": "q3",
        "question": "Який файл містить метаданні плагіну?",
        "options": ["pom.xml", "config.yml", "plugin.yml", "settings.xml"],
        "correctAnswer": 2,
        "explanation": "plugin.yml містить назву, версію, main клас та інші метадані плагіну"
      },
      {
        "id": "q4",
        "question": "Який метод викликається при увімкненні плагіну?",
        "options": ["onStart()", "onLoad()", "onEnable()", "initialize()"],
        "correctAnswer": 2,
        "explanation": "onEnable() викликається коли плагін завантажується на сервері"
      },
      {
        "id": "q5",
        "question": "Де зберігається зібраний JAR файл після mvn package?",
        "options": ["src/", "build/", "target/", "out/"],
        "correctAnswer": 2,
        "explanation": "Maven зберігає зібрані артефакти в папці target/"
      }
    ]
  }'::jsonb,
  4, FALSE
);

-- =============================================
-- Перевірка
-- =============================================

SELECT 'Модуль 1 додано успішно! 4 уроки створено.' as status;
