-- =====================================================
-- МОДУЛЬ 7, КВІЗ: Logging та Forensics
-- =====================================================
-- Курс: paid-4 (Advanced Anti-Cheat та Security Systems)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 7;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 15;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Квіз: Logging та Forensics',
    'quiz',
    '# Квіз: Logging та Forensics

1. Яка команда CoreProtect показує хто зламав блок на вашій позиції?
a) /co check
b) /co inspect
c) /co lookup
d) /co rollback

Правильна відповідь: c) /co lookup
Пояснення: /co lookup - базова команда для перегляду історії змін. /co inspect deprecated.

---

2. Ви виявили гріфінг 2 дні тому. Яка команда відкотить зміни гравця TestGriefer?
a) /co rollback u:TestGriefer t:48h
b) /co undo u:TestGriefer r:100
c) /co restore u:TestGriefer t:2d
d) /co revert TestGriefer 2days

Правильна відповідь: a) /co rollback u:TestGriefer t:48h
Пояснення: /co rollback u:[user] t:[time] - стандартний синтаксис. 48h = 2 дні.

---

3. Який параметр CoreProtect фільтрує дії в радіусі 50 блоків?
a) d:50
b) r:50
c) radius:50
d) distance:50

Правильна відповідь: b) r:50
Пояснення: r:[number] - radius parameter. d: не існує, distance: не використовується.

---

4. Гравець добув 47 діамантів за годину. Нормальна швидкість - 15-20. Це ознака:
a) Удачі
b) X-Ray
c) Efficiency V
d) Strip mining

Правильна відповідь: b) X-Ray
Пояснення: 47/hour = 3x норми. Класична ознака X-ray при >40/hour sustained.

---

5. Яка команда показує тільки ті блоки алмазної руди, які були зламані за 7 днів?
a) /co lookup b:diamond_ore t:7d
b) /co lookup b:56 t:7d a:break
c) /co lookup type:diamond action:break time:7d
d) /co search diamond_ore 7days break

Правильна відповідь: a) /co lookup b:diamond_ore t:7d
Пяснення: b:diamond_ore фільтрує блоки. За замовчуванням показує break actions. a:break опціонально.

---

6. Підозрілий гравець копає тільки на Y:11 (97% consistency). Це вказує на:
a) Знання оптимального рівня
b) X-ray чіт
c) Strip mine стратегію
d) Tutorial поради

Правильна відповідь: b) X-ray чіт
Пояснення: 97% на одному Y = unnatural. Легітимні гравці варіюють Y:5-15.

---

7. Команда /co restore робить протилежне до:
a) /co undo
b) /co rollback
c) /co remove
d) /co delete

Правильна відповідь: b) /co rollback
Пояснення: /co restore відновлює те, що /co rollback відкотив. Використовується для скасування помилкового rollback.

---

8. Ви бачите що гравець ігнорує видимі руди (coal, iron) але знаходить приховані діаманти. Це:
a) Фокус на цінних рудах
b) X-ray evidence
c) Luck
d) Efficient mining

Правильна відповідь: b) X-ray evidence
Пояснення: Ігнорування видимих руд = ви їх бачите крізь стіни. Strong x-ray indicator.

---

9. Який SQL запит знайде топ 10 гравців по block breaks за 30 днів?
a) SELECT user, COUNT(*) FROM co_block WHERE action=0 GROUP BY user ORDER BY COUNT(*) DESC LIMIT 10
b) SELECT player FROM co_block ORDER BY breaks DESC LIMIT 10
c) SELECT TOP 10 user, breaks FROM co_block
d) SELECT user COUNT breaks FROM co_block LIMIT 10

Правильна відповідь: a) SELECT user, COUNT(*) FROM co_block WHERE action=0 GROUP BY user ORDER BY COUNT(*) DESC LIMIT 10
Пояснення: action=0 = break. GROUP BY user + COUNT(*) = count per user. ORDER BY DESC + LIMIT 10 = top 10.

---

10. Гравець видобув 5,000 діамантів за 2 години. Найбільш ймовірно:
a) X-ray + Efficiency V
b) Dupe exploit
c) Vanilla luck
d) Strip mining pro

Правильна відповідь: b) Dupe exploit
Пояснення: 5,000 diamonds = impossible to mine in 2h навіть з x-ray. Це dupe pattern.

---

11. Яка команда перевіряє що rollback зробить БЕЗ застосування змін?
a) /co rollback u:Player t:1d #preview
b) /co rollback u:Player t:1d --test
c) /co rollback u:Player t:1d -p
d) /co preview u:Player t:1d

Правильна відповідь: a) /co rollback u:Player t:1d #preview
Пояснення: #preview flag показує що буде rollback без apply. Потім /co apply для виконання.

---

12. В якому форматі CoreProtect зберігає time в MySQL базі?
a) DATETIME
b) UNIX timestamp (integer)
c) VARCHAR
d) ISO 8601 string

Правильна відповідь: b) UNIX timestamp (integer)
Пояснення: CoreProtect uses UNIX timestamps (seconds since 1970). Efficient для queries та порівняння.

---

13. Ви отримали репорт про гріфінг. Перший крок:
a) Забанити підозрюваного
b) Teleport до локації та /co lookup
c) Rollback усе
d) Попросити screenshots

Правильна відповідь: b) Teleport до локації та /co lookup
Пояснення: Evidence collection first. Never ban without evidence. Teleport + lookup = standard procedure.

---

14. Severity level P0 (Critical) має response time:
a) <5 minutes
b) <1 hour
c) <24 hours
d) <1 week

Правильна відповідь: a) <5 minutes
Пояснення: P0 = Critical (server crash, active exploit, mass grief). Immediate response <5min required.

---

15. Гравець подав appeal через 10 хвилин після бану з текстом "unban me now!!!". Це:
a) Green flag (швидкий response)
b) Red flag (impatient, low quality)
c) Neutral
d) Acceptable appeal

Правильна відповідь: b) Red flag (impatient, low quality)
Пояснення: Appeals immediately after ban + demanding tone + no explanation = red flags. Likely deny.

---',
    600,
    15,
    false
  );

  RAISE NOTICE 'Module 7 Quiz created! Module 7 complete.';
END $$;
