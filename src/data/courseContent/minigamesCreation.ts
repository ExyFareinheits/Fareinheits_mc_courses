import { CourseModule } from '../../types/lesson';

// Безкоштовний курс 5: Створення міні-ігор
export const minigamesCreationModules: CourseModule[] = [
  {
    id: 'module-1',
    title: 'Основи міні-ігор',
    description: 'Вступ до світу міні-ігор',
    order: 1,
    lessons: [
      {
        id: 'lesson-1-1',
        title: 'Що таке міні-ігри?',
        duration: '8 хв',
        type: 'text',
        content: `
# Що таке міні-ігри в Minecraft?

Міні-ігри - це короткі, динамічні ігрові режими з чіткими правилами та цілями.

## Популярні міні-ігри

**PvP орієнтовані:**
- **BedWars** - захист ліжка, руйнування ліжок ворогів
- **SkyWars** - битва на островах у небі
- **Hunger Games** - королевська битва в стилі Minecraft
- **KitPvP** - PvP з набором екіпірування

**PvE та Co-op:**
- **SpleefБіг по арені, руйнуючи блоки під опонентами
- **TNT Run** - біг по платформі, що зникає
- **Parkour** - стрибки та перешкоди
- **Build Battle** - змагання на будівництво

## Чому міні-ігри популярні?

**Швидкі сесії:**
- 5-15 хвилин на гру
- Підходить для casual гравців
- Легко зайти і вийти

**Конкурентність:**
- Рейтинги та статистика
- Можливість прогресувати
- Досягнення та винагороди

**Різноманітність:**
- Різні стилі гри
- Регулярні оновлення
- Сезонні події

## Архітектура міні-ігор

\`\`\`
Лобі (Hub)
  ├── Портали до міні-ігор
  ├── NPC з інформацією
  └── Область статистики
  
BedWars Arena
  ├── 4-8 островів команд
  ├── Центральний острів з ресурсами
  └── Генератори ресурсів
  
SkyWars Arena
  ├── Острови гравців (8-16)
  ├── Центральний острів
  └── Сундуки з лутом
\`\`\`

## Необхідні компоненти

1. **Лобі сервер** - центральний хаб
2. **Ігрові арени** - окремі світи
3. **Плагіни** - логіка міні-ігор
4. **BungeeCord/Velocity** - з'єднання серверів (опціонально)

У наступних уроках створимо повноцінні міні-ігри!
`,
      },
      {
        id: 'lesson-1-2',
        title: 'Планування та дизайн',
        duration: '12 хв',
        type: 'text',
        content: `
# Планування міні-ігор

Перш ніж почати будувати, потрібно все спланувати.

## Крок 1: Вибір міні-ігор

**Для початку рекомендуємо:**
1. BedWars (найпопулярніша)
2. SkyWars (проста у налаштуванні)
3. Один custom режим (унікальність)

**Критерії вибору:**
- Популярність на інших серверах
- Складність реалізації
- Ваші ресурси (час, навички)
- Цільова аудиторія

## Крок 2: Дизайн лобі

**Ключові зони:**

\`\`\`yaml
Spawn Point:
  - Безпечна область
  - Правила сервера
  - Інформація про донати

Portal Area:
  - Портали до кожної міні-гри
  - NPC з описом
  - Статистика поруч

Leaderboards:
  - Топ гравців
  - Статистика міні-ігор
  - Досягнення
  
Cosmetics Area:
  - Вибір pets
  - Частинки
  - Кастомізація
\`\`\`

## Крок 3: Дизайн арен

**BedWars Arena (4v4v4v4):**
\`\`\`
- Розмір: 100x100 блоків
- Відстань між островами: 30-40 блоків
- Висота: Y=64-90
- Центральний острів: 20x20
\`\`\`

**SkyWars Arena (12 гравців):**
\`\`\`
- Розмір: 80x80 блоків
- 12 островів + центральний
- Відстань: 15-20 блоків
- Середній лут в сундуках
\`\`\`

## Крок 4: Баланс гри

**Важливі аспекти:**

1. **Час гри:**
   - BedWars: 15-25 хвилин
   - SkyWars: 5-10 хвилин
   - Hunger Games: 10-15 хвилин

2. **Економіка (BedWars):**
   \`\`\`
   Iron (кожні 2 сек) → базові предмети
   Gold (кожні 10 сек) → покращення
   Diamond (центр) → потужні речі
   Emerald (центр, рідко) → унікальні предмети
   \`\`\`

3. **Лут (SkyWars):**
   \`\`\`
   Island Chests: 30% - base loot
   Center Chests: 60% - good loot
   Special Chests: 80% - best loot
   \`\`\`

## Крок 5: Прототипування

Перед фінальною побудовою:
1. Створіть тестову версію
2. Зіграйте з друзями
3. Збирайте відгуки
4. Корегуйте баланс
5. Будуйте фінальну версію
`,
        codeExamples: [
          {
            id: 'example-1',
            title: 'Схема розташування BedWars арени',
            language: 'yaml',
            code: `# Координати команд (приклад для 4 команд)
teams:
  red:
    spawn: [50, 70, 50]
    bed: [52, 70, 52]
    color: RED
  
  blue:
    spawn: [-50, 70, 50]
    bed: [-52, 70, 52]
    color: BLUE
  
  green:
    spawn: [50, 70, -50]
    bed: [52, 70, -52]
    color: GREEN
  
  yellow:
    spawn: [-50, 70, -50]
    bed: [-52, 70, -52]
    color: YELLOW

center:
  diamonds: [0, 75, 0]
  emeralds: [0, 78, 0]`,
            explanation: 'Базова схема розташування для 4 команд у BedWars',
          },
        ],
      },
      {
        id: 'lesson-1-3',
        title: 'Побудова лобі',
        duration: '15 хв',
        type: 'quiz',
        content: '',
        quiz: {
          id: 'quiz-1-3',
          questions: [
            {
              id: 'q1',
              question: 'Яка середня тривалість гри в SkyWars?',
              options: ['2-5 хвилин', '5-10 хвилин', '15-20 хвилин', '30+ хвилин'],
              correctAnswer: 1,
              explanation: 'SkyWars - це швидка міні-гра, що зазвичай триває 5-10 хвилин.',
            },
            {
              id: 'q2',
              question: 'Яка відстань рекомендується між островами в BedWars?',
              options: ['10-15 блоків', '20-25 блоків', '30-40 блоків', '50+ блоків'],
              correctAnswer: 2,
              explanation: 'Оптимальна відстань 30-40 блоків дозволяє зручно будувати мости.',
            },
            {
              id: 'q3',
              question: 'Який найважливіший ресурс у BedWars?',
              options: ['Iron', 'Gold', 'Diamond', 'Emerald'],
              correctAnswer: 0,
              explanation: 'Iron - основний ресурс для базових покупок та блоків для будівництва.',
            },
          ],
        },
      },
    ],
  },
  {
    id: 'module-2',
    title: 'Налаштування BedWars',
    description: 'Створення популярної міні-гри',
    order: 2,
    lessons: [
      {
        id: 'lesson-2-1',
        title: 'Встановлення BedWars плагіну',
        duration: '10 хв',
        type: 'text',
        content: `
# Встановлення BedWars плагіну

Найпопулярніші плагіни для BedWars:

## BedWars1058

**Найкраща версія для новачків:**

1. **Завантажте:**
   - https://www.spigotmc.org/resources/bedwars1058.50942/
   - Безкоштовний та open-source
   - Активна підтримка

2. **Встановлення:**
   \`\`\`
   1. Покладіть в plugins/
   2. Перезапустіть сервер
   3. З'являться папки:
      - plugins/BedWars1058/
      - plugins/BedWars1058/Arenas/
      - plugins/BedWars1058/Languages/
   \`\`\`

## Базова конфігурація

\`plugins/BedWars1058/config.yml\`:

\`\`\`yaml
# Налаштування гри
respawn-cooldown: 5
game-start-countdown: 10
next-event-time: 300

# Генератори
generator:
  iron:
    delay: 40  # тіки (2 сек)
    amount: 1
    spawn-limit: 40
  
  gold:
    delay: 200  # тіки (10 сек)
    amount: 1
    spawn-limit: 10

# Налаштування команд
team-size: 4
teams-per-arena: 4
\`\`\`

## Основні команди

**Адміністратору:**
\`\`\`
/bw setuparena <назва> - почати створення арени
/bw setspawn <команда> - встановити спавн команди
/bw setbed <команда> - встановити позицію ліжка
/bw setshop - встановити NPC магазину
/bw setupgrade - встановити NPC покращень
/bw enablearena <назва> - активувати арену
\`\`\`

**Гравцям:**
\`\`\`
/bw join <арена> - приєднатися до гри
/bw leave - вийти з гри
/bw stats - переглянути статистику
/bw top - топ гравців
\`\`\`

## Залежності

**Обов'язкові:**
- Vault (для економіки)
- Permissions плагін (LuckPerms)

**Рекомендовані:**
- Citizens (для NPC)
- PlaceholderAPI (для статистики)
- Multiverse-Core (для світів)
`,
      },
      {
        id: 'lesson-2-2',
        title: 'Створення BedWars арени',
        duration: '20 хв',
        type: 'text',
        content: `
# Створення BedWars арени

Покрокова інструкція створення арени.

## Крок 1: Підготовка світу

1. **Створіть новий світ:**
   \`\`\`
   /mv create bedwars_arena1 normal -g VoidGen
   \`\`\`

2. **Телепортуйтесь:**
   \`\`\`
   /mv tp bedwars_arena1
   \`\`\`

3. **Побудуйте арену** відповідно до плану

## Крок 2: Початок налаштування

\`\`\`
/bw setuparena arena1
\`\`\`

Система запитає наступні параметри:
- Мінімальна кількість гравців
- Максимальна кількість гравців
- Кількість команд
- Розмір команд

## Крок 3: Налаштування команд

**Для кожної команди:**

1. **Встановіть спавн:**
   \`\`\`
   Станьте на місці спавну команди
   /bw setspawn red
   \`\`\`

2. **Встановіть ліжко:**
   \`\`\`
   Поставте ліжко (2 блоки)
   /bw setbed red
   \`\`\`

3. **Магазин:**
   \`\`\`
   Станьте де буде NPC
   /bw setshop red
   \`\`\`

4. **Покращення:**
   \`\`\`
   /bw setupgrade red
   \`\`\`

5. **Генератори команди:**
   \`\`\`
   Станьте на місці генератора заліза
   /bw addgenerator red iron
   
   Станьте на місці генератора золота
   /bw addgenerator red gold
   \`\`\`

Повторіть для BLUE, GREEN, YELLOW команд.

## Крок 4: Центральні генератори

\`\`\`
Станьте на центральному острові
/bw addgenerator diamond
/bw addgenerator emerald
\`\`\`

## Крок 5: Зона чекання

\`\`\`
Створіть лобі для гравців
/bw setlobby arena1

Встановіть точку спавну в лобі
/bw setspawn
\`\`\`

## Крок 6: Завершення

1. **Встановіть межі арени:**
   \`\`\`
   /bw setpos1 (один кут)
   /bw setpos2 (протилежний кут)
   \`\`\`

2. **Активуйте арену:**
   \`\`\`
   /bw enablearena arena1
   \`\`\`

3. **Тестування:**
   \`\`\`
   /bw join arena1
   \`\`\`

## Поради

- **Симетрія** - усі команди мають бути однакові
- **Відстані** - зручні для мостів
- **Видимість** - гравці мають бачити інші острови
- **Захист спавну** - неможливо будувати дуже близько до ліжка
`,
        codeExamples: [
          {
            id: 'example-1',
            title: 'Приклад конфігурації арени',
            language: 'yaml',
            code: `# bedwars_arena1.yml
name: "Arena 1"
displayName: "&cBedWars &7Arena"
minPlayers: 4
maxPlayers: 16
world: bedwars_arena1
teams: 4
teamSize: 4

generators:
  iron:
    red: [50, 70, 50]
    blue: [-50, 70, 50]
    green: [50, 70, -50]
    yellow: [-50, 70, -50]
  
  gold:
    red: [52, 70, 52]
    blue: [-52, 70, 52]
    green: [52, 70, -52]
    yellow: [-52, 70, -52]
  
  diamond:
    center1: [0, 75, 10]
    center2: [0, 75, -10]
  
  emerald:
    center: [0, 78, 0]`,
            explanation: 'Конфігурація збережена після налаштування арени',
          },
        ],
      },
      {
        id: 'lesson-2-3',
        title: 'Налаштування магазину',
        duration: '15 хв',
        type: 'text',
        content: `
# Налаштування магазину BedWars

Налаштуємо предмети, ціни та категорії в магазині.

## Структура shop.yml

\`plugins/BedWars1058/shop.yml\`:

\`\`\`yaml
shop-categories:
  - name: "Blocks"
    icon: WOOL
    items:
      - material: WOOL
        price: 4
        currency: iron
        amount: 16
      
      - material: TERRACOTTA
        price: 12
        currency: iron
        amount: 16
      
      - material: GLASS
        price: 12
        currency: iron
        amount: 4
      
      - material: END_STONE
        price: 24
        currency: iron
        amount: 12
      
      - material: OBSIDIAN
        price: 4
        currency: emerald
        amount: 4
  
  - name: "Weapons"
    icon: DIAMOND_SWORD
    items:
      - material: STICK
        price: 10
        currency: iron
        amount: 1
        enchantments:
          - KNOCKBACK:1
      
      - material: IRON_SWORD
        price: 7
        currency: gold
        amount: 1
      
      - material: DIAMOND_SWORD
        price: 3
        currency: emerald
        amount: 1
  
  - name: "Armor"
    icon: CHAINMAIL_CHESTPLATE
    items:
      - material: CHAINMAIL_BOOTS
        price: 40
        currency: iron
        permanent: true
      
      - material: IRON_BOOTS
        price: 12
        currency: gold
        permanent: true
      
      - material: DIAMOND_BOOTS
        price: 6
        currency: emerald
        permanent: true
\`\`\`

## Категорії магазину

**1. Blocks (Блоки):**
- Wool - базовий блок
- Terracotta - міцніший
- Glass - прозорий
- End Stone - дуже міцний
- Obsidian - найміцніший

**2. Weapons (Зброя):**
- Stick (Knockback) - відштовхування
- Stone Sword - базова
- Iron Sword - середня
- Diamond Sword - найкраща

**3. Armor (Броня):**
- Permanent upgrades
- Chainmail → Iron → Diamond
- Зберігається після смерті

**4. Tools (Інструменти):**
- Pickaxe (швидше ламати блоки)
- Axe (для дерев'яних блоків)
- Shears (для вовни)

**5. Bows (Луки):**
- Regular Bow
- Power Bow
- Arrows

**6. Potions (Зілля):**
- Speed Potion
- Jump Boost
- Invisibility

**7. Special (Спеціальні):**
- TNT
- Fireball
- Tracker
- Bridge Egg

## Баланс цін

**Принципи:**
\`\`\`yaml
Iron (часто):
  - Wool: 4
  - Tools: 10-40
  - Weak weapons: 10

Gold (рідше):
  - Better armor: 12-30
  - Iron Sword: 7
  - Potions: 1-2

Diamond (рідко):
  - Diamond gear: 3-8
  - Strong weapons: 3
  - Special items: 4

Emerald (дуже рідко):
  - Premium items: 2-6
  - Obsidian: 4
  - Sharpness: 5
\`\`\`

## Тестування

1. Запустіть гру
2. Перевірте всі категорії
3. Тестуйте баланс предметів
4. Коригуйте ціни при потребі
`,
      },
    ],
  },
  {
    id: 'module-3',
    title: 'SkyWars та інші міні-ігри',
    description: 'Додаткові популярні режими',
    order: 3,
    lessons: [
      {
        id: 'lesson-3-1',
        title: 'Налаштування SkyWars',
        duration: '15 хв',
        type: 'text',
        content: `
# Налаштування SkyWars

SkyWars - проста у налаштуванні, але дуже популярна міні-гра.

## Встановлення SkyWarsReloaded

1. **Завантажте:**
   - https://www.spigotmc.org/resources/skywars.3796/
   - або SkyWarsX для альтернативи

2. **Встановіть:**
   \`\`\`
   1. Покладіть в plugins/
   2. Перезапустіть сервер
   3. Налаштуйте config
   \`\`\`

## Базова конфігурація

\`plugins/SkyWarsReloaded/config.yml\`:

\`\`\`yaml
# Налаштування гри
game:
  countdown: 10
  grace-period: 10
  max-time: 600
  
# Нагороди
rewards:
  win: 100
  kill: 10
  participation: 5

# Chest refill
chest-refill:
  enabled: true
  time: 180
  message: true
\`\`\`

## Створення SkyWars арени

1. **Почніть створення:**
   \`\`\`
   /sw createarena <назва> <кількість гравців>
   \`\`\`

2. **Встановіть спавни гравців:**
   \`\`\`
   Станьте на кожному острові
   /sw setspawn <номер>
   \`\`\`

3. **Встановіть спектаторів:**
   \`\`\`
   /sw setspectate
   \`\`\`

4. **Встановіть лобі:**
   \`\`\`
   /sw setlobby
   \`\`\`

5. **Зареєструйте сундуки:**
   \`\`\`
   ПКМ по кожному сундуку з паличкою
   Система автоматично їх запам'ятає
   \`\`\`

6. **Активуйте арену:**
   \`\`\`
   /sw enablearena <назва>
   \`\`\`

## Налаштування лута

\`chests.yml\`:

\`\`\`yaml
# Ймовірності та предмети
island-chest:
  tier: 1
  items:
    - item: STONE_SWORD
      chance: 30
    - item: LEATHER_CHESTPLATE
      chance: 25
    - item: APPLE
      amount: 3-5
      chance: 50

center-chest:
  tier: 2
  items:
    - item: IRON_SWORD
      chance: 40
    - item: DIAMOND_CHESTPLATE
      chance: 15
    - item: BOW
      chance: 35
    - item: ARROW
      amount: 10-20
      chance: 40

special-chest:
  tier: 3
  items:
    - item: DIAMOND_SWORD
      chance: 60
    - item: ENCHANTED_GOLDEN_APPLE
      chance: 20
    - item: ENDER_PEARL
      amount: 1-2
      chance: 30
\`\`\`

## Типи арен

**Solo (1v1v1...v1):**
- 8-12 гравців
- Індивідуальна гра
- Швидкі матчі

**Teams (2v2v2...v2):**
- 8-16 гравців (команди по 2)
- Командна робота
- Більше стратегії

**Mega (Великі):**
- 24+ гравців
- Великі острови
- Довші матчі
`,
        codeExamples: [
          {
            id: 'example-1',
            title: 'Приклад конфігурації SkyWars',
            language: 'yaml',
            code: `# Налаштування гри
game-settings:
  countdown-time: 10
  grace-period: 10
  chest-refill-time: 180
  max-game-time: 600
  
# Нагороди
rewards:
  win:
    money: 100
    xp: 50
  kill:
    money: 10
    xp: 5
  
# Можливості
projectiles:
  tracking-enabled: true
  
abilities:
  double-jump: true
  
spectator:
  allow-flight: true`,
            explanation: 'Збалансована конфігурація для SkyWars',
          },
        ],
      },
      {
        id: 'lesson-3-2',
        title: 'Система лобі та портів',
        duration: '12 хв',
        type: 'text',
        content: `
# Система лобі та портів

Створимо зручне лобі з порталами до міні-ігор.

## Варіант 1: Прості портали

**Використовуємо плагін AdvancedPortals:**

1. **Встановіть плагін**

2. **Створіть портал:**
   \`\`\`
   Виділіть область WorldEdit (//wand)
   /ap create bedwars
   \`\`\`

3. **Налаштуйте команду:**
   \`\`\`
   /ap command bedwars bw join arena1
   \`\`\`

## Варіант 2: NPC меню

**Використовуємо Citizens + DeluxeMenus:**

1. **Створіть NPC:**
   \`\`\`
   /npc create BedWars
   /npc skin Notch
   \`\`\`

2. **Налаштуйте клік:**
   \`\`\`
   /npc command add bw gui
   \`\`\`

3. **Створіть GUI меню:**
   \`deluxemenus/bedwars_menu.yml\`:
   \`\`\`yaml
   menu_title: 'BedWars Arenas'
   size: 27
   items:
     arena1:
       material: RED_BED
       slot: 11
       display_name: '&cArena 1'
       lore:
         - '&7Players: &a%bedwars_arena1_players%/16'
         - '&7Status: %bedwars_arena1_status%'
       left_click_commands:
         - 'bw join arena1'
   \`\`\`

## Варіант 3: Holograми

**Плагін DecentHolograms:**

\`\`\`
/hd create bedwars_info
/hd addline bedwars_info &c&lBedWars
/hd addline bedwars_info &7Гравців онлайн: &a%bedwars_online%
/hd addline bedwars_info &7Ігор активних: &e%bedwars_games%
/hd addline bedwars_info &aКлікни на портал!
\`\`\`

## Дизайн лобі

**Зони лобі:**

1. **Spawn Area** - старт
2. **Portal District** - портали до ігор
3. **Stats Area** - статистика
4. **Shop Area** - косметика
5. **Parkour** - розвага під час чекання

**Приклад розташування:**

\`\`\`
         [Stats Board]
              |
    [Parkour] - [Spawn] - [Shop]
              |
        [Portals Area]
     BW | SW | HG | KitPvP
\`\`\`

## Автоматичне балансування

Плагін для розподілу гравців:

\`\`\`yaml
# AutoBalancer config
auto-join:
  enabled: true
  prefer: "most-players"  # або "least-players"
  
signs:
  - location: world,100,65,100
    game: bedwars
  - location: world,110,65,100
    game: skywars
\`\`\`
`,
      },
      {
        id: 'lesson-3-3',
        title: 'Статистика та рейтинги',
        duration: '10 хв',
        type: 'quiz',
        content: '',
        quiz: {
          id: 'quiz-3-3',
          questions: [
            {
              id: 'q1',
              question: 'Який плагін використовується для створення NPC?',
              options: ['Citizens', 'NPCs', 'CustomNPC', 'Sentinel'],
              correctAnswer: 0,
              explanation: 'Citizens - найпопулярніший плагін для створення та управління NPC.',
            },
            {
              id: 'q2',
              question: 'Що таке "chest refill" у SkyWars?',
              options: [
                'Поповнення сундуків новими предметами під час гри',
                'Автоматичне відкриття сундуків',
                'Збільшення кількості сундуків',
                'Захист сундуків від гравців',
              ],
              correctAnswer: 0,
              explanation: 'Chest refill - це поповнення сундуків новими предметами через певний час гри для збільшення динамічності.',
            },
            {
              id: 'q3',
              question: 'Який тип арени найшвидший у SkyWars?',
              options: ['Mega', 'Teams', 'Solo', 'Custom'],
              correctAnswer: 2,
              explanation: 'Solo арени найшвидші, оскільки менше гравців і кожен грає сам за себе.',
            },
            {
              id: 'q4',
              question: 'Який ресурс найцінніший у BedWars?',
              options: ['Iron', 'Gold', 'Diamond', 'Emerald'],
              correctAnswer: 3,
              explanation: 'Emerald найрідкісніший і дозволяє купувати найпотужніші предмети.',
            },
          ],
        },
      },
    ],
  },
];
