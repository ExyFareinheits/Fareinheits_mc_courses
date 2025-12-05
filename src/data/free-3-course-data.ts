export const free3CourseData = {
  modules: [
    {
      id: 1,
      title: 'CoreProtect - захист від грифінгу',
      description: 'Логування всіх дій гравців, rollback, інтеграція з MySQL для великих серверів.',
      lessons: [
        {
          id: '1.1',
          title: 'Що таке CoreProtect і навіщо він потрібен',
          duration: 900,
          isFreePreview: true,
          content: `# CoreProtect - логування всіх дій

## Що таке CoreProtect?

CoreProtect - це плагін для логування всіх дій гравців на сервері.

## Що він записує:

- Поставлені та зламані блоки
- Відкриття контейнерів (сундуки, печі)
- Вбивство мобів
- Використання предметів
- Команди гравців
- Входи/виходи з сервера

## Навіщо це потрібно?

**Захист від грифінгу:**
- Дізнатися хто зламав ваш будинок
- Відкотити всі зміни за 1 команду
- Знайти грифера навіть якщо він вийшов

**Розслідування:**
- Хто вкрав з сундука?
- Хто вбив моба?
- Хто використав лаву?

**Статистика:**
- Скільки блоків поставив гравець
- Найактивніші гравці
- Популярні блоки

## Переваги CoreProtect

- Безкоштовний та open-source
- Мінімальний вплив на продуктивність
- Підтримка MySQL (для великих серверів)
- Веб-інтерфейс (з плагіном CoreProtectAPI)
- Сумісність з Paper/Spigot

## Основні команди

**/co inspect** - режим інспектора (клік по блоку = інфо)
**/co lookup** - пошук дій
**/co rollback** - відкат змін
**/co restore** - повернення змін

## Приклад використання

Гравець Ivan_Griffer зламав ваш будинок:

1. /co inspect (ввімкнути інспектор)
2. Клікнути по зламаному блоку
3. Побачити: "Ivan_Griffer зламав Stone 2 години тому"
4. /co rollback u:Ivan_Griffer t:3h r:50
5. Всі зміни відкочено!

У наступному уроці встановимо та налаштуємо CoreProtect.`
        },
        {
          id: '1.2',
          title: 'Встановлення та базова конфігурація',
          duration: 1200,
          isFreePreview: true,
          content: `# Встановлення CoreProtect

## Крок 1: Завантаження

Офіційне джерело: https://www.spigotmc.org/resources/coreprotect.8631/

Завантажте останню версію CoreProtect-XX.X.jar

## Крок 2: Встановлення

1. Зупинити сервер
2. Помістити CoreProtect-XX.X.jar в папку plugins/
3. Запустити сервер
4. Перевірити консоль: [CoreProtect] Enabling CoreProtect

## Крок 3: Базова конфігурація

Файл: plugins/CoreProtect/config.yml

\`\`\`yaml
# База даних (SQLite за замовчуванням)
use-mysql: false
table-prefix: co_

# Що логувати
block-place: true
block-break: true
natural-break: true
explosions: true
fire: true

# Логування контейнерів
chest-access: true

# Логування команд
commands: true

# Логування входів/виходів
player-sessions: true

# Скільки зберігати (дні)
max-days: 30

# Радіус пошуку (блоки)
max-radius: 100
\`\`\`

## Крок 4: Перша перевірка

1. Поставте блок
2. /co inspect
3. Клікніть по блоку
4. Має показати: "Ви поставили Stone"

## Оптимізація для великих серверів

Якщо сервер лагає через CoreProtect:

\`\`\`yaml
# Зменшити період збереження
max-days: 14

# Вимкнути непотрібне
natural-break: false
fire: false

# Збільшити інтервал збереження
save-interval: 300
\`\`\`

## Права доступу

\`\`\`
coreprotect.inspect - інспектор
coreprotect.lookup - пошук
coreprotect.rollback - відкат
coreprotect.restore - відновлення
\`\`\`

Модераторам дати: inspect, lookup
Адмінам дати: всі права

У наступному уроці розберемо команди детально.`
        },
        {
          id: '1.3',
          title: 'Команди rollback та restore - відкат змін',
          duration: 1500,
          isFreePreview: false,
          content: `# Команди відкату та відновлення

## Rollback - відкат змін

**Базовий синтаксис:**
/co rollback u:<гравець> t:<час> r:<радіус>

**Параметри:**

**u:** - гравець (username)
- u:Ivan - один гравець
- u:Ivan,Petro - кілька гравців
- u:#creeper - всі криперы

**t:** - час (time)
- t:1h - 1 година
- t:2d - 2 дні
- t:30m - 30 хвилин
- t:1w - 1 тиждень

**r:** - радіус (radius)
- r:10 - 10 блоків навколо вас
- r:50 - 50 блоків
- r:#global - весь світ
- r:#worldedit - ваша WorldEdit зона

**a:** - дія (action)
- a:block - тільки блоки
- a:+block - поставлені блоки
- a:-block - зламані блоки
- a:click - клік по контейнеру

## Приклади rollback

**Приклад 1: Відкатити все що зробив гравець за годину**
/co rollback u:Griefer t:1h r:#global

**Приклад 2: Відкатити вибух крипера**
/co rollback u:#creeper t:5m r:20

**Приклад 3: Відкатити тільки зламані блоки**
/co rollback u:Griefer a:-block t:2h r:30

**Приклад 4: Відкатити в WorldEdit зоні**
/co rollback u:Griefer t:1d r:#worldedit

## Restore - повернення змін

Якщо ви випадково відкотили зміни, можна повернути:

/co restore u:<гравець> t:<час> r:<радіус>

**Приклад:**
/co restore u:Griefer t:10m r:#global

## Lookup - перегляд перед відкатом

Перед rollback краще перевірити що буде відкочено:

/co lookup u:Griefer t:1h r:30

Покаже список всіх дій. Якщо все ок - робимо rollback.

## Інспектор (inspect)

/co inspect - увімкнути режим інспектора

Клік лівою кнопкою по блоку = історія
Клік правою кнопкою = гравці поруч

Вимкнути: /co inspect знову

## Важливо!

1. Завжди робіть backup перед великим rollback
2. Перевіряйте lookup перед rollback
3. Rollback можна відмінити через restore
4. Великі rollback (r:100+) можуть лагати сервер

У наступному модулі розберемо WorldGuard для захисту регіонів.`
        }
      ]
    },
    {
      id: 2,
      title: 'WorldGuard - захист регіонів',
      description: 'Створення захищених зон, налаштування флагів, інтеграція з системою прав.',
      lessons: [
        {
          id: '2.1',
          title: 'Створення регіонів за допомогою WorldEdit',
          duration: 1200,
          isFreePreview: false,
          content: `# WorldGuard + WorldEdit

## Що потрібно встановити

1. **WorldEdit** - для виділення зон
2. **WorldGuard** - для захисту регіонів

Завантажити:
- https://dev.bukkit.org/projects/worldedit
- https://dev.bukkit.org/projects/worldguard

## WorldEdit - базові команди

**//wand** - отримати дерев'яну сокиру (інструмент)

**Виділення зони:**
- Ліва кнопка миші = точка 1
- Права кнопка миші = точка 2

**//expand vert** - розширити до неба та бедроку

**//pos1** та **//pos2** - встановити точки де стоїш

## Створення регіону

**Крок 1: Виділити зону**
1. //wand
2. Клік ЛКМ по першому куту
3. Клік ПКМ по другому куту
4. //expand vert

**Крок 2: Створити регіон**
/region define назва_регіону

**Приклад:**
/region define spawn
/region define shop
/region define arena_pvp

## Базові команди регіонів

**/region list** - список всіх регіонів
**/region info назва** - інфо про регіон
**/region remove назва** - видалити регіон
**/region redefine назва** - змінити зону

## Додавання власників та учасників

**/region addowner назва гравець** - додати власника
**/region addmember назва гравець** - додати учасника

**Різниця:**
- Owner - може міняти регіон, додавати інших
- Member - просто має доступ

**Приклад:**
/region addowner myhouse Ivan
/region addmember myhouse Petro

## Пріоритети регіонів

Якщо регіони перетинаються, працює той що має вищий пріоритет.

/region setpriority назва число

**Приклад:**
/region setpriority spawn 100
/region setpriority shop 50

Spawn матиме вищий пріоритет.

У наступному уроці розберемо флаги регіонів.`
        },
        {
          id: '2.2',
          title: 'Налаштування флагів (PvP, build, damage)',
          duration: 1500,
          isFreePreview: false,
          content: `# Флаги WorldGuard

## Що таке флаги?

Флаги - це правила регіону. Вони контролюють що можна/не можна робити.

## Базовий синтаксис

/region flag <регіон> <флаг> <значення>

**Значення:**
- allow - дозволити
- deny - заборонити
- none - скинути (за замовчуванням)

## ТОП-10 найважливіших флагів

**1. pvp** - PvP бій
/region flag spawn pvp deny

**2. build** - будівництво
/region flag spawn build deny

**3. damage** - отримання урону
/region flag spawn damage deny

**4. mob-spawning** - спавн мобів
/region flag spawn mob-spawning deny

**5. creeper-explosion** - вибухи кріперів
/region flag spawn creeper-explosion deny

**6. use** - взаємодія (двері, кнопки)
/region flag spawn use allow

**7. chest-access** - доступ до сундуків
/region flag spawn chest-access deny

**8. entry** - вхід в регіон
/region flag private_base entry deny

**9. exit** - вихід з регіону
/region flag trap exit deny

**10. greeting** - повідомлення при вході
/region flag spawn greeting "Ласкаво просимо на спавн!"

## Приклади налаштування

**Спавн (безпечна зона):**
\`\`\`
/region flag spawn pvp deny
/region flag spawn damage deny
/region flag spawn mob-spawning deny
/region flag spawn build deny
/region flag spawn greeting "Ви на спавні!"
\`\`\`

**PvP Арена:**
\`\`\`
/region flag arena pvp allow
/region flag arena build deny
/region flag arena mob-spawning deny
/region flag arena greeting "Арена! Будьте обережні!"
\`\`\`

**Приватний дім:**
\`\`\`
/region flag myhouse build deny
/region flag myhouse chest-access deny
/region flag myhouse entry deny
/region addmember myhouse Ivan
\`\`\`

**Магазин:**
\`\`\`
/region flag shop build deny
/region flag shop pvp deny
/region flag shop use allow
/region flag shop greeting "Магазин! /shop"
\`\`\`

## Групові флаги

Можна встановити флаги для груп:

/region flag spawn build -g nonmembers deny

Тепер тільки member's можуть будувати.

## Глобальні флаги

Флаги для всього світу:

/rg flag __global__ pvp deny

Тепер PvP вимкнено скрізь (крім регіонів де allow).

У наступному уроці інтеграція з LuckPerms.`
        },
        {
          id: '2.3',
          title: 'Інтеграція з LuckPerms - права на регіони',
          duration: 1200,
          isFreePreview: false,
          content: `# WorldGuard + LuckPerms

## Як це працює разом?

WorldGuard може перевіряти права з LuckPerms для доступу до регіонів.

## Налаштування прав для флагів

**Базовий синтаксис:**
/region flag <регіон> <флаг> -g <група> <значення>

## Приклади

**Тільки VIP можуть будувати на спавні:**
\`\`\`
/region flag spawn build -g members deny
/region flag spawn build -g vip allow
\`\`\`

**Тільки модератори можуть ламати блоки в спавн-зоні:**
\`\`\`
/lp group moderator permission set worldguard.region.bypass.spawn.block-break
\`\`\`

## Права WorldGuard

**worldguard.region.bypass.<регіон>.<флаг>**

**Приклад:**
\`\`\`
# Адміни можуть будувати скрізь
/lp group admin permission set worldguard.region.bypass.*

# VIP ігнорують вхід в приватні регіони
/lp group vip permission set worldguard.region.bypass.*.entry
\`\`\`

## Створення VIP-зони

**Крок 1: Створити регіон**
/region define vip_area

**Крок 2: Заборонити вхід всім**
/region flag vip_area entry deny

**Крок 3: Дозволити VIP**
/region flag vip_area entry -g vip allow

**Крок 4: Додати повідомлення**
/region flag vip_area entry-deny-message "Ця зона тільки для VIP!"

## Магазинні прилавки

Гравці можуть орендувати прилавки:

**Створення прилавка:**
\`\`\`
/region define shop_1
/region addowner shop_1 Ivan
/region flag shop_1 build deny
/region flag shop_1 build -g owner allow
\`\`\`

Тепер Ivan може будувати тільки у своєму прилавку.

## Дозволи на команди регіонів

\`\`\`
# Базові команди
worldguard.region.info - /region info
worldguard.region.list - /region list

# Створення регіонів
worldguard.region.define - /region define
worldguard.region.redefine - /region redefine

# Управління
worldguard.region.addmember - /region addmember
worldguard.region.addowner - /region addowner
worldguard.region.flag - /region flag

# Видалення (тільки адмін!)
worldguard.region.remove - /region remove
\`\`\`

## Приклад налаштування групи

**Модератор:**
\`\`\`
/lp group moderator permission set worldguard.region.info
/lp group moderator permission set worldguard.region.list
/lp group moderator permission set worldguard.region.flag
/lp group moderator permission set worldguard.region.bypass.spawn.build
\`\`\`

**VIP:**
\`\`\`
/lp group vip permission set worldguard.region.info
/lp group vip permission set worldguard.region.list
/lp group vip permission set worldguard.region.bypass.*.entry
\`\`\`

Тепер ваш сервер повністю захищений!`
        }
      ]
    }
  ]
};
