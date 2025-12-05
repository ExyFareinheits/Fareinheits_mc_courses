-- =====================================================
-- МОДУЛЬ 1, УРОК 3: Основні причини лагів та їх усунення
-- =====================================================
-- Курс: paid-2 (Ідеальна Оптимізація Minecraft Сервера)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-2' AND order_index = 1;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 3;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-2',
    v_module_id,
    v_lesson_id,
    'ТОП-5 причин лагів і як їх фіксити',
    'text',
    '# Основні причини лагів: діагностика та рішення

## 🎯 Вступ

У попередньому уроці ви навчились знаходити проблеми через Spark. Тепер розберемо **ТОП-5 найпоширеніших причин** лагів і як їх усунути.

**Статистика з 1000+ серверів:**
- 🥇 Entity overflow (42% випадків)
- 🥈 Погані плагіни (28% випадків)  
- 🥉 Chunk loading (15% випадків)
- Redstone lag machines (8% випадків)
- Memory leaks (7% випадків)

## 🐄 ПРОБЛЕМА #1: Entity Overflow (42%)

### Симптоми

```bash
/spark profiler показує:
Entity Tick: 45-60% ← КРИТИЧНО!

/paper entity list:
world: 15,000+ entities
├─ minecraft:item: 6,000+
├─ minecraft:cow: 3,000+
└─ minecraft:zombie: 2,000+
```

### Чому це лагає?

Кожен entity кожен тік (50ms):
- ✓ AI calculations (pathfinding)
- ✓ Collision detection
- ✓ Physics simulation
- ✓ Network sync з клієнтами

```
1 корова = ~0.3ms
3000 корів = 900ms на тік!
TPS падає до 1.1!
```

### Діагностика

#### Крок 1: Підрахунок

```bash
/paper entity list

# Норми:
< 100 entities на гравця = OK ✅
100-200 на гравця = багато ⚠️
> 200 на гравця = КРИТИЧНО ❌
```

#### Крок 2: Локація проблеми

```bash
# WorldGuard
/wg report -p

# Покаже:
Chunk (123, 456): 234 entities ← ПРОБЛЕМА!
```

#### Крок 3: Spark підтвердження

```
Entity Tick breakdown:
- minecraft:item: 22% ← Предмети на землі
- minecraft:cow: 18% ← Ферми корів
- minecraft:zombie: 12% ← Спавнери
```

### Рішення

#### Фікс #1: Spigot.yml - Entity Activation Range

```yaml
# spigot.yml
world-settings:
  default:
    entity-activation-range:
      # Скільки блоків від гравця entity активний
      animals: 16       # Було: 32 → зменшили вдвічі
      monsters: 24      # Було: 32
      raiders: 48       # Pillagers - залишаємо
      misc: 8           # Предмети - було: 16
      water: 8          # Риби
      villagers: 24     # Було: 32
      flying-monsters: 32
      
    # Як часто оновлювати entities
    tick-inactive-villagers: false  # НЕ оновлювати неактивних
    nerf-spawner-mobs: true         # Ослабити мобів зі спавнерів
```

**Що дає:**
- Entities далі 16 блоків від гравців = заморожені
- AI не рахується = економія ~40% Entity Tick
- TPS +2-3 пункти

**Побічні ефекти:**
- Ферми працюють тільки коли гравець поблизу
- Моби не будуть атакувати здалеку

#### Фікс #2: Paper.yml - Spawn Limits

```yaml
# paper-world.yml (Paper 1.19+)
entities:
  spawning:
    # Максимум мобів що можуть існувати
    spawn-limits:
      monster: 50      # Було: 70
      creature: 10     # Було: 15 (корови, свині)
      ambient: 15      # Кажани
      water-creature: 5
      water-ambient: 20
      
  behavior:
    # Disable features
    disable-chest-cat-detection: true
    disable-creeper-lingering-effect: true
    disable-player-crits: false  # Залишити PvP
    
  # Despawn rates
  despawn-ranges:
    soft: 28  # Починати деспавн з 28 блоків
    hard: 96  # Форсований деспавн на 96 блоках
```

