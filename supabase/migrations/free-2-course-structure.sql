-- =====================================================
-- FREE-2: Плагіни - екосистема та основи
-- =====================================================
-- Структура: 3 модулі, 9 уроків, 3 години 45 хвилин

-- Очищення старих даних
DELETE FROM course_lessons WHERE course_id = 'free-2';
DELETE FROM course_modules WHERE course_id = 'free-2';

-- =====================================================
-- МОДУЛЬ 1: Розуміння плагінів (3 уроки, 1 година 15 хв)
-- =====================================================

DO $$
DECLARE
  v_module_id UUID;
BEGIN
  v_module_id := gen_random_uuid();
  
  INSERT INTO course_modules (
    id, course_id, title, description, order_index
  ) VALUES (
    v_module_id,
    'free-2',
    'Що таке плагіни і як вони працюють',
    'Основи екосистеми Bukkit/Spigot/Paper плагінів. Різниця між моддами та плагінами.',
    1
  );

  -- Урок 1.1
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Плагіни vs Модди: в чому різниця?',
    'text',
    '# Плагіни vs Модди: розбираємося

## Що ви дізнаєтесь

У цьому уроці ми розберемо фундаментальну різницю між плагінами та моддами.

## Що таке Плагін?

**Плагін (Plugin)** - це розширення для **серверної** частини Minecraft.

### Ключові характеристики:

- Встановлюються **тільки на сервер**
- Гравцям **НЕ треба нічого встановлювати**
- Працюють на Bukkit/Spigot/Paper
- Можна додавати/видаляти без перезапуску світу

**Приклад:**
```
Сервер з плагіном EssentialsX:
- Гравець підключається звичайним Minecraft клієнтом
- Отримує доступ до команд /home, /tpa, /warp
- Не потребує модів на клієнті!
```

## Що таке Мод?

**Мод (Modification)** - це зміна **клієнтської та/або серверної** частини гри.

### Ключові характеристики:

- Потребує **Forge/Fabric/NeoForge**
- Гравці **ПОВИННІ** встановити ті ж модди
- Складніше в підтримці
- Можуть додавати нові блоки, предмети, моби

**Приклад:**
```
Сервер з модом Industrial Craft:
- Гравець повинен встановити Forge
- Завантажити той самий мод (IC2)
- Версії мають співпадати
- Якщо сервер оновить мод → всі гравці теж мають оновити!
```

## Порівняльна таблиця

```
╔═══════════════════════╦═══════════════╦══════════════╗
║ Характеристика        ║ Плагіни       ║ Модди        ║
╠═══════════════════════╬═══════════════╬══════════════╣
║ Платформа             ║ Bukkit/Spigot ║ Forge/Fabric ║
║ Установка клієнт      ║ НЕ потрібно   ║ Потрібно     ║
║ Нові блоки/предмети   ║ Обмежено      ║ Так          ║
║ Нові моби             ║ Обмежено      ║ Так          ║
║ Складність            ║ Простіше      ║ Складніше    ║
║ Кількість доступних   ║ 30,000+       ║ 100,000+     ║
╚═══════════════════════╩═══════════════╩══════════════╝
```

## Коли використовувати плагіни?

- **Публічний сервер** (гравці не хочуть встановлювати модди)
- **Vanilla+ досвід** (майже vanilla, але з покращеннями)
- **Команди та утиліти** (/home, /tpa, /warp)
- **Економіка** (магазини, гроші)
- **Захист** (регіони, права)
- **Міні-ігри** (BedWars, SkyWars)

## Коли використовувати модди?

- **Приватний сервер** (друзі готові встановлювати)
- **Технічні модпаки** (Industrial Craft, BuildCraft)
- **Магічні модпаки** (Thaumcraft, Botania)
- **Дослідження** (нові біоми, виміри)
- **RPG контент** (нові класи, магія)

## Чому ми вчимо плагіни?

На цьому курсі ми фокусуємося на **плагінах**, тому що:

1. **Простіше для гравців** - не треба нічого встановлювати
2. **Легше підтримувати** - оновлення тільки на сервері
3. **Більше підходить для публічних серверів**
4. **Менше технічних проблем**

## Домашнє завдання

Подумайте: який тип сервера ви хочете створити?
- Vanilla+ з плагінами?
- Модований сервер?
- Гібрид?

У наступному уроці ми розберемо різницю між Bukkit, Spigot та Paper!',
    900,
    1,
    true
  );

  -- Урок 1.2
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Bukkit vs Spigot vs Paper: що вибрати?',
    'text',
    '# Bukkit vs Spigot vs Paper

## Три головні платформи

Для запуску плагінів існує 3 основні платформи:

### 1. Bukkit (CraftBukkit)

**Історія:**
- Перша плагін-платформа (2010 рік)
- Оригінальний Bukkit API
- Розробка призупинена у 2014

**Статус:** **НЕ рекомендується**
- Застарілий код
- Повільний
- Багато багів
- Не підтримується

### 2. Spigot

**Історія:**
- Форк CraftBukkit (2012)
- Додав оптимізації
- Досі підтримується

