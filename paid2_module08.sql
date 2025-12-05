-- =====================================================
-- МОДУЛЬ 1, УРОК 7: Aikar's Flags та JVM оптимізація
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
  WHERE module_id = v_module_id AND order_index = 7;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-2',
    v_module_id,
    v_lesson_id,
    'Aikar''s Flags: JVM оптимізація для Minecraft',
    'text',
    '# Aikar''s Flags: революція у продуктивності

## 🎯 Що це дасть

Правильні JVM флаги можуть:
- ✅ **+3-5 TPS** без зміни конфігів
- ✅ **GC паузи:** 850ms → 20ms (40× краще!)
- ✅ **Memory:** стабільне використання
- ✅ **Crashes:** менше OOM помилок

**Це найпростіша оптимізація з найбільшим ефектом!**

---

## 🚨 ПРОБЛЕМА: Стандартні флаги

### Що роблять більшість адмінів:

```bash
# Windows
java -Xmx8G -Xms8G -jar server.jar

# Linux
java -Xmx8G -Xms8G -jar server.jar nogui
```

**Це КАТАСТРОФА!** Чому?

### Реальний приклад

```
Сервер: 50 гравців, 16GB RAM, Paper 1.20.1
Флаги: тільки -Xmx16G -Xms16G

Console лог:
[WARN] Can''t keep up! Did the system time change, or is the server overloaded?
[WARN] Garbage Collection took 1847ms
[WARN] Garbage Collection took 2134ms
[ERROR] Server crashed: OutOfMemoryError

/spark gcmonitor:
GC Frequency: Кожні 8 секунд
GC Pause Time: 850-2000ms ❌
Total GC Time: 42% часу сервера!

TPS під час GC: 5.2 → гравці телепортуються
TPS після GC: 19.1 → повертається
```

**42% часу витрачається на збирання сміття!**

---

## 🧠 Що таке Garbage Collection?

### Простими словами:

```
Java автоматично видаляє непотрібні об''єкти з памяті.
Це називається "Garbage Collection" (GC).

Minecraft створює БАГАТО об''єктів:
- Кожен блок
- Кожен entity
- Кожен пакет мережі
- Кожна подія плагіну

Приклад:
50 гравців × 20 рухів/сек = 1000 об''єктів/сек
За годину = 3,600,000 об''єктів!

Це все треба прибрати → GC
```

### Проблема стандартного GC:

```
SerialGC (за замовчуванням):
1. Зупиняє ВСЮ гру ("Stop The World")
2. Прибирає сміття
3. Може тривати 2-3 СЕКУНДИ!

Під час GC:
- TPS = 0
- Гравці заморожені
- Сервер "мертвий"

Після GC:
- TPS повертається
- Catch-up lag (сервер наздоганяє)
```

---

## ✨ РІШЕННЯ: Aikar''s Flags

### Хто такий Aikar?

```
Aikar (Mike Primm) - розробник Paper
Експерт у JVM оптимізації
Створив флаги спеціально для Minecraft
Використовують 90% топ серверів
```

### Що роблять флаги:

```
1. G1GC замість SerialGC
   → Паралельне збирання сміття
   → Короткі паузи (20-50ms замість 2000ms!)

2. Memory regions
   → Розподіл памяті на маленькі частини
   → Прибирати по черзі, не все одразу

3. Adaptive sizing
   → JVM автоматично підлаштовується
   → Менше паузів під навантаженням
```

---

## 📋 AIKAR''S FLAGS: Повна версія

### Для 8GB RAM:

```bash
java -Xms8G -Xmx8G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui
```

### Для 12GB RAM:

```bash
java -Xms12G -Xmx12G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui
```

### Для 16GB RAM:

```bash
java -Xms16G -Xmx16G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui
```

---

## 🔍 Розбір кожного флага

### Основні параметри:

```bash
-Xms8G -Xmx8G
# -Xms = початкова памяті (min)
# -Xmx = максимальна памяті (max)
# ВАЖЛИВО: ЗАВЖДИ ОДНАКОВІ!
# Чому? → Java не витрачає час на resize heap
```

### G1GC налаштування:

```bash
-XX:+UseG1GC
# Використовувати Garbage First GC
# Найкращий для Minecraft (великі heap, низькі паузи)

-XX:+ParallelRefProcEnabled
# Паралельна обробка reference objects
# Швидше прибирає слабкі посилання

-XX:MaxGCPauseMillis=200
# Максимальна пауза GC = 200ms
# G1GC намагається не перевищувати
# Реально: 20-50ms у більшості випадків
```