**Що дає:**
- Менше мобів = менше AI calculations
- TPS +1-2 пункти

#### Фікс #3: Item Despawn

```yaml
# spigot.yml  
world-settings:
  default:
    item-despawn-rate: 2400  # Було: 6000 (2 хв замість 5)
    
    merge-radius:
      item: 4.0  # Об''єднувати предмети в радіусі 4 блоки
      exp: 6.0   # Досвід
    
    # Альтернативні предмети що деспавняться швидше
    alt-item-despawn-rate:
      enabled: true
      items:
        COBBLESTONE: 600   # 30 секунд
        NETHERRACK: 600
        DIRT: 600
        SAND: 600
```

**Що дає:**
- Предмети зникають швидше = менше entities
- Об''єднання зменшує кількість вдвічі
- TPS +1-2 пункти

#### Фікс #4: Farm Limiter Plugin

```bash
# Встановити FarmLimiter
wget https://github.com/.../FarmLimiter.jar

# config.yml
limits:
  passive:
    cow: 10        # Макс 10 корів на чанк
    pig: 10
    sheep: 10
    chicken: 15
    
  hostile:
    zombie: 8
    skeleton: 8
    creeper: 5
    
  removal:
    enabled: true
    check-interval: 300  # Кожні 5 хвилин
    kill-excess: true    # Вбивати зайві
```

**Що дає:**
- Неможливо зробити ферму на 1000 корів
- Автоматичне видалення зайвих
- TPS +2-4 пункти

#### Фікс #5: ClearLag Automation

```yaml
# ClearLag config.yml
settings:
  auto-removal:
    enabled: true
    interval: 300      # Кожні 5 хвилин
    broadcast: true
    
    entities:
      - item            # Предмети на землі
      - arrow           # Стріли
      - snowball
      - egg
      - experience_orb  # Досвід (обережно!)
      
    # Попередження гравцям
    warnings:
      - 60   # За 60 секунд
      - 30
      - 10
      - 5
      
    # Що НЕ видаляти
    skip-items:
      - DIAMOND
      - NETHERITE_INGOT
      - ELYTRA
```

**Що дає:**
- Автоматична чистка кожні 5 хвилин
- Гравці попереджені
- TPS стабільний

### Результат Entity Fixes

**ДО:**
```
Entities: 15,000
Entity Tick: 52%
TPS: 16.3
```

**ПІСЛЯ:**
```
Entities: 2,500 ✅
Entity Tick: 18% ✅
TPS: 19.6 ✅
```

**Приріст:** +3.3 TPS (+20% продуктивності!)

## 🔌 ПРОБЛЕМА #2: Погані плагіни (28%)

### Симптоми

```bash
/spark profiler:
MyAwesomePlugin: 18.7% ← ПРОБЛЕМА!
├─ PlayerMoveEvent: 12.3%
└─ onBlockBreak: 6.4%
```

### Чому плагіни лагають?

#### 1. Heavy Event Listeners

```java
// ПОГАНИЙ КОД ❌
@EventHandler
public void onPlayerMove(PlayerMoveEvent e) {
    // Викликається КОЖЕН РУХ (сотні разів на секунду!)
    for (Player p : Bukkit.getOnlinePlayers()) {
        // Перевірка для КОЖНОГО гравця
        if (p.getLocation().distance(e.getTo()) < 10) {
            p.sendMessage("Хтось поблизу!");
        }
    }
}

// При 100 гравцях:
// 100 рухів/сек × 100 перевірок = 10,000 операцій/сек!
// Кожна 0.5ms = 5000ms = 5 секунд на тік!
// TPS падає до 0.2!
```

#### 2. Database Queries в Main Thread