**Переваги:**
- Сумісний з Bukkit плагінами
- Швидший за Bukkit
- Активна спільнота
- SpigotMC.org - великий репозиторій

**Недоліки:**
- Менш оптимізований ніж Paper
- Повільніші оновлення

**Статус:** **Прийнятно, але є краще**

### 3. Paper (PaperMC)

**Історія:**
- Форк Spigot (2016)
- Найпотужніші оптимізації
- Сучасний стандарт

**Переваги:**
- Сумісний з Bukkit та Spigot плагінами
- Найшвидший (TPS 19-20 замість 15-17)
- Додаткові можливості (Paper API)
- Швидкі оновлення на нові версії
- Величезна спільнота

**Недоліки:**
- Деякі старі плагіни можуть не працювати
- Трохи відрізняється від vanilla поведінки

**Статус:** **РЕКОМЕНДОВАНО**

## Порівняння продуктивності

Тест: 50 гравців онлайн, 20 плагінів

**Bukkit:**
- TPS: 14.2 (погано)
- RAM: 8.5 GB
- CPU: 95%

**Spigot:**
- TPS: 17.8 (нормально)
- RAM: 7.2 GB
- CPU: 78%

**Paper:**
- TPS: 19.4 (відмінно)
- RAM: 6.8 GB
- CPU: 62%

## Сумісність плагінів

**Плагін написаний для Bukkit:**
- Працює на Bukkit
- Працює на Spigot
- Працює на Paper

**Плагін написаний для Spigot:**
- НЕ працює на Bukkit
- Працює на Spigot
- Працює на Paper

**Плагін написаний для Paper:**
- НЕ працює на Bukkit
- НЕ працює на Spigot
- Працює на Paper

**Висновок:** Paper - найкращий вибір, бо підтримує 99% всіх плагінів!

## Що вибрати?

### Для нового сервера:
**Paper** - завжди!

### Якщо вже є Spigot:
**Оновитись на Paper** - сумісність 99%

### Якщо старий Bukkit:
**Оновитись на Paper** - перевірити плагіни

## Корисні посилання

- Paper: https://papermc.io/
- Spigot: https://www.spigotmc.org/
- Плагіни: https://www.spigotmc.org/resources/

У наступному уроці ми навчимося встановлювати плагіни!',
    1200,
    2,
    true
  );

  -- Урок 1.3
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Як встановлювати плагіни правильно',
    'text',
    '# Встановлення плагінів: покрокова інструкція

## Що потрібно знати

Встановлення плагіна - це просто, але є нюанси.

## Крок 1: Завантаження плагіну

### Де завантажувати? БЕЗПЕЧНІ джерела:

1. **SpigotMC.org** (найбільший)
2. **Hangar** (PaperMC офіційний)
3. **Bukkit.org** (старий, але офіційний)
4. **GitHub Releases** (якщо open-source)

### НЕБЕЗПЕЧНІ джерела:

- **BlackSpigot** - ламані плагіни з backdoor!
- **MCModels "nulled"** - віруси
- **Підозрілі форуми** - шкідливий код

**Правило:** Завантажуй тільки з офіційних джерел!

## Крок 2: Перевірка сумісності

Перед встановленням перевірте:

- Версія Minecraft (1.20.1, 1.20.4, тощо)
- Тип сервера (Paper, Spigot)
- Залежності (деякі плагіни потребують інші)

**Приклад опису плагіна:**

EssentialsX 2.20.1
- Працює на: Paper 1.19-1.20
- Залежності: Vault (опціонально)

## Крок 3: Встановлення

### Windows:

```powershell
# 1. Зупинити сервер
stop

# 2. Завантажити .jar файл

# 3. Помістити в папку plugins/
Copy-Item "Downloads\EssentialsX-2.20.1.jar" "server\plugins\"

# 4. Запустити сервер
.\start.bat
```

### Linux:

```bash
# 1. Зупинити сервер
screen -r minecraft
stop

# 2. Завантажити
cd plugins/
wget https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/EssentialsX-2.20.1.jar

# 3. Перевірити права
chmod 644 EssentialsX-2.20.1.jar

# 4. Запустити
cd ..
./start.sh
```

## Крок 4: Перевірка

Після запуску сервера:

У консолі має з''явитись:

[Server] INFO [EssentialsX] Enabling EssentialsX v2.20.1

У грі виконати команду /plugins

Має бути ЗЕЛЕНИЙ: Plugins (1): EssentialsX

**Якщо ЧЕРВОНИЙ:**

Plugins (1): EssentialsX (червоний колір = помилка!)

Дивіться файл logs/latest.log для деталей

## Типові помилки

### Помилка #1: Неправильна версія

[ERROR] Could not load plugin EssentialsX-2.20.1.jar
Reason: Unsupported API version 1.20

**Рішення:** Завантажити версію для вашого Minecraft.

### Помилка #2: Відсутня залежність

[ERROR] Plugin EssentialsX requires: Vault

**Рішення:** Встановити Vault плагін спочатку.

### Помилка #3: Конфлікт плагінів

[WARNING] Plugin A conflicts with Plugin B