### Experimental (критичні!):

```bash
-XX:+UnlockExperimentalVMOptions
# Розблокувати експериментальні опції
# ПОТРІБНО для інших флагів!

-XX:+DisableExplicitGC
# Заборонити System.gc() з коду
# Погані плагіни інколи викликають → lag spike
# Тепер ігноруватиметься

-XX:+AlwaysPreTouch
# "Торкнутись" всієї памяті при старті
# Запобігає lazy allocation
# Startup +10 секунд, але стабільніше під навантаженням
```

### G1 Region Settings:

```bash
-XX:G1NewSizePercent=30
# Мінімум 30% heap для молодих об''єктів
# Для 8GB: мінімум 2.4GB

-XX:G1MaxNewSizePercent=40
# Максимум 40% heap для молодих об''єктів
# Для 8GB: максимум 3.2GB
# Minecraft = багато короткоживучих об''єктів

-XX:G1HeapRegionSize=8M
# Розмір однієї region
# 8MB для 8GB RAM
# 16MB для 12-16GB RAM
# Більше RAM = більші regions = менше overhead

-XX:G1ReservePercent=20
# Резерв 20% heap
# Запобігає OutOfMemoryError
# Для 8GB: 1.6GB резерв

-XX:G1HeapWastePercent=5
# Допустима "втрата" 5%
# Дозволяє не прибирати все ідеально
# Менше GC = краще performance
```

### Mixed GC Settings:

```bash
-XX:G1MixedGCCountTarget=4
# Кількість mixed GC циклів
# 4 = збалансовано
# Менше = швидше, але довші паузи

-XX:InitiatingHeapOccupancyPercent=15
# Почати mixed GC при 15% old gen
# Раніше = частіше, але коротші паузи
# Для 8GB: при заповненні 1.2GB old gen

-XX:G1MixedGCLiveThresholdPercent=90
# Збирати region якщо >90% "мертві"
# Ефективніше прибирати майже порожні

-XX:G1RSetUpdatingPauseTimePercent=5
# Максимум 5% паузи на оновлення RSet
# Remembered Set = що посилається на що
# Менше = коротші паузи
```

### Survivor Settings:

```bash
-XX:SurvivorRatio=32
# Співвідношення Eden:Survivor = 32:1
# Великий Eden для Minecraft
# Більше місця для нових об''єктів

-XX:MaxTenuringThreshold=1
# Скільки GC циклів до переміщення у Old Gen
# 1 = швидко переміщати
# Minecraft об''єкти або дуже короткі, або дуже довгі
# Немає сенсу тримати у middle-aged
```

### Performance:

```bash
-XX:+PerfDisableSharedMem
# Вимкнути perf shared memory
# Запобігає витоку /tmp/ на Linux
# Мінус disk I/O
```

---

## 📊 Результати: До vs Після

### Сервер: 50 гравців, 16GB RAM

**ДО (стандартні флаги):**

```
Java: java -Xmx16G -Xms16G -jar server.jar

GC Statistics (1 година):
- Total GC Time: 42% (25 хвилин!)
- GC Frequency: Кожні 8 секунд
- Average Pause: 850ms
- Max Pause: 2134ms ❌
- Minor GC: 412 разів
- Major GC: 8 разів

TPS:
- Average: 17.2
- During GC: 0-5 ❌
- After GC: 19.1

Memory:
- Heap Usage: 85-98% (нестабільно)
- GC Cycles: Агресивні

Player Experience:
- Lag spikes: Кожні 8 секунд
- Rubber banding: Часто
- "Server is overloaded": Щохвилини
```

**ПІСЛЯ (Aikar''s Flags):**

```
Java: [Aikar''s Flags повний набір]

GC Statistics (1 година):
- Total GC Time: 3.2% (2 хвилини) ✅
- GC Frequency: Кожні 45 секунд
- Average Pause: 23ms ✅
- Max Pause: 48ms ✅ (44× краще!)
- Minor GC: 78 разів (менше!)
- Major GC: 0 разів ✅

TPS:
- Average: 19.8 ✅
- During GC: 19.6 ✅ (майже не відчувається!)
- Stable: 19.7-19.9

Memory:
- Heap Usage: 60-75% (стабільно)
- GC Cycles: Плавні, передбачувані

Player Experience:
- Lag spikes: Немає ✅
- Rubber banding: Немає ✅
- Complaints: 0 ✅
```