```java
// ПОГАНИЙ КОД ❌
@EventHandler
public void onJoin(PlayerJoinEvent e) {
    // Блокуючий SQL запит в головному потоці!
    ResultSet rs = database.query("SELECT * FROM players WHERE uuid=...");
    // Затримка 50-200ms = весь сервер чекає!
}
```

#### 3. File I/O в Sync

```java
// ПОГАНИЙ КОД ❌
public void saveData() {
    // Запис у файл синхронно
    file.write(data);  // Може зайняти 100+ ms!
}
```

### Діагностика

#### Крок 1: Spark Profiler

```bash
/spark profiler --timeout 300
# Чекати 5 хвилин
/spark profiler --stop
```

**Шукати:**
- Плагіни >10% = підозрілі ⚠️
- Плагіни >15% = критичні ❌
- Database/IO методи = червоний прапор 🚩

#### Крок 2: Plugin List Analysis

```bash
/plugins

# Перевірити кожен:
1. Коли оновлювався? (старі = погані)
2. Рейтинг на SpigotMC? (<4.0 = погано)
3. Скільки downloads? (<10k = ризик)
4. Підтримується? (abandoned = видалити)
```

#### Крок 3: А/Б Testing

```bash
# Видалити підозрілий плагін
/stop
rm plugins/SuspiciousPlugin.jar
# Запустити

# Профайл знову
/spark profiler --timeout 300

# Порівняти TPS
```

### Рішення

#### Фікс #1: Видалити погані плагіни

**Типові кандидати на видалення:**

```
❌ Holographic Displays (старий) → ✅ DecentHolograms
❌ FeatherBoard → ✅ TAB
❌ Citizens (якщо багато NPC) → обмежити кількість
❌ WorldEdit (на production) → тільки на build сервері
❌ Dynmap → ✅ BlueMap або відключити
```

#### Фікс #2: Оновити плагіни

```bash
# Перевірити версії
/version PluginName

# Оновити ВСІ до останніх версій
# Старі версії = багато багів = лаги
```

#### Фікс #3: Налаштувати плагіни

**LuckPerms:**
```yaml
# luckperms config
# Кешування = менше DB запитів
split-storage:
  enabled: true
  methods:
    user: h2    # Локальна БД
    group: h2
```

**EssentialsX:**
```yaml
# Essentials config
# Відключити непотрібне
use-bukkit-permissions: true
debug: false
update-check: false  # Не перевіряти оновлення кожні 5 хв
```

**CoreProtect:**
```yaml
# CoreProtect config
max-time: 30  # Зберігати логи 30 днів, не 60
queue-time: 10  # Писати у БД кожні 10 сек
```

#### Фікс #4: Async все що можна

Якщо ви розробник плагінів:

```java
// ГАРНИЙ КОД ✅
@EventHandler
public void onJoin(PlayerJoinEvent e) {
    // Async database query
    Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
        ResultSet rs = database.query(...);
        
        // Повернутись у main thread для Bukkit API
        Bukkit.getScheduler().runTask(plugin, () -> {
            player.sendMessage("Welcome!");
        });
    });
}
```

### Результат Plugin Fixes

**ДО:**
```
AwesomePlugin: 18.7%
Citizens: 12.3%
Dynmap: 8.5%
TPS: 17.2
```

**ПІСЛЯ (видалили/оновили):**
```
AwesomePlugin: removed
Citizens: 4.2% ✅ (оновили + обмежили NPC)
Dynmap: removed (BlueMap замість)
TPS: 19.3 ✅
```

**Приріст:** +2.1 TPS

## 🗺️ ПРОБЛЕМА #3: Chunk Loading (15%)

### Симптоми

```bash
/spark profiler:
Chunk Tick: 28% ← ПРОБЛЕМА!
├─ Chunk Loading: 15%
└─ Random Tick: 13%

Console:
[WARN] Can''t keep up! Server overloaded, skipping ticks
# Під час генерації нового світу або teleport
```

### Чому chunks лагають?

#### 1. Генерація нових чанків

