import { CourseModule } from '../../types/lesson';

// Безкоштовний курс 6: Хостинг та продуктивність
export const hostingPerformanceModules: CourseModule[] = [
  {
    id: 'module-1',
    title: 'Вибір хостингу',
    description: 'Як обрати правильний хостинг',
    order: 1,
    lessons: [
      {
        id: 'lesson-1-1',
        title: 'Домашній сервер vs Хостинг',
        duration: '10 хв',
        type: 'text',
        content: `
# Домашній сервер vs Хостинг

Порівняємо різні варіанти розміщення Minecraft сервера.

## Домашній сервер

**Переваги:**
✅ Безкоштовно (окрім електрики)
✅ Повний контроль
✅ Необмежений доступ до файлів
✅ Можна експериментувати

**Недоліки:**
❌ Потрібен потужний ПК (8GB+ RAM)
❌ ПК має працювати 24/7
❌ Домашній інтернет (менша швидкість)
❌ Нестабільність через відключення світла
❌ Складність налаштування портів
❌ Ваша IP адреса видима гравцям

**Коли використовувати:**
- Тестування та навчання
- Гра з 2-5 друзями
- Невеликий whitelist сервер
- Експерименти з модами/плагінами

## Платний хостинг

**Переваги:**
✅ Висока швидкість інтернету
✅ 99.9% uptime (стабільність)
✅ Технічна підтримка
✅ DDoS захист
✅ Автоматичні бекапи
✅ Проста панель управління

**Недоліки:**
❌ Щомісячна оплата
❌ Обмеження ресурсів
❌ Менше контролю
❌ Залежність від провайдера

**Коли використовувати:**
- Публічний сервер
- 10+ гравців одночасно
- Серйозний проєкт
- Потрібна стабільність

## Порівняльна таблиця

\`\`\`
Характеристика    | Дома  | Хостинг
------------------|-------|--------
Ціна              | $0    | $5-50/міс
Продуктивність    | 3/5   | 5/5
Стабільність      | 2/5   | 5/5
Контроль          | 5/5   | 3/5
Складність        | 4/5   | 1/5
Масштабованість   | 1/5   | 5/5
\`\`\`

## VPS vs Shared Hosting

**Shared Hosting (спільний):**
- $3-15/місяць
- Обмежені ресурси
- Для 5-20 гравців
- Проста панель
- Приклад: Aternos, Minehut (безкоштовні), Shockbyte

**VPS (Virtual Private Server):**
- $10-50/місяць
- Виділені ресурси
- Для 20-100+ гравців
- Потрібні знання Linux
- Приклад: DigitalOcean, Linode, Vultr

**Dedicated Server (виділений):**
- $50-200+/місяць
- Фізичний сервер
- Для 100-500+ гравців
- Максимальна продуктивність
- Приклад: OVH, Hetzner

## Рекомендації

**Початківцям:**
1. Почніть з домашнього сервера
2. Перейдіть на Shared Hosting ($5-10/міс)
3. При зростанні → VPS

**Бюджет:**
- $0: Дома або Aternos
- $5-10: Shockbyte, Apex, Pebblehost
- $15-30: Надійний VPS (DigitalOcean)
- $50+: Dedicated для великого сервера
`,
      },
      {
        id: 'lesson-1-2',
        title: 'Вимоги до обладнання',
        duration: '12 хв',
        type: 'text',
        content: `
# Вимоги до обладнання

Розрахуємо потрібні ресурси для вашого сервера.

## RAM (Оперативна пам'ять)

**Базові вимоги:**

\`\`\`yaml
Vanilla (без модів):
  2-5 гравців: 1-2 GB
  5-10 гравців: 2-4 GB
  10-20 гравців: 4-6 GB
  20-50 гравців: 6-10 GB
  50-100 гравців: 10-16 GB

Modded (з модами):
  2-5 гравців: 3-4 GB
  5-10 гравців: 4-6 GB
  10-20 гравців: 6-10 GB
  20-50 гравців: 10-20 GB

Плагіни (Spigot/Paper):
  2-5 гравців: 1-2 GB
  5-10 гравців: 2-3 GB
  10-20 гравців: 3-5 GB
  20-50 гравців: 5-8 GB
  50-100 гравців: 8-12 GB
\`\`\`

**Фактори впливу:**
- Кількість плагінів/модів
- Розмір світу
- View distance
- Кількість entities (мобів, предметів)
- Chunk pre-generation

## CPU (Процесор)

**Minecraft однопоточний!**
- Краще висока частота, ніж багато ядер
- Мінімум: 2.5 GHz
- Рекомендовано: 3.5+ GHz
- Ideal: Intel i7/i9 або AMD Ryzen 7/9

**Орієнтовні вимоги:**

\`\`\`
Гравці    | Частота CPU
----------|------------
5-10      | 2.5+ GHz
10-20     | 3.0+ GHz
20-50     | 3.5+ GHz
50-100    | 4.0+ GHz
100+      | 4.5+ GHz + багатосерверна архітектура
\`\`\`

## Диск (SSD обов'язково!)

**Простір:**
- Мінімум: 5 GB
- Рекомендовано: 10-20 GB
- З бекапами: 50-100 GB

**Тип диску:**
- ❌ HDD - повільно, лаги при завантаженні чанків
- ✅ SSD - швидко, плавна гра
- ✅✅ NVMe SSD - найшвидше

**Чому SSD важливий:**
\`\`\`
Завантаження чанку:
HDD: 50-100ms
SSD: 5-10ms
NVMe: 1-3ms
\`\`\`

## Інтернет

**Швидкість завантаження (Upload):**
\`\`\`
5-10 гравців: 5+ Mbps
10-20 гравців: 10+ Mbps
20-50 гравців: 20+ Mbps
50-100 гравців: 50+ Mbps
\`\`\`

**Важливо:**
- Upload швидкість (не download!)
- Низький ping до гравців
- Стабільність з'єднання

## Калькулятор ресурсів

**Формула RAM:**
\`\`\`
Base (OS) = 1GB
Per player = 50-100MB
Plugins = 200MB-2GB
World = 500MB-2GB

Приклад (20 гравців, 30 плагінів):
1GB + (20 × 75MB) + 1GB + 1GB = 4.5GB
Рекомендовано: 6GB (з запасом)
\`\`\`

## Поради по оптимізації

1. **Не виділяйте більше RAM, ніж потрібно**
   - Більше ≠ краще
   - Оптимальний range: 4-10GB

2. **View distance = 6-8**
   - Default 10 - занадто багато
   - 6 - баланс між продуктивністю та видимістю

3. **Pre-generate world**
   - Генерація чанків заздалегідь
   - Усуває лаги під час дослідження

4. **Регулярні restart**
   - Кожні 12-24 години
   - Очищує пам'ять
`,
        codeExamples: [
          {
            id: 'example-1',
            title: 'Скрипт запуску з оптимальними параметрами',
            language: 'bash',
            code: `#!/bin/bash
# Minecraft Server Start Script

# RAM allocation (встановіть відповідно до ваших потреб)
MIN_RAM="2G"
MAX_RAM="4G"

# Оптимізовані Java параметри
JAVA_FLAGS="-Xms$MIN_RAM -Xmx$MAX_RAM \\
  -XX:+UseG1GC \\
  -XX:+ParallelRefProcEnabled \\
  -XX:MaxGCPauseMillis=200 \\
  -XX:+UnlockExperimentalVMOptions \\
  -XX:+DisableExplicitGC \\
  -XX:G1NewSizePercent=30 \\
  -XX:G1MaxNewSizePercent=40 \\
  -XX:G1HeapRegionSize=8M \\
  -XX:G1ReservePercent=20"

# Запуск сервера
java $JAVA_FLAGS -jar paper.jar --nogui`,
            explanation: 'Оптимізований скрипт запуску для Paper сервера',
          },
        ],
      },
      {
        id: 'lesson-1-3',
        title: 'Огляд популярних хостингів',
        duration: '15 хв',
        type: 'quiz',
        content: '',
        quiz: {
          id: 'quiz-1-3',
          questions: [
            {
              id: 'q1',
              question: 'Скільки RAM потрібно для 20 гравців на Spigot сервері?',
              options: ['1-2 GB', '2-3 GB', '3-5 GB', '8-10 GB'],
              correctAnswer: 2,
              explanation: 'Для 20 гравців на Spigot/Paper рекомендується 3-5 GB RAM з урахуванням плагінів.',
            },
            {
              id: 'q2',
              question: 'Чому SSD краще за HDD для Minecraft сервера?',
              options: [
                'Більше місця',
                'Дешевше',
                'Швидше завантаження чанків',
                'Краще виглядає',
              ],
              correctAnswer: 2,
              explanation: 'SSD значно швидше завантажує чанки (5-10ms vs 50-100ms на HDD), що усуває лаги.',
            },
            {
              id: 'q3',
              question: 'Що важливіше для Minecraft сервера?',
              options: [
                'Багато ядер CPU',
                'Висока частота CPU',
                'Велика відеокарта',
                'Багато місця на диску',
              ],
              correctAnswer: 1,
              explanation: 'Minecraft однопоточний, тому висока частота CPU (3.5+ GHz) важливіша за кількість ядер.',
            },
            {
              id: 'q4',
              question: 'Яка швидкість Upload потрібна для 10 гравців?',
              options: ['1 Mbps', '5 Mbps', '10 Mbps', '50 Mbps'],
              correctAnswer: 2,
              explanation: 'Для 10 гравців рекомендується мінімум 10 Mbps Upload швидкість для стабільної гри.',
            },
          ],
        },
      },
    ],
  },
  {
    id: 'module-2',
    title: 'Оптимізація Java',
    description: 'Налаштування JVM для максимальної продуктивності',
    order: 2,
    lessons: [
      {
        id: 'lesson-2-1',
        title: 'Параметри запуску Java',
        duration: '15 хв',
        type: 'text',
        content: `
# Параметри запуску Java

Правильні параметри JVM можуть покращити продуктивність на 20-40%.

## Базові параметри

**Виділення пам'яті:**

\`\`\`bash
-Xms4G  # Початковий розмір heap
-Xmx4G  # Максимальний розмір heap
\`\`\`

**Важливо:**
- Xms та Xmx мають бути однакові!
- Не виділяйте більше 10-12GB (Java обмеження)
- Залиште 1-2GB для системи

## Garbage Collector (G1GC)

G1GC - найкращий збирач сміття для Minecraft:

\`\`\`bash
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
\`\`\`

**Що це робить:**
- \`UseG1GC\` - використовує G1 Garbage Collector
- \`ParallelRefProcEnabled\` - паралельна обробка посилань
- \`MaxGCPauseMillis=200\` - максимальна пауза 200ms
- \`DisableExplicitGC\` - вимикає примусове збирання сміття

## Тонке налаштування G1GC

\`\`\`bash
-XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40
-XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20
-XX:G1HeapWastePercent=5
-XX:G1MixedGCCountTarget=4
-XX:InitiatingHeapOccupancyPercent=15
-XX:G1MixedGCLiveThresholdPercent=90
-XX:G1RSetUpdatingPauseTimePercent=5
\`\`\`

## Aikar's Flags (Рекомендовані)

Найпопулярніші flags від Aikar (Paper developer):

\`\`\`bash
java -Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled \\
-XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions \\
-XX:+DisableExplicitGC -XX:+AlwaysPreTouch \\
-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \\
-XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 \\
-XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \\
-XX:InitiatingHeapOccupancyPercent=15 \\
-XX:G1MixedGCLiveThresholdPercent=90 \\
-XX:G1RSetUpdatingPauseTimePercent=5 \\
-XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem \\
-XX:MaxTenuringThreshold=1 \\
-Dusing.aikars.flags=https://mcflags.emc.gs \\
-Daikars.new.flags=true \\
-jar paper.jar --nogui
\`\`\`

## Для різних розмірів RAM

**2-4 GB:**
\`\`\`bash
-Xms2G -Xmx2G -XX:+UseG1GC \\
-XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \\
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \\
-XX:G1HeapRegionSize=4M
\`\`\`

**4-8 GB:**
\`\`\`bash
-Xms6G -Xmx6G -XX:+UseG1GC \\
-XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \\
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \\
-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \\
-XX:G1HeapRegionSize=8M
\`\`\`

**8-12 GB:**
\`\`\`bash
# Використовуйте повні Aikar's flags
\`\`\`

## Моніторинг GC

Для перевірки роботи:

\`\`\`bash
# Додайте до flags:
-Xlog:gc*:file=gc.log:time,uptime:filecount=5,filesize=1M
\`\`\`

Аналізуйте gc.log для виявлення проблем.

## Поради

1. **Не змінюйте все одразу**
   - Почніть з базових параметрів
   - Додавайте по одному
   - Тестуйте після кожної зміни

2. **Моніторте TPS**
   - Використовуйте Spark або Timings
   - TPS має бути 20.0

3. **Restart регулярно**
   - Навіть з оптимізаціями
   - Очищає memory leaks
`,
        codeExamples: [
          {
            id: 'example-1',
            title: 'start.bat для Windows',
            language: 'batch',
            code: `@echo off
title Minecraft Server

REM === Налаштування RAM ===
set MIN_RAM=4G
set MAX_RAM=4G

REM === Java flags ===
set FLAGS=-Xms%MIN_RAM% -Xmx%MAX_RAM% ^
-XX:+UseG1GC ^
-XX:+ParallelRefProcEnabled ^
-XX:MaxGCPauseMillis=200 ^
-XX:+UnlockExperimentalVMOptions ^
-XX:+DisableExplicitGC ^
-XX:G1NewSizePercent=30 ^
-XX:G1MaxNewSizePercent=40 ^
-XX:G1HeapRegionSize=8M

REM === Запуск ===
java %FLAGS% -jar paper.jar --nogui

pause`,
            explanation: 'Batch скрипт для запуску на Windows з оптимізованими параметрами',
          },
          {
            id: 'example-2',
            title: 'start.sh для Linux',
            language: 'bash',
            code: `#!/bin/bash

# === Налаштування ===
MIN_RAM="4G"
MAX_RAM="4G"

# === Java flags ===
FLAGS="-Xms$MIN_RAM -Xmx$MAX_RAM \\
  -XX:+UseG1GC \\
  -XX:+ParallelRefProcEnabled \\
  -XX:MaxGCPauseMillis=200 \\
  -XX:+UnlockExperimentalVMOptions \\
  -XX:+DisableExplicitGC \\
  -XX:G1NewSizePercent=30 \\
  -XX:G1MaxNewSizePercent=40 \\
  -XX:G1HeapRegionSize=8M"

# === Запуск ===
java $FLAGS -jar paper.jar --nogui`,
            explanation: 'Shell скрипт для запуску на Linux/Mac з оптимізованими параметрами',
          },
        ],
      },
      {
        id: 'lesson-2-2',
        title: 'Оптимізація server.properties',
        duration: '12 хв',
        type: 'text',
        content: `
# Оптимізація server.properties

Налаштуємо конфігурацію сервера для кращої продуктивності.

## Основні параметри

\`server.properties\`:

\`\`\`properties
# === View Distance ===
view-distance=6
simulation-distance=4

# === Entities ===
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
max-world-size=29999984

# === Network ===
network-compression-threshold=256
max-tick-time=60000

# === Мобы ===
spawn-limits.monster=70
spawn-limits.creature=10
spawn-limits.ambient=15
spawn-limits.water-creature=5

# === Інше ===
entity-broadcast-range-percentage=100
\`\`\`

## View Distance - найважливіше!

**Що це:**
- Скільки чанків бачить гравець
- 1 view distance = 16 блоків

**Вплив на продуктивність:**
\`\`\`
View Distance | Чанки | Вплив
--------------|-------|-------
4             | 81    | Мінімальний
6             | 169   | Збалансований ✅
8             | 225   | Середній
10 (default)  | 441   | Високий
12            | 625   | Дуже високий
\`\`\`

**Рекомендації:**
- 4-6: для слабких серверів
- 6-8: оптимально
- 8-10: для потужних серверів

## Simulation Distance

**Що це:**
- На якій відстані працюють механіки (ферми, мобспавн)
- Може бути менше view-distance

**Налаштування:**
\`\`\`properties
view-distance=8
simulation-distance=4
\`\`\`

Гравець бачить 8 чанків, але ферми працюють тільки в 4.

## Спавн мобів

**Ліміти:**
\`\`\`properties
# Кількість мобів на гравця
spawn-limits.monster=70    # Вороже мобы
spawn-limits.creature=10   # Тварини
spawn-limits.ambient=15    # Кажани
spawn-limits.water-creature=5  # Риба, кальмари
spawn-limits.water-ambient=20  # Тропічна риба
\`\`\`

**Для лагового сервера:**
\`\`\`properties
spawn-limits.monster=50
spawn-limits.creature=5
spawn-limits.ambient=5
spawn-limits.water-creature=3
\`\`\`

## Network оптимізація

\`\`\`properties
# Стискання пакетів (256 default)
network-compression-threshold=256

# Для повільного інтернету:
network-compression-threshold=128

# Для швидкого інтернету:
network-compression-threshold=512
\`\`\`

## Entity Broadcast Range

\`\`\`properties
# Відсоток від view-distance для entities
entity-broadcast-range-percentage=100

# Для оптимізації (гравці бачать мобів ближче):
entity-broadcast-range-percentage=75
\`\`\`

## Max Tick Time

\`\`\`properties
# Час на один tick (мілісекунди)
max-tick-time=60000

# -1 = необмежено (для лагових серверів)
max-tick-time=-1
\`\`\`

## Збалансована конфігурація

\`\`\`properties
# === Оптимізована конфігурація ===
view-distance=6
simulation-distance=4
spawn-limits.monster=60
spawn-limits.creature=8
spawn-limits.ambient=10
spawn-limits.water-creature=4
network-compression-threshold=256
entity-broadcast-range-percentage=80
max-tick-time=-1
\`\`\`
`,
      },
      {
        id: 'lesson-2-3',
        title: 'Paper/Spigot конфігурація',
        duration: '18 хв',
        type: 'text',
        content: `
# Paper/Spigot конфігурація

Глибокі налаштування Paper та Spigot для максимальної оптимізації.

## paper-global.yml (Paper 1.19+)

\`\`\`yaml
# === Chunk Loading ===
chunk-loading:
  max-concurrent-sends: 2
  min-load-radius: 2
  autoconfig-send-distance: true
  target-player-chunk-send-rate: 100.0

# === Async Chunks ===
async-chunks:
  threads: 4

# === Entities ===
entities:
  spawning:
    all-chunks-are-slime-chunks: false
    alt-item-despawn-rate:
      enabled: true
      items:
        cobblestone: 300
        netherrack: 300
        sand: 300
        red_sand: 300
        gravel: 300
        dirt: 300
  
  behavior:
    disable-chest-cat-detection: true
    spawner-nerfed-mobs-should-jump: false
    
  tracking:
    # Оновлення позицій entities
    tracking-range-y:
      enabled: true
      animal: 3
      monster: 3
      misc: 3
      other: 3
      player: 3

# === Misc ===
misc:
  max-joins-per-tick: 3
  fix-entity-position-desync: true
  lag-compensate-block-breaking: true
\`\`\`

## paper-world-defaults.yml

\`\`\`yaml
# === Антігрифер оптимізації ===
anticheat:
  anti-xray:
    enabled: true
    engine-mode: 1
    max-block-height: 64
    hidden-blocks:
      - copper_ore
      - deepslate_copper_ore
      - gold_ore
      - deepslate_gold_ore
      - iron_ore
      - deepslate_iron_ore
      - coal_ore
      - deepslate_coal_ore
      - lapis_ore
      - deepslate_lapis_ore
      - diamond_ore
      - deepslate_diamond_ore
      - redstone_ore
      - deepslate_redstone_ore
      - emerald_ore
      - deepslate_emerald_ore

# === Entities ===
entities:
  spawning:
    # Де-спавн відстані
    despawn-ranges:
      monster:
        soft: 32
        hard: 128
      creature:
        soft: 32
        hard: 128
      ambient:
        soft: 32
        hard: 128
      water_creature:
        soft: 32
        hard: 128
    
    # Ліміти спавну
    per-player-mob-spawns: true
    spawn-limits:
      monster: 70
      creature: 10
      ambient: 15
      water_creature: 5

  behavior:
    # Оптимізації AI
    disable-creeper-lingering-effect: true
    disable-mob-spawner-spawn-egg-transformation: true
    ender-dragons-death-always-places-dragon-egg: false
    
# === Tick-rates ===
tick-rates:
  sensor:
    villager:
      secondarypoisensor: 40
  behavior:
    villager:
      validatenearbypoi: -1

# === Hopper оптимізація ===
hopper:
  cooldown-when-full: true
  disable-move-event: false

# === Feature Seeds ===
feature-seeds:
  generate-random-seeds-for-all: false
\`\`\`

## spigot.yml (для Spigot)

\`\`\`yaml
# === World Settings ===
world-settings:
  default:
    # View distance
    view-distance: default
    
    # Mob spawn range
    mob-spawn-range: 6
    
    # Entity tracking
    entity-tracking-range:
      players: 48
      animals: 48
      monsters: 48
      misc: 32
      other: 64
    
    # Entity activation range
    entity-activation-range:
      animals: 32
      monsters: 32
      raiders: 48
      misc: 16
      water: 16
      villagers: 32
      flying-monsters: 32
    
    # Tick rates
    tick-inactive-villagers: false
    nerf-spawner-mobs: false
    
    # Growth
    growth:
      cactus-modifier: 100
      cane-modifier: 100
      melon-modifier: 100
      mushroom-modifier: 100
      pumpkin-modifier: 100
      sapling-modifier: 100
      beetroot-modifier: 100
      carrot-modifier: 100
      potato-modifier: 100
      wheat-modifier: 100
      netherwart-modifier: 100
      vine-modifier: 100
      cocoa-modifier: 100
      bamboo-modifier: 100
      sweetberry-modifier: 100
      kelp-modifier: 100
    
    # Merge Radius
    merge-radius:
      item: 2.5
      exp: 3.0
    
    # Hopper
    hopper-transfer: 8
    hopper-check: 1
\`\`\`

## Агресивна оптимізація

Для дуже лагових серверів:

\`\`\`yaml
# paper-world-defaults.yml
entities:
  spawning:
    spawn-limits:
      monster: 50
      creature: 5
      ambient: 5
      water_creature: 3
    
    despawn-ranges:
      monster:
        soft: 28
        hard: 96
      creature:
        soft: 28
        hard: 96

tick-rates:
  sensor:
    villager:
      secondarypoisensor: 80
  behavior:
    villager:
      validatenearbypoi: -1

# spigot.yml
entity-activation-range:
  animals: 16
  monsters: 24
  raiders: 32
  misc: 8
  water: 12
  villagers: 24
  flying-monsters: 32
\`\`\`

## Після змін

1. Перезавантажте сервер
2. Моніторте TPS через Spark
3. Корегуйте параметри
4. Тестуйте з гравцями
`,
        codeExamples: [
          {
            id: 'example-1',
            title: 'Збалансована Paper конфігурація',
            language: 'yaml',
            code: `# paper-global.yml
chunk-loading:
  max-concurrent-sends: 2
  min-load-radius: 2
  target-player-chunk-send-rate: 100.0

async-chunks:
  threads: 4

entities:
  behavior:
    disable-chest-cat-detection: true
    spawner-nerfed-mobs-should-jump: false

# paper-world-defaults.yml
entities:
  spawning:
    per-player-mob-spawns: true
    spawn-limits:
      monster: 60
      creature: 8
      ambient: 10
      water_creature: 4

hopper:
  cooldown-when-full: true`,
            explanation: 'Оптимізована конфігурація для 20-50 гравців',
          },
        ],
      },
    ],
  },
  {
    id: 'module-3',
    title: 'Моніторинг та підтримка',
    description: 'Відстеження продуктивності сервера',
    order: 3,
    lessons: [
      {
        id: 'lesson-3-1',
        title: 'Spark - профілювання',
        duration: '15 хв',
        type: 'text',
        content: `
# Spark - профілювання сервера

Spark - найкращий інструмент для аналізу продуктивності Minecraft серверів.

## Встановлення Spark

1. **Завантажте:**
   - https://spark.lucko.me/download
   - Підтримує Bukkit, Spigot, Paper, Fabric, Forge

2. **Встановіть:**
   \`\`\`
   Покладіть spark.jar в plugins/ (або mods/)
   Перезапустіть сервер
   \`\`\`

## Базові команди

**Профілювання CPU:**
\`\`\`
/spark profiler start
# Зачекайте 1-2 хвилини
/spark profiler stop
\`\`\`

Отримаєте посилання на веб-звіт.

**Heap профілювання:**
\`\`\`
/spark heapsummary
\`\`\`

**TPS моніторинг:**
\`\`\`
/spark tps
\`\`\`

## Читання результатів

**CPU Profiler покаже:**

1. **Найбільш навантажені методи:**
   \`\`\`
   net.minecraft.world.entity.Mob.tick - 45%
   com.example.plugin.Task - 12%
   net.minecraft.world.level.chunk.ChunkGenerator - 8%
   \`\`\`

2. **Проблемні плагіни:**
   - Якщо плагін займає >10% - потрібна оптимізація
   - >20% - критична проблема

3. **Ігрові механіки:**
   - Entity ticking
   - Chunk generation
   - Redstone

## Аналіз типових проблем

**Проблема: Entity lag**
\`\`\`
Симптоми:
  net.minecraft.world.entity - 60%+

Рішення:
  - Зменшити spawn-limits
  - Знайти ферми з великою кількістю мобів
  - Використати entity limiting плагін
\`\`\`

**Проблема: Chunk generation**
\`\`\`
Симптоми:
  ChunkGenerator - 40%+

Рішення:
  - Pre-generate світ (Chunky)
  - Зменшити view-distance
  - Використати Paper з aggressive optimizations
\`\`\`

**Проблема: Redstone lag**
\`\`\`
Симптоми:
  RedstoneWire.tick - 30%+

Рішення:
  - Обмежити розмір redstone circuits
  - Використати optimized redstone плагін
  - Заборонити проблемні механіки
\`\`\`

**Проблема: Плагін lag**
\`\`\`
Симптоми:
  com.plugin.Name - 25%+

Рішення:
  - Оновити плагін
  - Змінити конфігурацію
  - Знайти альтернативу
  - Видалити, якщо не критичний
\`\`\`

## Heap Summary

\`\`\`
/spark heapsummary
\`\`\`

**Покаже:**
- Які об'єкти займають пам'ять
- Memory leaks
- Неоптимальне використання RAM

**Приклад проблем:**
\`\`\`
ItemStack - 800MB
  → Занадто багато предметів на землі
  → Item merge radius замалий

Player data - 1.2GB
  → Memory leak в плагіні
  → Некоректне очищення даних
\`\`\`

## Автоматичний моніторинг

**Налаштування:**

1. **Активуйте health reporting:**
   \`\`\`
   /spark health --memory --network
   \`\`\`

2. **Автоматичні профілі при лагах:**
   \`\`\`yaml
   # plugins/spark/config.json
   {
     "backgroundProfiler": {
       "enabled": true,
       "engine": "async",
       "interval": 600,
       "threadDumper": true
     }
   }
   \`\`\`

## Поради

1. **Регулярно профілюйте**
   - Раз на тиждень мінімум
   - Після додавання плагінів
   - При скаргах на лаги

2. **Порівнюйте результати**
   - Зберігайте посилання на звіти
   - Порівнюйте до/після оптимізацій

3. **Аналізуйте на піках**
   - Профілюйте під час найбільшого онлайну
   - Реальні умови навантаження
`,
      },
      {
        id: 'lesson-3-2',
        title: 'Chunky - Pre-generation',
        duration: '10 хв',
        type: 'text',
        content: `
# Chunky - Pre-generation світу

Pre-generation усуває лаги від генерації нових чанків під час гри.

## Навіщо потрібно?

**Проблема:**
- Гравець йде в нові території
- Сервер генерує чанки в реальному часі
- TPS падає до 10-15
- Всі гравці відчувають лаг

**Рішення:**
- Згенерувати світ заздалегідь
- Нулеві лаги від генерації
- Стабільний TPS

## Встановлення Chunky

\`\`\`
/chunky help
\`\`\`

Або завантажте:
- https://www.spigotmc.org/resources/chunky.81534/

## Використання

**Базова команда:**
\`\`\`
/chunky world <world_name>
/chunky radius 5000
/chunky start
\`\`\`

Генерує квадрат 10000x10000 блоків (5000 в кожен бік від 0,0).

**Для кількох світів:**
\`\`\`
# Overworld
/chunky world world
/chunky radius 5000
/chunky start

# Nether
/chunky world world_nether
/chunky radius 2500
/chunky start

# End
/chunky world world_the_end
/chunky radius 2500
/chunky start
\`\`\`

## Оптимальні радіуси

\`\`\`yaml
Розмір сервера | Overworld | Nether | End
---------------|-----------|--------|-----
Малий (5-10)   | 3000      | 1500   | 1500
Середній (20)  | 5000      | 2500   | 2000
Великий (50+)  | 10000     | 5000   | 3000
\`\`\`

## Моніторинг прогресу

\`\`\`
/chunky progress
\`\`\`

**Покаже:**
- Відсоток виконання
- Швидкість генерації
- Час до завершення

## Управління

**Пауза:**
\`\`\`
/chunky pause
\`\`\`

**Продовження:**
\`\`\`
/chunky continue
\`\`\`

**Скасування:**
\`\`\`
/chunky cancel
\`\`\`

## Налаштування швидкості

\`plugins/Chunky/config.yml\`:

\`\`\`yaml
# Chunks за tick
chunks-per-tick: 10

# Для швидшої генерації (може лагати):
chunks-per-tick: 20

# Для безпечної генерації під час гри:
chunks-per-tick: 5
\`\`\`

## Поради

**1. Генеруйте до запуску:**
- Найкраще на порожньому сервері
- Швидше і без лагів для гравців

**2. Розбивайте на сесії:**
\`\`\`
# День 1:
/chunky radius 2000
/chunky start

# День 2:
/chunky radius 4000
/chunky start

# День 3:
/chunky radius 6000
/chunky start
\`\`\`

**3. Моніторте ресурси:**
- CPU може бути на 100%
- Це нормально для генерації
- Час на генерацію залежить від CPU

**4. Час генерації (орієнтовно):**
\`\`\`
Радіус 5000:
  Сильний CPU (4.0+ GHz): 2-4 години
  Середній CPU (3.0 GHz): 6-10 годин
  Слабкий CPU (2.5 GHz): 12-24 години
\`\`\`

**5. Після генерації:**
\`\`\`
/chunky trim
\`\`\`
Видаляє непотрібні чанки за межами.
`,
      },
      {
        id: 'lesson-3-3',
        title: 'Бекапи та відновлення',
        duration: '12 хв',
        type: 'quiz',
        content: '',
        quiz: {
          id: 'quiz-3-3',
          questions: [
            {
              id: 'q1',
              question: 'Що показує команда /spark profiler?',
              options: [
                'Кількість гравців',
                'Які методи найбільше навантажують CPU',
                'Розмір світу',
                'Швидкість інтернету',
              ],
              correctAnswer: 1,
              explanation: 'Spark profiler показує, які методи (коду, плагінів, механік) найбільше навантажують процесор.',
            },
            {
              id: 'q2',
              question: 'Що робить Chunky pre-generation?',
              options: [
                'Видаляє старі чанки',
                'Генерує чанки заздалегідь',
                'Стискає чанки',
                'Збільшує view distance',
              ],
              correctAnswer: 1,
              explanation: 'Chunky генерує чанки заздалегідь, щоб уникнути лагів під час дослідження нових територій.',
            },
            {
              id: 'q3',
              question: 'Який оптимальний радіус pre-generation для малого сервера?',
              options: ['1000 блоків', '3000 блоків', '10000 блоків', '50000 блоків'],
              correctAnswer: 1,
              explanation: 'Для малого сервера (5-10 гравців) оптимально згенерувати 3000 блоків у всі сторони.',
            },
            {
              id: 'q4',
              question: 'Як часто потрібно профілювати сервер?',
              options: [
                'Кожну годину',
                'Щодня',
                'Раз на тиждень мінімум',
                'Раз на рік',
              ],
              correctAnswer: 2,
              explanation: 'Рекомендується профілювати мінімум раз на тиждень, після додавання плагінів та при скаргах на лаги.',
            },
          ],
        },
      },
    ],
  },
];