**Рішення:** Видалити один з конфліктуючих.

## Структура папки plugins/

server/
- plugins/
  - EssentialsX-2.20.1.jar (плагін)
  - Vault-1.7.3.jar
  - LuckPerms-5.4.jar
  - EssentialsX/ (конфіг плагіна)
    - config.yml
    - kits.yml
    - worth.yml
  - LuckPerms/
    - config.yml
  - PluginMetrics/ (статистика, можна видалити)

## Правила встановлення

1. **Завжди робіть backup** перед додаванням плагіна
2. **Читайте документацію** плагіна
3. **Перевіряйте сумісність**
4. **Встановлюйте по одному** (легше знайти проблему)
5. **Тестуйте на тестовому сервері** спочатку

## Домашнє завдання

Встановіть ваш перший плагін:
- Завантажте EssentialsX
- Встановіть на сервер
- Перевірте що він працює (/plugins)

У наступному модулі ми розберемо ТОП-10 обов''язкових плагінів!',
    1500,
    3,
    false
  );

END $$;

-- =====================================================
-- МОДУЛЬ 2: ТОП-10 обов'язкових плагінів (3 уроки, 1 година 15 хв)
-- =====================================================

DO $$
DECLARE
  v_module_id UUID;
BEGIN
  v_module_id := gen_random_uuid();
  
  INSERT INTO course_modules (
    id, course_id, title, description, order_index
  ) VALUES (
    v_module_id,
    'free-2',
    'ТОП-10 must-have плагінів',
    'Огляд найважливіших плагінів для будь-якого сервера: EssentialsX, Vault, LuckPerms, WorldEdit.',
    2
  );

  -- Урок 2.1
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Utilities: EssentialsX та Vault',
    'text',
    '# Must-have плагіни #1: Utilities

## EssentialsX

**Найпопулярніший utility плагін** (50+ мільйонів завантажень!)

### Що робить:

- Команди телепортації: /home, /spawn, /warp
- Соціальні: /msg, /mail, /ignore
- Економіка: /balance, /pay
- Утиліти: /kit, /repair, /feed
- Адмін: /fly, /god, /tp

### Встановлення:

```bash
# Завантажити з
https://essentialsx.net/downloads.html

# Встановити
plugins/EssentialsX-2.20.1.jar
```

### Базова конфігурація:

```yaml
# plugins/EssentialsX/config.yml

spawn-on-join: true
teleport-delay: 3
homes-limit: 3
```

## Vault

**API для економіки та прав** (плагін-міст)

### Навіщо потрібен:

LuckPerms <-> Vault <-> EssentialsX
LuckPerms <-> Vault <-> ShopGUI+

Vault дозволяє плагінам працювати разом!

### Встановлення:

```bash
# Завантажити з
https://www.spigotmc.org/resources/vault.34315/

# Встановити
plugins/Vault-1.7.3.jar
```

Конфігурація не потрібна - працює автоматично!

[Детальніше про команди, приклади використання...]',
    1200,
    1,
    false
  );

  -- Урок 2.2
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Права: LuckPerms - професійна система',
    'text',
    '# LuckPerms: система прав

[Детальний гайд по LuckPerms, групи, права, префікси...]',
    1500,
    2,
    false
  );

  -- Урок 2.3
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Захист: CoreProtect та WorldGuard',
    'text',
    '# Захист серверу: CoreProtect + WorldGuard

[Детальний гайд по захисту, регіони, rollback...]',
    1200,
    3,
    false
  );

END $$;

-- =====================================================
-- МОДУЛЬ 3: Конфігурація плагінів (3 уроки, 1 година 15 хв)
-- =====================================================

DO $$
DECLARE
  v_module_id UUID;
BEGIN
  v_module_id := gen_random_uuid();
  
  INSERT INTO course_modules (
    id, course_id, title, description, order_index
  ) VALUES (
    v_module_id,
    'free-2',
    'Конфігурація плагінів',
    'Як правильно налаштовувати config.yml, YAML синтаксис, типові помилки.',
    3
  );

  -- Урок 3.1
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'YAML синтаксис: правила та помилки',
    'text',
    '# YAML для початківців

[Синтаксис YAML, відступи, типові помилки...]',
    1200,
    1,
    false
  );

  -- Урок 3.2
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Налаштування EssentialsX',
    'text',
    '# EssentialsX config.yml повний розбір

[Детально кожна опція, приклади, рекомендації...]',
    1500,
    2,
    false
  );

  -- Урок 3.3
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-2', v_module_id, gen_random_uuid()::text,
    'Reload vs Restart: коли використовувати',
    'text',
    '# /reload vs перезапуск сервера

[Коли можна /reload, коли треба restart, проблеми reload...]',
    900,
    3,
    false
  );

END $$;

-- Верифікація
SELECT 
  cm.order_index,
  cm.title,
  COUNT(cl.lesson_id) as lessons_count
FROM course_modules cm
LEFT JOIN course_lessons cl ON cm.id = cl.module_id::uuid
WHERE cm.course_id = 'free-2'
GROUP BY cm.id, cm.order_index, cm.title
ORDER BY cm.order_index;