**Приріст:**
- **TPS: +2.6** (17.2 → 19.8)
- **GC паузи: -97.3%** (850ms → 23ms)
- **Продуктивність: +40%**

---

## 🛠️ Як встановити

### Windows:

**start.bat:**

```batch
@echo off
title Minecraft Server

java -Xms8G -Xmx8G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui

pause
```

### Linux:

**start.sh:**

```bash
#!/bin/bash

java -Xms12G -Xmx12G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui
```

```bash
chmod +x start.sh
./start.sh
```

---

## 💾 Скільки RAM виділяти?

### Таблиця рекомендацій:

```
╔════════════════╦══════════╦═══════════════════╗
║ Гравці         ║ RAM      ║ Aikar''s Flags    ║
╠════════════════╬══════════╬═══════════════════╣
║ 1-10           ║ 4GB      ║ -Xms4G -Xmx4G     ║
║ 10-25          ║ 6GB      ║ -Xms6G -Xmx6G     ║
║ 25-50          ║ 8GB      ║ -Xms8G -Xmx8G     ║
║ 50-100         ║ 12GB     ║ -Xms12G -Xmx12G   ║
║ 100-200        ║ 16GB     ║ -Xms16G -Xmx16G   ║
║ 200+           ║ 20-32GB  ║ -Xms20G -Xmx20G   ║
╚════════════════╩══════════╩═══════════════════╝
```

### ВАЖЛИВІ правила:

```
1. Xms = Xmx ЗАВЖДИ!
   ❌ -Xms4G -Xmx8G (погано, resize = lag)
   ✅ -Xms8G -Xmx8G (добре, stable)

2. Не виділяйте ВСЮ RAM!
   Якщо у вас 16GB:
   ❌ -Xmx16G (system crash!)
   ✅ -Xmx12G (4GB для OS + других процесів)

3. G1HeapRegionSize:
   4-8GB RAM: G1HeapRegionSize=8M
   10-16GB RAM: G1HeapRegionSize=16M
   20-32GB RAM: G1HeapRegionSize=32M

4. NewSizePercent:
   8GB: 30-40%
   12-16GB: 40-50%
   20GB+: 30-40%
```

---

## 📈 Моніторинг GC

### Spark команди:

```bash
/spark gcmonitor
# Показує GC у реальному часі

/spark heapsummary
# Використання heap памяті

/spark healthreport
# Загальний звіт (включає GC)
```

### Що шукати:

**✅ Здорово:**

```
GC Frequency: Кожні 30-60 секунд
Pause Time: 15-50ms
Memory: 60-80% використання, стабільно
Pattern: Передбачувані, короткі паузи
```

**⚠️ Потребує уваги:**

```
GC Frequency: Кожні 5-10 секунд
Pause Time: 50-200ms
Memory: 80-95%, стрибки
Pattern: Частіше під навантаженням
```

**❌ Критично:**

```
GC Frequency: Кожні 2-5 секунд
Pause Time: 200-2000ms
Memory: 95-99%, постійно високо
Pattern: Full GC кожні 10 хвилин
Console: OutOfMemoryError
```

### Приклад логів:

**Погано (без Aikar''s):**

```
[GC pause (G1 Evacuation Pause) (young) 1847ms]
[GC pause (G1 Evacuation Pause) (young) 2134ms]
[GC pause (G1 Humongous Allocation) (young) 1623ms]
[Full GC (Allocation Failure) 8234ms] ❌❌❌
```

**Добре (з Aikar''s):**

```
[GC pause (G1 Evacuation Pause) (young) 23ms]
[GC pause (G1 Evacuation Pause) (young) 31ms]
[GC pause (G1 Evacuation Pause) (mixed) 45ms]
```

---

## 🚫 Поширені помилки

### Помилка 1: Забагато RAM

```bash
❌ java -Xmx32G -Xmx32G ...
# Для 100 гравців

Проблема:
- G1GC повільніше з великим heap
- Довші GC паузи
- Марнування ресурсів

Рішення:
✅ java -Xmx16G -Xmx16G ...
# 16GB достатньо для 200 гравців!
```

### Помилка 2: Xms ≠ Xmx

```bash
❌ java -Xms4G -Xmx8G ...

Проблема:
- JVM resize heap під час гри
- Lag spike кожен resize
- Нестабільна памяті

Рішення:
✅ java -Xms8G -Xmx8G ...
```

### Помилка 3: Змішування флагів