```
1 chunk = 16×256×16 = 65,536 блоків
Генерація включає:
- Terrain generation (камінь, земля)
- Ore placement (руда)
- Cave generation (печери)
- Structure placement (села)
- Biome decoration (дерева, квіти)

Час: 50-200ms ПЕР CHUNK!
```

#### 2. Chunk Keep-Alive

```
50 гравців × 8 chunk view distance = 400 chunks
400 chunks × entity updates = лаги
```

#### 3. Random Ticks

```
Кожен chunk рандомно оновлює ~3 блоки за тік:
- Ріст рослин
- Лід/сніг
- Вода/лава
- Редстоун

400 chunks × 3 блоки = 1200 block updates/tick!
```

### Діагностика

```bash
/paper chunk list
# Покаже завантажені чанки

/spark profiler
# Шукати Chunk Tick >20%
```

### Рішення

#### Фікс #1: View Distance

```yaml
# server.properties
view-distance=6        # Було: 10
simulation-distance=4  # Було: 10

# paper.yml
delay-chunk-unloads-by: 10s  # Не вивантажувати відразу
```

**Що дає:**
- Менше чанків завантажено = менше обчислень
- 6 chunks = 113×113 блоків = достатньо
- TPS +2-3 пункти

**Trade-off:**
- Гравці бачать менше (але 96 блоків = OK)
- Entities спавняться ближче

#### Фікс #2: Pre-Generate World

```bash
# Chunky plugin
/chunky world world
/chunky radius 5000  # 5000 блоків від спавну
/chunky start

# Генерація займе 2-4 години
# Після - нуль лагів при exploration!
```

**Що дає:**
- Нові гравці НЕ генерують чанки = стабільний TPS
- Exploration без лагів

#### Фікс #3: Random Tick Speed

```yaml
# paper.yml
tick-rates:
  # Як часто рослини ростуть
  grass-spread: 4  # Було: 1 (повільніше)
  container-update: 1
  mob-spawner: 1
  
# in-game
/gamerule randomTickSpeed 2  # За замовчуванням 3
```

**Що дає:**
- Менше block updates = менше обчислень
- TPS +0.5-1 пункт

**Trade-off:**
- Рослини ростуть повільніше (~30%)

#### Фікс #4: Paper Anti-Xray

```yaml
# paper.yml
anti-xray:
  enabled: true
  engine-mode: 2  # Найшвидший
  # НЕ використовувати mode 1 - дуже лагає!
```

### Результат Chunk Fixes

**ДО:**
```
Chunk Tick: 28%
View Distance: 10
World: не pre-generated
TPS: 17.8
```

**ПІСЛЯ:**
```
Chunk Tick: 12% ✅
View Distance: 6
World: pre-generated ✅
TPS: 19.5 ✅
```

**Приріст:** +1.7 TPS

## ⚡ ПРОБЛЕМА #4: Redstone Lag Machines (8%)

### Симптоми

```bash
/spark profiler:
Redstone Tick: 15-25% ← ПРОБЛЕМА!

Console:
Excessive block updates detected
# Redstone loop або 0-tick farm
```

### Чому redstone лагає?

```
1 redstone update → перевірка 6 сусідів
Redstone clock 20Hz → 20 updates/sec × 6 = 120 перевірок
10 таких годинників = 1200 перевірок/sec

Складні схеми = тисячі updates = TPS падає
```

### Рішення

#### Фікс #1: Redstone Limiter

```yaml
# paper.yml
world-settings:
  default:
    redstone-implementation: ALTERNATE  # Швидша обробка
    
max-auto-save-chunks-per-tick: 12
optimize-explosions: true
```

#### Фікс #2: Знайти lag machines

```bash
# WorldGuard
/wg report -p

# Покаже чанки з найбільшою активністю
Chunk (234, 567): 450 block updates/sec ← ЛАГ МАШИНА!

# Телепортуватись
/tp @s 234 64 567

# Видалити схему
```

