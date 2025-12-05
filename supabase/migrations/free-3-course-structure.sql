-- =====================================================
-- FREE-3: Безпека сервера - основи
-- =====================================================
-- Структура: 2 модулі, 6 уроків, 2 години 30 хвилин

-- Очищення старих даних
DELETE FROM course_lessons WHERE course_id = 'free-3';
DELETE FROM course_modules WHERE course_id = 'free-3';

-- =====================================================
-- МОДУЛЬ 1: Захист від гріферів (3 уроки, 1 година 15 хв)
-- =====================================================

DO $$
DECLARE
  v_module_id TEXT;
BEGIN
  v_module_id := gen_random_uuid()::text;
  
  INSERT INTO course_modules (
    id, course_id, title, description, order_index
  ) VALUES (
    v_module_id,
    'free-3',
    'CoreProtect: відслідковування та rollback',
    'Повний гайд по CoreProtect - запис всіх дій гравців, rollback гріфу, інспектування блоків.',
    1
  );

  -- Урок 1.1
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-3', v_module_id, gen_random_uuid()::text,
    'Встановлення CoreProtect та MySQL',
    'text',
    '# CoreProtect: захист від гріферів

## 🎯 Що таке CoreProtect?

**CoreProtect** - плагін який записує ВСІ дії на сервері:
- Хто поставив/зламав блок
- Хто відкрив скриню
- Хто вбив моба
- Хто використав TNT
- Хто вилив лаву

**Можливості:**
- 🔍 Інспектування блоку (хто змінював)
- ⏮️ Rollback (відміна дій)
- ⏭️ Restore (повернення дій)
- 📊 Lookup (пошук дій гравця)

## Встановлення

### Крок 1: Завантажити

```bash
# SpigotMC
https://www.spigotmc.org/resources/coreprotect.8631/

# Завантажити CoreProtect-22.2.jar
```

### Крок 2: Встановити

```bash
# Помістити в plugins/
plugins/CoreProtect-22.2.jar

# Запустити сервер
```

### Крок 3: MySQL (рекомендовано!)

**Чому MySQL замість SQLite?**

```
SQLite (за замовчуванням):
❌ Повільний на великих серверах
❌ Файл може пошкодитись
❌ Складно бекапити

MySQL:
✅ Швидкий навіть з мільйонами записів
✅ Професійний backup
✅ Можна підключити з інших інструментів
```

**Налаштування MySQL:**

```yaml
# plugins/CoreProtect/config.yml

use-mysql: true
table-prefix: co_
mysql-host: localhost
mysql-port: 3306
mysql-database: minecraft
mysql-username: minecraft_user
mysql-password: your_secure_password
```

## Базові команди

```bash
# Інспектування блоку
/co inspect
# Клікнути по блоку

# Пошук дій гравця
/co lookup u:PlayerName t:7d

# Rollback (відміна)
/co rollback u:Griefer t:7d r:50

# Restore (повернення)
/co restore u:PlayerName t:1h r:10
```

[Детальніше про параметри, приклади використання...]',
    1500,
    1,
    true
  );

  -- Урок 1.2
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-3', v_module_id, gen_random_uuid()::text,
    'Команди CoreProtect: lookup, rollback, restore',
    'text',
    '# CoreProtect: практичні сценарії

[Детальні приклади використання команд, реальні кейси гріфу...]',
    1200,
    2,
    true
  );

  -- Урок 1.3
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-3', v_module_id, gen_random_uuid()::text,
    'Розслідування гріфу: покрокова інструкція',
    'text',
    '# Як розслідувати гріф

[Покрокова інструкція розслідування, приклади, доказова база...]',
    1500,
    3,
    false
  );

END $$;

-- =====================================================
-- МОДУЛЬ 2: WorldGuard та LuckPerms (3 уроки, 1 година 15 хв)
-- =====================================================

DO $$
DECLARE
  v_module_id TEXT;
BEGIN
  v_module_id := gen_random_uuid()::text;
  
  INSERT INTO course_modules (
    id, course_id, title, description, order_index
  ) VALUES (
    v_module_id,
    'free-3',
    'WorldGuard: захист регіонів',
    'Створення та налаштування регіонів, прапорці (flags), пріоритети, батьківські регіони.',
    2
  );

  -- Урок 2.1
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-3', v_module_id, gen_random_uuid()::text,
    'WorldGuard: створення регіонів',
    'text',
    '# WorldGuard регіони

[Створення регіонів, команди, базові флаги...]',
    1500,
    1,
    false
  );

  -- Урок 2.2
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-3', v_module_id, gen_random_uuid()::text,
    'Flags: всі можливості WorldGuard',
    'text',
    '# WorldGuard флаги повний гайд

[Всі флаги, приклади, типові налаштування для spawn/pvp/shop...]',
    1200,
    2,
    false
  );

  -- Урок 2.3
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'free-3', v_module_id, gen_random_uuid()::text,
    'LuckPerms + WorldGuard: інтеграція прав',
    'text',
    '# Права в регіонах

[Як давати права на регіони через LuckPerms, приклади...]',
    1500,
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
LEFT JOIN course_lessons cl ON cm.id::text = cl.module_id
WHERE cm.course_id = 'free-3'
GROUP BY cm.id, cm.order_index, cm.title
ORDER BY cm.order_index;
