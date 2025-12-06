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
          duration: 25,
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
          duration: 30,
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
          title: 'Команди rollback та restore',
          duration: 40,
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
    },
    {
      id: 3,
      title: 'Додаткові методи захисту',
      description: 'Захист від DDoS, блокування VPN, backup системи та моніторинг',
      lessons: [
        {
          id: '3.1',
          title: 'Захист від DDoS атак',
          duration: 35,
          isFreePreview: true,
          content: `# Захист від DDoS атак

## Що таке DDoS?

**DDoS (Distributed Denial of Service)** - атака на сервер з метою його перевантаження.

### Як це працює:

1. Атакуючий орендує ботнет (1000-10000 комп'ютерів)
2. Всі боти одночасно підключаються до сервера
3. Сервер не витримує навантаження
4. Гравці не можуть зайти

## Симптоми DDoS:

- Різке падіння TPS (20 → 5)
- Гравці кікаються
- Сервер не відповідає
- Консоль спамиться підключеннями

## Рівні захисту

### Рівень 1: Плагіни (базовий)

#### AntiVPN Pro

Блокує VPN/Proxy підключення:

\`\`\`yaml
# config.yml
block-vpn: true
api-key: 'your-key-from-iphub.info'
whitelist:
  - '123.45.67.89' # твій IP
\`\`\`

**Чому блокувати VPN?**
- 90% DDoS атак йдуть через VPN
- Читери ховаються за VPN
- Бани обходяться через VPN

#### AntiBot

Блокує ботів:

\`\`\`yaml
# settings.yml
max-connections-per-ip: 3
connection-speed-limit: 2 # 2 підключення за секунду
captcha-enabled: true
whitelist-after-verify: true
\`\`\`

**Як працює:**
1. Гравець заходить вперше
2. Отримує captcha в чаті
3. Повинен написати код
4. Після проходження - більше не перевіряється

### Рівень 2: Хостинг (середній)

Вибирай хостинг з DDoS захистом!

**Рекомендації:**

| Хостинг | DDoS захист | Ціна/міс |
|---------|-------------|----------|
| BisectHosting | ✅ Безкоштовно | від $8 |
| Sparked | ✅ Безкоштовно | від $5 |
| Apex Hosting | ✅ Безкоштовно | від $10 |
| Server.pro | ❌ Ні | від $3 |

**Що дає хостинг захист:**
- Фільтрація трафіку
- Автоблокування атак
- CDN розподіл навантаження

### Рівень 3: Проксі (професійний)

#### TCPShield (БЕЗКОШТОВНО!)

**Найкращий захист для Minecraft!**

Як працює:
1. Гравці підключаються до TCPShield
2. TCPShield фільтрує трафік
3. Чистий трафік йде на твій сервер

**Налаштування:**

\`\`\`
1. Реєстрація на tcpshield.com
2. Додай свій домен (mc.example.com)
3. Зміни A record на TCPShield IP
4. Встанови TCPShield плагін
5. Перезапусти сервер
\`\`\`

**server.properties:**
\`\`\`properties
network-compression-threshold=256
prevent-proxy-connections=false
\`\`\`

**Переваги:**
- Безкоштовно до 1000 гравців online
- Захист від 99% DDoS
- Не потрібен VDS
- Працює з будь-яким хостингом

#### Cloudflare Spectrum (платно)

Для великих серверів (500+ онлайн):

**Ціна:** від $20/міс
**Що дає:**
- Захист рівня Cloudflare
- Безлімітний трафік
- Геолокаційний розподіл
- 99.99% uptime

### Рівень 4: Власний VDS (максимальний)

Якщо маєш свій VDS/Dedicated:

#### iptables rules

\`\`\`bash
# Обмеження підключень з одного IP
iptables -A INPUT -p tcp --dport 25565 -m connlimit --connlimit-above 3 -j REJECT

# Захист від SYN flood
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# Блокування ping flood
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
\`\`\`

#### fail2ban

Автоматичне блокування IP після атак:

\`\`\`ini
# /etc/fail2ban/jail.local
[minecraft]
enabled = true
port = 25565
filter = minecraft
logpath = /home/minecraft/logs/latest.log
maxretry = 5
bantime = 3600
\`\`\`

## План дій при DDoS

### Якщо атака почалася:

**Крок 1:** Визнач тип атаки
\`\`\`bash
# Подивись підключення
netstat -an | grep 25565 | wc -l

# Якщо > 100 - це DDoS
\`\`\`

**Крок 2:** Тимчасова блокування
\`\`\`bash
# Закрий сервер
screen -X -S minecraft quit

# Зміни IP або порт
# server.properties -> server-port=25566
\`\`\`

**Крок 3:** Встанови захист
- TCPShield (найшвидший спосіб)
- AntiBot плагін
- Зміна домену

**Крок 4:** Whitelist режим
\`\`\`
white-list=true
# Додай тільки перевірених гравців
\`\`\`

## Профілактика

### 1. Не публікуй IP сервера

❌ "Наш IP: 123.45.67.89:25565"
✅ "Наш домен: play.myserver.net"

**Чому?**
- IP легко атакувати напряму
- Домен можна перенести на TCPShield
- Можна швидко змінити IP

### 2. Обмеж slot'и

\`\`\`properties
max-players=100
# Навіть якщо хостинг дозволяє 500
\`\`\`

Залиш резерв для захисту.

### 3. Моніторинг

Встанови **Spark** для моніторингу:

\`\`\`
/spark tps - перевір TPS
/spark healthreport - звіт про здоров'я сервера
\`\`\`

Якщо TPS падає - можлива атака!

### 4. Backup план

Завжди май:
- Запасний хостинг
- Backup IP адресу
- Альтернативний домен

## Реальні кейси

### Кейс 1: Малий сервер (20-50 онлайн)

**Проблема:** Конкурент DDoS'ить щодня

**Рішення:**
1. Встановив TCPShield (безкоштовно)
2. AntiBot плагін
3. Змінив домен

**Результат:** Атаки зупинились, TPS стабільний

### Кейс 2: Середній сервер (100-200 онлайн)

**Проблема:** DDoS на 10 Gbps

**Рішення:**
1. Переїхав на BisectHosting (вбудований захист)
2. TCPShield для домену
3. fail2ban на VDS

**Результат:** Витримав атаку, гравці не помітили

### Кейс 3: Великий сервер (500+ онлайн)

**Проблема:** Цільова атака на 50 Gbps

**Рішення:**
1. Cloudflare Spectrum ($40/міс)
2. Dedicated сервер з 1 Gbps
3. Професійна команда моніторингу

**Результат:** Атака поглинута, 0% downtime

## Чек-лист захисту

- [ ] TCPShield або Cloudflare
- [ ] AntiVPN плагін
- [ ] AntiBot плагін
- [ ] Домен замість IP
- [ ] Хостинг з DDoS захистом
- [ ] Моніторинг (Spark)
- [ ] Backup план
- [ ] fail2ban (якщо VDS)

## Висновок

**Мінімальний захист (безкоштовно):**
1. TCPShield
2. AntiBot
3. AntiVPN

**Це покриє 95% атак!**

**Для великих серверів:**
- Cloudflare Spectrum
- Dedicated з захистом
- Професійний моніторинг

Пам'ятай: **краще встановити захист до атаки**, ніж гасити пожежу потім!`
        },
        {
          id: '3.2',
          title: 'Backup системи та відновлення',
          duration: 30,
          isFreePreview: true,
          content: `# Backup системи та відновлення

## Чому backup критично важливий?

**Без backup = ризик втратити все!**

### Реальні випадки втрати даних:

1. **Грифер з OP правами**
   - Видалив всі світи за 5 хвилин
   - Не було backup
   - Сервер закрився

2. **Crash БД**
   - MySQL crashed
   - Всі баланси, дані скинулись
   - Гравці покинули сервер

3. **Помилка хостера**
   - Хостинг видалив файли
   - Не було backup у гравця
   - Проект втрачено

**Backup = страховка!**

## Види backup'ів

### 1. World Backup (світ)

Найважливіше - світ з постройками гравців!

**Що включає:**
- world/
- world_nether/
- world_the_end/
- Розмір: 500 MB - 50 GB

**Частота:** Щодня

### 2. Plugins Backup (плагіни)

Конфіги та дані плагінів:

**Що включає:**
- plugins/
- Всі .yml файли
- Дані економіки, варпів, домів
- Розмір: 10-500 MB

**Частота:** Після кожної зміни конфігу

### 3. Database Backup (база даних)

MySQL/MariaDB дані:

**Що включає:**
- Користувачі
- Баланси
- Історія CoreProtect
- Статистика
- Розмір: 50 MB - 10 GB

**Частота:** Кожні 6 годин

### 4. Full Backup (повний)

Весь сервер цілком:

**Що включає:**
- Все вище + logs, cache
- Розмір: весь сервер
- Частота: Щотижня

## Автоматичні backup'и

### Метод 1: Плагін (найпростіший)

#### DriveBackupV2

**Функції:**
- Автоматичні backup'и
- Завантаження в Google Drive
- Scheduled backup'и
- Compression

**Установка:**

\`\`\`bash
1. Завантаж DriveBackupV2.jar
2. /plugins
3. /drivebackup link - зв'яжи з Google Drive
\`\`\`

**Конфіг:**

\`\`\`yaml
# config.yml
backups:
  world:
    enabled: true
    schedule: '0 */6 * * *' # Кожні 6 годин
    destination: 'google-drive'
    keep-count: 10 # Зберігати 10 останніх
    
  plugins:
    enabled: true
    schedule: '0 0 * * *' # Щодня о 00:00
    
  mysql:
    enabled: true
    schedule: '0 */3 * * *' # Кожні 3 години
    host: 'localhost'
    port: 3306
    database: 'minecraft'
\`\`\`

**Переваги:**
- Не потрібен доступ до хостингу
- GUI в грі
- Автоматично в хмару

**Мінуси:**
- Додаткове навантаження на сервер під час backup

### Метод 2: Server Script (професійний)

Якщо маєш доступ до VDS/Dedicated:

#### Bash скрипт:

\`\`\`bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y-%m-%d_%H-%M)
BACKUP_DIR="/home/backups"
SERVER_DIR="/home/minecraft"

# Створи директорію
mkdir -p $BACKUP_DIR

# Попередж гравців
screen -S minecraft -p 0 -X stuff "say §eBackup почався!§r
"

# Вимкни auto-save
screen -S minecraft -p 0 -X stuff "save-off
"
screen -S minecraft -p 0 -X stuff "save-all flush
"

# Почекай 10 секунд
sleep 10

# Створи archive
tar -czf $BACKUP_DIR/backup_$DATE.tar.gz \
  -C $SERVER_DIR \
  world world_nether world_the_end plugins

# Увімкни auto-save
screen -S minecraft -p 0 -X stuff "save-on
"

# Повідом гравців
screen -S minecraft -p 0 -X stuff "say §aBackup завершено!§r
"

# Видали старі backup'и (старші 7 днів)
find $BACKUP_DIR -name "backup_*.tar.gz" -mtime +7 -delete

# Завантаж у cloud (опціонально)
rclone copy $BACKUP_DIR remote:minecraft-backups
\`\`\`

**Автоматизація через cron:**

\`\`\`bash
# Відкрий crontab
crontab -e

# Додай рядок (кожні 6 годин)
0 */6 * * * /home/minecraft/backup.sh

# Або щодня о 3 ночі
0 3 * * * /home/minecraft/backup.sh
\`\`\`

#### Переваги скрипта:
- Не навантажує сервер (може працювати офлайн)
- Гнучкість налаштувань
- Інтеграція з rclone (cloud storage)

### Метод 3: Хостинг backup'и

Багато хостингів мають вбудовані:

**BisectHosting:**
- Автоматичні щоденні backup'и
- 1-click restore
- Зберігається 7 днів

**Apex Hosting:**
- Backup кожні 24 години
- Місце для 5 backup'ів
- FTP доступ до backup'ів

**Sparked:**
- Manual backup кнопка
- Автоматичні раз на тиждень

**Переваги:**
- Не треба нічого налаштовувати
- Швидке відновлення

**Мінуси:**
- Обмежена кількість backup'ів
- Немає контролю

## MySQL/MariaDB backup

### Automated mysqldump:

\`\`\`bash
#!/bin/bash
# mysql-backup.sh

DB_USER="minecraft"
DB_PASS="password123"
DB_NAME="minecraftdb"
BACKUP_DIR="/home/backups/mysql"
DATE=$(date +%Y-%m-%d_%H-%M)

mkdir -p $BACKUP_DIR

# Dump database
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME \
  | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Видали старі (більше 14 днів)
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +14 -delete
\`\`\`

**Cron:**
\`\`\`bash
0 */3 * * * /home/minecraft/mysql-backup.sh
\`\`\`

## Cloud storage інтеграція

### Google Drive (DriveBackupV2)

Найпростіше для початківців:
- Безкоштовно 15 GB
- Автоматична sync
- Доступ з будь-якого пристрою

### rclone (для VDS)

Підтримує всі хмари:

\`\`\`bash
# Налаштування
rclone config

# Вибери provider:
# - Google Drive
# - Dropbox
# - Amazon S3
# - Microsoft OneDrive

# Копіювання backup'ів
rclone copy /home/backups remote:minecraft-backups
\`\`\`

### Amazon S3 (для великих серверів)

**Переваги:**
- Безлімітне місце
- Дешево ($0.023/GB/міс)
- Професійна надійність

**S3 sync скрипт:**
\`\`\`bash
aws s3 sync /home/backups s3://my-minecraft-backups \
  --storage-class GLACIER \
  --exclude "*.log"
\`\`\`

## Відновлення з backup'у

### Ситуація 1: Грифінг світу

**Проблема:** Гравець зруйнував spawn

**Рішення:**
1. CoreProtect rollback (якщо недавно)
2. Або повний restore світу

**Restore:**
\`\`\`bash
# Зупини сервер
screen -S minecraft -X quit

# Видали поточний світ
rm -rf /home/minecraft/world

# Розпакуй backup
tar -xzf /home/backups/backup_2024-12-05.tar.gz -C /home/minecraft

# Запусти сервер
screen -S minecraft -d -m java -jar server.jar
\`\`\`

### Ситуація 2: Corrupted database

**Проблема:** MySQL crashed, дані пошкоджені

**Restore:**
\`\`\`bash
# Відновлення з dump'у
gunzip < /home/backups/mysql/db_2024-12-05.sql.gz \
  | mysql -u minecraft -p minecraftdb
\`\`\`

### Ситуація 3: Видалений плагін конфіг

**Проблема:** Випадково видалив EssentialsX конфіг

**Restore:**
\`\`\`bash
# Розпакуй тільки plugins папку
tar -xzf backup_2024-12-05.tar.gz \
  -C /home/minecraft \
  plugins/Essentials/config.yml
\`\`\`

## Тестування backup'ів

**Важливо:** Backup без тесту = можливо не працює!

### Щомісячний тест:

1. Створи тестовий сервер
2. Restore з останнього backup'у
3. Запусти сервер
4. Перевір:
   - Чи є світ
   - Чи працюють плагіни
   - Чи є дані гравців

**Якщо щось не так - виправ backup систему!**

## Backup стратегія

### Правило 3-2-1:

- **3** копії даних (original + 2 backup'и)
- **2** різні носії (HDD + Cloud)
- **1** offsite копія (в іншому місці)

### Приклад для серера:

1. **Original** - на хостингу
2. **Backup 1** - локально на VDS
3. **Backup 2** - Google Drive/S3

## Чек-лист backup системи

- [ ] Автоматичні backup'и налаштовані
- [ ] World backup - щодня
- [ ] MySQL backup - кожні 6 год
- [ ] Plugins backup - після змін
- [ ] Cloud storage підключений
- [ ] Тестував restore хоча б раз
- [ ] Старі backup'и видаляються auto
- [ ] Є offsite копія

## Висновок

**Мінімальна система (безкоштовно):**
- DriveBackupV2 плагін
- Google Drive 15 GB
- Backup щодня

**Професійна система:**
- Bash скрипти через cron
- rclone → S3/Drive
- Тестування щомісяця

**Пам'ятай: backup != backup поки ти не протестував restore!**`
        },
        {
          id: '3.3',
          title: 'Моніторинг та логування подій',
          duration: 25,
          isFreePreview: true,
          content: `# Моніторинг та логування подій

## Чому моніторинг важливий?

**Не можна керувати тим, що не вимірюєш!**

Без моніторингу ти не знаєш:
- Скільки TPS на сервері
- Які плагіни лагають
- Коли був останній crash
- Які помилки в консолі

## Рівень 1: Базовий моніторинг

### Spark - must-have!

**Найкращий профайлер для Minecraft!**

\`\`\`bash
# Встановлення
Завантаж Spark.jar → /plugins → restart
\`\`\`

**Базові команди:**

\`\`\`
/spark tps - TPS зараз
/spark ping - ping гравців
/spark health - здоров'я сервера
/spark profiler - запустити профайлінг
\`\`\`

**Профайлінг (дуже важливо!):**

\`\`\`
# Запусти профайлінг на 2 хвилини
/spark profiler --timeout 120

# Отримаєш посилання типу:
https://spark.lucko.me/abc123

# Побачиш:
- Які плагіни лагають
- Які chunk'и проблемні
- Які entities забагато
\`\`\`

**Що показує:**
- CPU usage по плагінах
- Memory usage
- Tick time breakdown
- Problem entities/chunks

### Plan - статистика сервера

**Веб-панель з аналітикою!**

\`\`\`
Встанови Plan.jar
Відкрий http://your-server-ip:8804
\`\`\```

**Що побачиш:**
- Графіки онлайну
- Час гри гравців
- Найактивніші гравці
- TPS історія
- Join/Leave логи

**Корисно для:**
- Розуміння пікових годин
- Виявлення ботів
- Статистика утримання гравців

## Рівень 2: Логування подій

### Log formats

**Базові логи:**
\`\`\`
logs/latest.log - поточні логи
logs/2024-12-05-1.log.gz - архів
\`\`\`

**Що логується:**
- Приєднання/від'єднання гравців
- Команди виконані
- Помилки плагінів
- Server warnings

### Logblock/CoreProtect - advanced logging

**CoreProtect логує:**
- Кожен блок поставлений/зламаний
- Відкриття контейнерів
- Взаємодії з блоками
- Вбивство мобів

**Зберігання:**
- SQLite (малі сервери)
- MySQL (великі сервери)

**Розмір:**
- 1000 гравців = ~50 MB/день
- Після місяця = ~1.5 GB

**Очищення старих логів:**
\`\`\`
/co purge t:30d - видалити логи старші 30 днів
\`\`\`

### DiscordSRV - логи в Discord

Отримуй події в Discord:

\`\`\`yaml
# config.yml
channels:
  console: '123456789' # Console channel ID
  
console:
  levels:
    - error
    - warn
  
discord-to-minecraft:
    enabled: true
\`\`\`

**Що надсилається:**
- Server start/stop
- Player join/leave
- Помилки в консолі
- Команди адмінів

## Рівень 3: Metrics та аналітика

### bStats

**Анонімна статистика використання:**

Автоматично збирається:
- Кількість серверів з плагіном
- Версія Minecraft
- Кількість гравців

**Приклад:** 
bStats показує що 50% серверів використовують Paper 1.20.1

### Prometheus + Grafana (advanced)

Для великих серверів (500+ онлайн):

**Stack:**
1. **Prometheus** - збір метрик
2. **Grafana** - візуалізація
3. **minecraft-prometheus-exporter** - плагін

**Що дає:**
- Real-time graphs TPS
- Memory usage timeline
- Player count history
- Alert при падінні TPS

**Налаштування:**
\`\`\`yaml
# prometheus.yml
scrape_configs:
  - job_name: 'minecraft'
    static_configs:
      - targets: ['localhost:9225']
\`\`\`

## Моніторинг важливих метрик

### 1. TPS (Ticks Per Second)

**Норма:** 20 TPS
**Проблема:** < 19 TPS

**Як перевірити:**
\`\`\`
/spark tps
/tps (якщо є Essentials)
\`\`\`

**Якщо TPS низький:**
1. `/spark profiler` - знайди проблемний плагін
2. Видали проблемні chunk'и
3. Зменш entities (мобів/предметів)

### 2. Memory (RAM)

**Як перевірити:**
\`\`\```
/spark heapsummary
\`\`\`

**Проблема:**
- Якщо використано > 90% RAM
- Часті garbage collection паузи

**Рішення:**
- Збільш RAM
- Оптимізуй GC flags
- Видали непотрібні світи

### 3. CPU Usage

**Норма:** 20-50%
**Проблема:** постійно > 80%

**Перевірка:**
\`\`\`bash
top # на Linux
htop # краща версія
\`\`\`

**Рішення:**
- Оптимізуй chunk loading
- Видали лагучі плагіни
- Upgrade CPU

### 4. Disk I/O

**Проблема:**
- Повільне збереження світу
- Лаги при chunk loading

**Рішення:**
- Використовуй SSD (не HDD!)
- Зменш autosave frequency
- Backup на інший диск

## Алерти та сповіщення

### Discord webhooks

Отримуй алерт коли:
- Server crashed
- TPS < 15
- Memory > 90%
- Player join/leave

**Скрипт:**
\`\`\`bash
#!/bin/bash
# check-tps.sh

TPS=$(/path/to/spark tps | grep -oP '\d+\.\d+')

if (( $(echo "$TPS < 15" | bc -l) )); then
  curl -H "Content-Type: application/json" \
    -d "{\"content\":\"⚠️ TPS низький: $TPS\"}" \
    https://discord.com/api/webhooks/YOUR_WEBHOOK
fi
\`\`\`

**Cron:**
\`\`\`bash
*/5 * * * * /home/minecraft/check-tps.sh
\`\`\`

### Email notifications

Для критичних подій:

\`\`\`bash
#!/bin/bash
# На crash сервера

if ! screen -list | grep -q "minecraft"; then
  echo "Server crashed!" | mail -s "Minecraft Down" admin@example.com
fi
\`\`\`

## Best practices

### 1. Щоденний чек

Кожен ранок перевіряй:
- `/spark health` - загальне здоров'я
- `logs/latest.log` - помилки
- Plan dashboard - статистика

### 2. Щотижневий огляд

Кожної неділі:
- `/spark profiler` на 5 хвилин
- Аналіз найактивніших гравців
- Перевірка disk space

### 3. Щомісячний аудит

- Видали старі CoreProtect логи
- Оптимізуй базу даних
- Backup performance testing

## Troubleshooting guide

### Проблема: TPS падає вночі

**Діагностика:**
\`\`\`
/spark profiler --timeout 600
# Запусти о 3 ночі
\`\`\`

**Можливі причини:**
- Backup скрипт працює
- Autosave всіх світів
- Cron jobs хостингу

**Рішення:**
- Перенеси backup на інший час
- Збільш autosave interval

### Проблема: Сервер crashing без причини

**Діагностика:**
\`\`\`bash
# Подивись crash logs
cat logs/latest.log | grep -i "error"
cat hs_err_pid*.log
\`\`\`

**Типові причини:**
- OutOfMemoryError → збільш RAM
- Plugin conflict → видали новий плагін
- Corrupted chunk → regenerate chunk

## Чек-лист моніторингу

- [ ] Spark встановлений
- [ ] Plan dashboard активний
- [ ] CoreProtect логує дії
- [ ] DiscordSRV для алертів
- [ ] Щоденний health check
- [ ] Backup логів у cloud
- [ ] Автоматичні алерти при проблемах

## Висновок

**Мінімальний набір:**
1. Spark - профайлінг
2. Plan - статистика
3. CoreProtect - логи дій

**Для великих серверів:**
- Prometheus + Grafana
- Automated alerting
- Log aggregation (ELK stack)

**Пам'ятай:** Моніторинг допомагає знайти проблему ДО того як гравці помітять!`
        }
      ]
    }
  ]
};