#### Фікс #3: Plugins для контролю

```bash
# RedstoneControl плагін
max-redstone-per-chunk: 100  # Макс 100 redstone блоків
disable-observer-clocks: true
```

### Результат: +0.5-2 TPS залежно від кількості lag machines

## 💾 ПРОБЛЕМА #5: Memory Leaks (7%)

### Симптоми

```bash
/spark tps
Memory: 15.8GB / 16GB (98%!) ← КРИТИЧНО!

Console:
[WARN] Garbage Collection took 850ms
[ERROR] OutOfMemoryError: Java heap space
# Сервер крашиться
```

### Діагностика

```bash
/spark heapsummary
# Покаже що займає памяті

/spark gcmonitor
# Моніторинг збирання сміття

# Якщо GC >100ms кожні 10 секунд = проблема
```

### Рішення

#### Фікс #1: Aikar''s Flags

```bash
# startup.sh (детально в модулі 2!)
java -Xms12G -Xmx12G \\
  -XX:+UseG1GC \\
  -XX:+ParallelRefProcEnabled \\
  -XX:MaxGCPauseMillis=200 \\
  -XX:+UnlockExperimentalVMOptions \\
  -XX:+DisableExplicitGC \\
  -XX:G1NewSizePercent=30 \\
  -XX:G1MaxNewSizePercent=40 \\
  -XX:G1HeapRegionSize=8M \\
  -XX:G1ReservePercent=20 \\
  -XX:G1HeapWastePercent=5 \\
  -jar server.jar
```

#### Фікс #2: Plugin Leaks

```bash
# Плагіни що часто лікають:
- Citizens (велик і NPC)
- Dynmap (велик і tiles)
- WorldEdit (великі копії)

# Видалити або оновити
```

#### Фікс #3: Більше RAM

```
Мінімум для серверу:
- 10 гравців: 4GB
- 50 гравців: 8GB
- 100+ гравців: 12-16GB
```

## 🎯 Комбінований приклад: від 15 до 19.8 TPS

### Початковий стан

```bash
/spark profiler:
Entity Tick: 48%
Plugin (ShopGUI): 18%
Chunk Tick: 22%
Redstone: 8%
TPS: 15.3 average
```

### План дій

1. ✅ Entities: spigot.yml + FarmLimiter
2. ✅ ShopGUI: замінити на EssentialsX  
3. ✅ Chunks: view-distance 6, pre-gen
4. ✅ Redstone: знайти lag machine
5. ✅ Memory: Aikar flags

### Результат

```bash
Entity Tick: 18% ✅ (-30%)
EssentialsX: 4% ✅ (-14%)
Chunk Tick: 11% ✅ (-11%)
Redstone: 3% ✅ (-5%)
TPS: 19.8 average ✅ (+4.5 TPS!)
```

## 🔑 Ключові висновки

1. **Entity overflow #1 причина** - завжди перевіряйте першим
2. **Один плагін може вбити TPS** - профайліть регулярно
3. **View distance 6-8** - оптимальний баланс
4. **Pre-generate world** - обов''язково перед запуском
5. **Знайти lag machines** - перевірити підозрілі чанки

## 📚 Домашнє завдання

1. Запустіть `/spark profiler` на 5 хвилин
2. Знайдіть ТОП-3 проблеми у вашому звіті
3. Застосуйте відповідні фікси з цього уроку
4. Запустіть профайл знову та порівняйте результати
5. Запишіть приріст TPS

**Підготуйтесь:** наступний урок - квіз перевірка знань!

---

**Наступний урок:** Квіз - перевірка знань модуля 1',
    3000,
    3,
    false
  );

  RAISE NOTICE 'Lesson 3 created!';
END $$;

SELECT l.title, l.order_index, l.duration
FROM course_lessons l
JOIN course_modules m ON m.id::text = l.module_id
WHERE m.course_id = 'paid-2' AND m.order_index = 1
ORDER BY l.order_index;