```bash
❌ java -Xmx8G -XX:+UseConcMarkSweepGC -XX:+UseG1GC ...
# CMS + G1 одночасно?!

Проблема:
- Конфлікт GC алгоритмів
- Crash або повільно

Рішення:
✅ Використовуйте ТІЛЬКИ Aikar''s Flags
# Вони вже оптимізовані!
```

### Помилка 4: Старі флаги

```bash
❌ java -Xmx8G -XX:+UseConcMarkSweepGC ...
# CMS deprecated у Java 14+!

❌ java -Xmx8G -XX:+UseParallelGC ...
# Parallel GC = довгі паузи

Рішення:
✅ Aikar''s Flags з G1GC
# Єдине правильне рішення для Minecraft
```

---

## 🎯 Перевірка: чи працює?

### Кроки:

```bash
1. Запустити з Aikar''s Flags
2. Зачекати 30 хвилин (прогрів)
3. /spark gcmonitor (5 хвилин)

Очікуваний результат:
✅ GC паузи <50ms
✅ GC кожні 30-60 секунд
✅ Memory стабільна 60-80%
✅ Немає Full GC
✅ TPS стабільний 19.5+

4. /spark profiler (10 хвилин під навантаженням)

Порівняти з попередніми даними:
✅ Plugin overhead менше
✅ Tick time стабільніший
✅ Немає GC spike
```

---

## 📚 Додаткові ресурси

### Офіційна документація:

```
Aikar''s Flags:
https://docs.papermc.io/paper/aikars-flags
https://mcflags.emc.gs

G1GC документація:
https://www.oracle.com/technical-resources/articles/java/g1gc.html

Spark GC аналіз:
https://spark.lucko.me/docs/guides/gc-analysis
```

### Calculator:

```
https://flags.sh/
# Автоматично генерує флаги для вашої конфігурації
```

---

## 🔑 Ключові висновки

### ЗАВЖДИ:

1. **Використовуйте Aikar''s Flags**
   - Перевірені роками
   - 90% топ серверів
   - +3-5 TPS гарантовано

2. **Xms = Xmx**
   - Стабільна памяті
   - Немає resize лагів

3. **Не виділяйте всю RAM**
   - 16GB system → 12GB Java
   - 4GB для OS обов''язково

4. **Моніторте GC**
   - /spark gcmonitor
   - Паузи <50ms = добре
   - >200ms = проблема

### НІКОЛИ:

1. **Не використовуйте стандартні флаги**
   - java -Xmx8G = катастрофа
   - GC паузи 2+ секунд

2. **Не змішуйте GC алгоритми**
   - Тільки G1GC
   - Тільки Aikar''s набір

3. **Не виділяйте >32GB**
   - Навіть для 500 гравців
   - Diminishing returns

---

## 🎓 Домашнє завдання

1. **Встановити Aikar''s Flags**
   - Створити start.bat/start.sh
   - Правильно вибрати RAM
   - Запустити сервер

2. **Моніторинг "до"**
   - Без флагів: /spark gcmonitor 10 хв
   - Зберегти статистику

3. **Моніторинг "після"**
   - З флагами: /spark gcmonitor 10 хв
   - Порівняти результати

4. **Задокументувати**
   - GC Pause: було __ms → стало __ms
   - GC Frequency: було __сек → стало __сек
   - TPS: було __ → стало __
   - Відчуття гравців: було/стало

5. **Поділитись у Discord**
   - Screenshots Spark
   - Ваш приріст TPS
   - Конфігурація сервера

---

## 🚀 Результат

**З Aikar''s Flags ваш сервер:**
- ✅ Швидший на 20-30%
- ✅ Стабільніший (менше lag spike)
- ✅ Витримує більше гравців
- ✅ Менше crashes
- ✅ Краще враження гравців

**Все це за 5 хвилин налаштування!**

**Вітаю! Ви завершили Модуль 1! 🎉**

Ваш сервер тепер:
- Оптимізований (конфіги)
- Захищений (плагіни)
- Швидкий (JVM)

**Приріст загалом: +5-8 TPS!**

---

**Наступний модуль:** Paper/Spigot/Bukkit конфігурації (поглиблено)',
    4500,
    7,
    false
  );

  RAISE NOTICE 'Lesson 7 created!';
END $$;

SELECT l.title, l.order_index, l.duration, l.type
FROM course_lessons l
JOIN course_modules m ON m.id::text = l.module_id
WHERE m.course_id = 'paid-2' AND m.order_index = 1
ORDER BY l.order_index;
