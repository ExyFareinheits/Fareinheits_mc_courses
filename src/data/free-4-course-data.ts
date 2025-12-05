export const free4CourseData = {
  modules: [
    {
      id: 1,
      title: 'Налаштування економіки',
      description: 'EssentialsX Economy, ChestShop, Jobs Reborn - створення ігрової економіки.',
      lessons: [
        {
          id: '1.1',
          title: 'EssentialsX Economy - базова економіка',
          duration: 900,
          isFreePreview: true,
          content: `# Економіка на сервері

## Що таке економіка?

Економіка - це система грошей на сервері. Гравці можуть:
- Заробляти гроші
- Купувати/продавати предмети
- Створювати магазини
- Платити за послуги

## EssentialsX Economy

EssentialsX має вбудовану систему економіки.

**Основні команди:**

**/balance** (або /bal) - переглянути баланс
**/pay <гравець> <сума>** - передати гроші
**/balancetop** (або /baltop) - топ багатіїв

## Налаштування economy

Файл: plugins/Essentials/config.yml

\`\`\`yaml
# Стартовий баланс
starting-balance: 1000

# Максимальний баланс
max-money: 10000000

# Формат валюти
currency-symbol: '$'

# Мінімальна сума для передачі
minimum-pay-amount: 1
\`\`\`

## Адмін команди

**/eco give <гравець> <сума>** - дати гроші
**/eco take <гравець> <сума>** - забрати гроші
**/eco set <гравець> <сума>** - встановити баланс
**/eco reset <гравець>** - скинути баланс

## Приклад: Винагорода за вхід

Дати кожному гравцю 100$ при вході:

1. Встановити плагін "LoginRewards"
2. Налаштувати:
\`\`\`yaml
rewards:
  money: 100
  message: "Ви отримали 100$ за вхід!"
\`\`\`

## Важливо!

Не давайте занадто багато грошей на старті:
- 100-500$ - оптимально
- 10,000$+ - інфляція, гравці нічого не цінують

У наступному уроці створимо магазини!`
        },
        {
          id: '1.2',
          title: 'ChestShop - магазини гравців',
          duration: 1200,
          isFreePreview: true,
          content: `# ChestShop - створення магазинів

## Що таке ChestShop?

Плагін для створення магазинів за допомогою сундуків та табличок.

**Завантажити:** https://www.spigotmc.org/resources/chestshop.50951/

## Як створити магазин?

**Крок 1: Поставити сундук**
**Крок 2: Поставити табличку на сундук**
**Крок 3: Написати:**

\`\`\`
Рядок 1: (порожньо - автоматично ваш нік)
Рядок 2: кількість предметів
Рядок 3: ціна продажу : ціна купівлі
Рядок 4: назва предмета
\`\`\`

## Приклад магазину

**Продаж діамантів:**
\`\`\`
Ivan
1
100:90
DIAMOND
\`\`\`

- Продає 1 діамант за 100$
- Купує 1 діамант за 90$

**Тільки продаж:**
\`\`\`
Ivan
64
500:B
STONE
\`\`\`

- Продає 64 каменю за 500$
- Не купує (B = buy only)

**Тільки купівля:**
\`\`\`
Ivan
32
S:200
IRON_INGOT
\`\`\`

- Не продає (S = sell only)
- Купує 32 залізних злитків за 200$

## Як користуватись?

**Купити:** Клік ЛКМ по табличці
**Продати:** Клік ПКМ по табличці

## Налаштування ChestShop

Файл: plugins/ChestShop/config.yml

\`\`\`yaml
# Комісія магазину (0.05 = 5%)
TAX_AMOUNT: 0.00

# Чи можна створювати магазини для інших
ALLOW_MULTIPLE_SHOPS: true

# Захист регіонів
WORLDGUARD_INTEGRATION: true

# Логування транзакцій
LOG_TO_DATABASE: true
\`\`\`

## Права доступу

\`\`\`
chestshop.shop.create - створення магазинів
chestshop.shop.buy - купівля
chestshop.shop.sell - продаж
\`\`\`

## Приклад торгового центру

1. Створити WorldGuard регіон "mall"
2. /region flag mall build deny
3. Дати гравцям plot'и (ділянки)
4. Кожен може створити магазин у своїй ділянці

У наступному уроці - Jobs Reborn для заробітку!`
        },
        {
          id: '1.3',
          title: 'Jobs Reborn - професії та заробіток',
          duration: 1500,
          isFreePreview: false,
          content: `# Jobs Reborn - система професій

## Що таке Jobs Reborn?

Плагін що дає гравцям можливість обирати професії та заробляти гроші виконуючи дії.

**Завантажити:** https://www.spigotmc.org/resources/jobs-reborn.4216/

## Основні професії

**Miner (Шахтар):**
- Заробіток за копання руди
- Камінь: 1$
- Вугілля: 2$
- Залізо: 5$
- Діамант: 50$

**Woodcutter (Лісоруб):**
- Заробіток за рубку дерев
- Дуб: 1$
- Береза: 1.5$
- Jungle: 2$

**Builder (Будівельник):**
- Заробіток за розміщення блоків
- Каменю: 0.5$
- Цегли: 1$

**Hunter (Мисливець):**
- Заробіток за вбивство мобів
- Зомбі: 5$
- Скелет: 7$
- Крипер: 10$
- Ендермен: 20$

**Farmer (Фермер):**
- Заробіток за збір урожаю
- Пшениця: 1$
- Морква: 1.5$
- Картопля: 1.5$

## Команди гравців

**/jobs browse** - список професій
**/jobs join <професія>** - приєднатись до професії
**/jobs leave <професія>** - покинути професію
**/jobs info <професія>** - інфо про професію
**/jobs stats** - ваша статистика

## Система рівнів

Кожна професія має рівні (1-100):
- Вищий рівень = більше грошей
- Досвід за виконання дій
- Бонуси на високих рівнях

**Приклад:**
\`\`\`
Miner Level 1: Діамант = 50$
Miner Level 50: Діамант = 100$
Miner Level 100: Діамант = 200$
\`\`\`

## Налаштування професій

Файл: plugins/Jobs/jobConfig.yml

\`\`\`yaml
Jobs:
  Miner:
    fullname: 'Шахтар'
    shortname: 'М'
    description: 'Копайте руду та заробляйте!'
    max-level: 100
    slots: 2
    
    Break:
      STONE:
        income: 1.0
        experience: 1.0
      DIAMOND_ORE:
        income: 50.0
        experience: 20.0
\`\`\`

## Ліміти професій

Скільки професій може мати гравець?

\`\`\`yaml
# Максимум професій
max-jobs: 3

# Для VIP
vip-max-jobs: 5
\`\`\`

## Бонуси для VIP

\`\`\`yaml
boosters:
  vip:
    money: 1.5  # 50% більше грошей
    exp: 2.0    # 100% більше досвіду
\`\`\`

## Quest система

Jobs має квести (завдання):

**/jobs quests** - список квестів

**Приклад квесту:**
"Видобути 100 діамантів" - винагорода 5000$

Тепер економіка працює! Наступний модуль - монетизація.`
        }
      ]
    },
    {
      id: 2,
      title: 'Монетизація сервера',
      description: 'Mojang EULA, Tebex, donation ranks - як заробляти на сервері легально.',
      lessons: [
        {
          id: '2.1',
          title: 'Mojang EULA - що можна продавати',
          duration: 1200,
          isFreePreview: false,
          content: `# Mojang EULA - правила монетизації

## Що таке EULA?

EULA (End User License Agreement) - це правила Mojang щодо монетизації серверів.

**Офіційний документ:** https://account.mojang.com/documents/minecraft_eula

## Що МОЖНА продавати?

**1. Косметика:**
- Префікси та суфікси в чаті
- Кольорові ніки
- Партикли
- Пети (косметичні)
- Ембарки (пріколи)

**2. Доступ до зон:**
- VIP зона на спавні
- Додаткові варпи
- Приватні арени

**3. Сервера:**
- Доступ до окремих серверів (наприклад Creative)
- Пріоритет у черзі

**4. Косметичний вміст:**
- Скіни для предметів (CustomModelData)
- Косметична броня
- Емоджі в чаті

## Що ЗАБОРОНЕНО продавати?

**1. Pay-to-win:**
- Діаманти, руду
- Зброю/броню з кращими характеристиками
- Імбові перки (/fly в survival)
- Більший урон/захист

**2. Ігрові переваги:**
- Більше HP
- Швидше пересування (якщо не косметика)
- Безсмертя
- Креатив на survival

**3. Валюта за реальні гроші:**
- Не можна продавати ігрову валюту напряму
- Тільки donation валюту (окрему)

## Сіра зона

**Що спірно:**
- /fly в survival - ЗАБОРОНЕНО
- /fly в creative/spawn - ДОЗВОЛЕНО
- Більше home'ів (3→10) - ДОЗВОЛЕНО
- Більше claim'ів - ДОЗВОЛЕНО

## Як правильно монетизувати?

**Donation Ranks (ранги):**

**VIP (5$/міс):**
- Префікс [VIP] зеленого кольору
- Доступ до /hat
- 10 home замість 3
- Партикли
- VIP зона на спавні

**MVP (10$/міс):**
- Префікс [MVP] золотого кольору
- Все з VIP +
- 20 home
- Пет (косметичний)
- Кольоровий нік

**LEGEND (20$/міс):**
- Префікс [LEGEND] червоного кольору
- Все з MVP +
- 50 home
- Доступ до /nick
- Ембарки в чаті

## Важливо!

Mojang може забанити ваш сервер якщо порушуєте EULA.

**Ознаки порушення:**
- Продаж діамантів
- "Premium броня +20% захисту"
- Креатив за гроші

**Легальні приклади:**
- "VIPPrefix + партикли"
- "Доступ до VIP зони"
- "Пріоритет у черзі"

У наступному уроці налаштуємо Tebex!`
        },
        {
          id: '2.2',
          title: 'Tebex (Buycraft) - приймання донатів',
          duration: 1500,
          isFreePreview: false,
          content: `# Tebex - система донатів

## Що таке Tebex?

Tebex (колишній Buycraft) - найпопулярніша платформа для приймання донатів на Minecraft серверах.

**Офіційний сайт:** https://www.tebex.io/

## Переваги Tebex

- Приймає всі способи оплати (карти, PayPal, криптовалюта)
- Автоматична видача донат-пакетів
- Підтримка підписок
- Захист від chargeback
- Мобільний додаток
- Статистика продажів

## Реєстрація

1. Йдемо на https://tebex.io/
2. Sign Up
3. Вказати назву сервера
4. Підтвердити email

## Встановлення плагіна

1. Завантажити Tebex плагін з https://www.spigotmc.org/resources/tebex.1475/
2. Помістити в plugins/
3. Перезапустити сервер
4. /tebex secret <ваш_ключ>

**Ключ знайти:** Tebex Dashboard → Settings → Secret Key

## Створення донат-пакету

**Крок 1: Dashboard → Packages → Create Package**

**Крок 2: Налаштування:**
\`\`\`
Name: VIP Rank
Description: VIP префікс + партикли + 10 homes
Price: 5.00 USD
\`\`\`

**Крок 3: Команди (виконаються після покупки):**
\`\`\`
lp user {username} parent add vip
give {username} diamond 5
broadcast {username} купив VIP!
\`\`\`

**Змінні:**
- {username} - нік гравця
- {uuid} - UUID гравця
- {price} - ціна пакету

## Типи пакетів

**1. One-Time (разова покупка):**
Гравець купує 1 раз, отримує назавжди.

**2. Subscription (підписка):**
Щомісячна оплата, при закінченні - ранг забирається.

**3. Expiry (з терміном дії):**
Діє 30 днів, потім автоматично закінчується.

## Приклад підписки

**VIP Subscription (5$/міс):**

**При покупці:**
\`\`\`
lp user {username} parent add vip
lp user {username} permission set essentials.hat
\`\`\`

**При закінченні:**
\`\`\`
lp user {username} parent remove vip
lp user {username} permission unset essentials.hat
\`\`\`

## Створення донат-магазину

**1. Customize Webstore:**
- Вибрати шаблон (Minecraft, Modern, Dark)
- Додати логотип сервера
- Налаштувати кольори

**2. Додати категорії:**
- Ranks (VIP, MVP, LEGEND)
- Crates (Keys для кейсів)
- Boosters (XP boost, Money boost)

**3. Опис пакетів:**
Детально описати що входить у пакет.

## Комісія Tebex

**Free Plan:**
- 5% комісія з кожної транзакції
- Базовий функціонал

**Premium ($10/міс):**
- 3% комісія
- Розширена статистика
- Купони та знижки

**Enterprise ($50/міс):**
- 2% комісія
- API доступ
- Пріоритетна підтримка

## Безпека

**Chargeback захист:**
Якщо гравець робить chargeback (повертає гроші через банк), Tebex автоматично:
1. Забирає донат
2. Банить гравця
3. Повідомляє вас

**Fraud Detection:**
Автоматична перевірка шахрайських платежів.

## Купони та знижки

Створити купон:
\`\`\`
Code: CHRISTMAS2024
Discount: 25%
Valid for: All packages
Expires: 31.12.2024
\`\`\`

У наступному уроці налаштуємо донат-ранги!`
        },
        {
          id: '2.3',
          title: 'Створення донат-рангів з LuckPerms',
          duration: 1200,
          isFreePreview: false,
          content: `# Донат ранги - повна настройка

## Структура рангів

**Безкоштовні:**
- Default (всі гравці)

**Донат:**
- VIP (5$/міс)
- MVP (10$/міс)
- LEGEND (20$/міс)

**Адміністрація:**
- Helper
- Moderator
- Admin

## Створення рангів

**Default (за замовчуванням):**
\`\`\`
/lp creategroup default
/lp group default permission set essentials.spawn
/lp group default permission set essentials.tpa
/lp group default permission set essentials.home.limit.3
\`\`\`

**VIP:**
\`\`\`
/lp creategroup vip
/lp group vip parent add default
/lp group vip meta setprefix 100 "&a[VIP] "
/lp group vip permission set essentials.hat
/lp group vip permission set essentials.home.limit.10
/lp group vip permission set worldguard.region.bypass.*.entry
/lp group vip permission set particles.use
\`\`\`

**MVP:**
\`\`\`
/lp creategroup mvp
/lp group mvp parent add vip
/lp group mvp meta setprefix 200 "&6[MVP] "
/lp group mvp permission set essentials.home.limit.20
/lp group mvp permission set essentials.nick
/lp group mvp permission set pets.use
\`\`\`

**LEGEND:**
\`\`\`
/lp creategroup legend
/lp group legend parent add mvp
/lp group legend meta setprefix 300 "&c[LEGEND] "
/lp group legend permission set essentials.home.limit.50
/lp group legend permission set deluxemenus.vip
/lp group legend permission set emotes.use
\`\`\`

## Префікси в чаті

Встановити плагін ChatFormatter або EssentialsChat:

**EssentialsX Chat:**
Файл: plugins/Essentials/config.yml
\`\`\`yaml
format: '{DISPLAYNAME}: {MESSAGE}'
\`\`\`

**Для кольорових ніків:**
/lp group mvp permission set essentials.nick.color

## Тимчасові ранги

Видати VIP на 30 днів:
\`\`\`
/lp user Ivan parent addtemp vip 30d
\`\`\`

Автоматично забереться через 30 днів.

## Інтеграція з Tebex

**При покупці VIP (Tebex команди):**
\`\`\`
lp user {username} parent set vip
lp user {username} permission set essentials.hat
broadcast &a{username} купив VIP ранг!
give {username} diamond 5
\`\`\`

**При закінченні підписки:**
\`\`\`
lp user {username} parent set default
lp user {username} permission unset essentials.hat
\`\`\`

## Перки для кожного рангу

**VIP Перки:**
- Префікс [VIP] зелений
- /hat - носити блок на голові
- 10 home'ів
- Доступ до VIP зони
- Партикли

**MVP Перки:**
- Все з VIP +
- Префікс [MVP] золотий
- 20 home'ів
- /nick - змінити нік
- Пет (косметичний)
- Кольоровий текст в чаті

**LEGEND Перки:**
- Все з MVP +
- Префікс [LEGEND] червоний
- 50 home'ів
- Доступ до /fly на спавні
- Ембарки в чаті
- VIP меню з ексклюзивом

## Важливо - EULA Compliance

Всі перки легальні по Mojang EULA:
- Префікси - косметика ✓
- Home'и - не дають переваги в PvP ✓
- Партикли - косметика ✓
- /fly на спавні - дозволено ✓
- Доступ до зон - дозволено ✓

## Статистика донатів

Tebex Dashboard покаже:
- Скільки заробили за місяць
- Найпопулярніші пакети
- Хто купив
- Conversion rate (скільки % відвідувачів купують)

Тепер ваш сервер готовий до монетизації!`
        }
      ]
    }
  ]
};
