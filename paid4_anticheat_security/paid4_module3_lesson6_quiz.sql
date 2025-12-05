-- =====================================================
-- МОДУЛЬ 3, УРОК 6: Quiz - Custom Anti-Cheat Development
-- =====================================================
-- Курс: paid-4 (Advanced Anti-Cheat та Security Systems)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 3;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 6;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Quiz: Custom Anti-Cheat Development',
    'quiz',
    '[
  {
    "question": "Чому Killaura rotation check перевіряє чи поворот не перевищує 80 градусів за tick?",
    "options": [
      "80 градусів - це ліміт Minecraft engine",
      "Legitimate гравці фізично не можуть повернути мишку швидше за 80°/50ms, більше - підозра на чіт",
      "80 градусів - стандарт Bukkit API",
      "Це випадкове значення для тестування"
    ],
    "correctAnswer": 1,
    "explanation": "Людина фізично не може повернути мишку дуже швидко. 1 tick = 50ms, і realistic максимум ~80 градусів. Killaura часто робить instant 180° snap, що виявляється цією перевіркою."
  },
  {
    "question": "Що таке multi-target detection в контексті Killaura?",
    "options": [
      "Атака декількох entities одночасно",
      "Виявлення атаки >2 різних entities за 1 секунду, що неможливо для legitimate гравця",
      "Перевірка damage dealt",
      "Аналіз inventory items"
    ],
    "correctAnswer": 1,
    "explanation": "Multi-target detection виявляє коли гравець атакує більше 2 різних entities за 1 секунду. Legitimate гравець фокусується на 1-2 цілях, тоді як Killaura може атакувати всі nearby entities."
  },
  {
    "question": "Чому hit pattern analysis перевіряє consistency атак (standard deviation)?",
    "options": [
      "Для статистики сервера",
      "Legitimate гравці мають варіацію в timing (human factor), чіти - perfect consistency з низькою std deviation",
      "Для визначення CPS",
      "Для перевірки ping"
    ],
    "correctAnswer": 1,
    "explanation": "Люди не можуть кликати з абсолютною consistency - завжди є мікро-варіації. Якщо standard deviation занадто низька (<15%), це означає bot-like behavior, характерний для Killaura."
  },
  {
    "question": "Як fly check відрізняє чіт від legitimate elytra flight?",
    "options": [
      "Перевіряє player inventory",
      "Перевіряє player.isGliding() та GameMode, ігноруючи CREATIVE/SPECTATOR та elytra users",
      "Вимірює швидкість польоту",
      "Перевіряє Y coordinate"
    ],
    "correctAnswer": 1,
    "explanation": "Fly check має whitelist умови: ігнорує гравців у CREATIVE/SPECTATOR mode та тих, хто використовує elytra (player.isGliding()). Це запобігає false positives для legitimate flight."
  },
  {
    "question": "Чому fly check відслідковує hover ticks (кількість ticks без вертикального руху в повітрі)?",
    "options": [
      "Для оптимізації performance",
      "Legitimate гравці падають через gravity, hovering >10 ticks без руху - ознака fly чіту",
      "Для логування статистики",
      "Для перевірки latency"
    ],
    "correctAnswer": 1,
    "explanation": "У Minecraft діє gravity (0.08 blocks/tick). Якщо гравець у повітрі і не рухається вертикально >10 ticks, це hover - характерна ознака fly чіту. Legitimate гравці завжди падають."
  },
  {
    "question": "Як speed check враховує potion effects (Speed II, Speed III)?",
    "options": [
      "Ігнорує potion effects повністю",
      "Додає SPEED_EFFECT_MULTIPLIER * (amplifier + 1) до max allowed speed",
      "Зменшує max speed",
      "Блокує рух гравця"
    ],
    "correctAnswer": 1,
    "explanation": "Speed check dynamically розраховує max allowed speed: base speed (0.36) * sprint (1.3) + speed effect (0.20 * amplifier). Це запобігає false positives для гравців з Speed II/III potions."
  },
  {
    "question": "Чому scaffold check перевіряє pitch (кут нахилу голови)?",
    "options": [
      "Для красивої статистики",
      "Legitimate гравці дивляться вниз (pitch >30°) коли ставлять блоки, scaffold часто не змінює rotation",
      "Для перевірки fly",
      "Pitch не має значення"
    ],
    "correctAnswer": 1,
    "explanation": "Коли людина ставить блоки під собою, вона дивиться вниз (pitch >30°). Scaffold чіти часто ставлять блоки не змінюючи rotation для швидкості. >5 блоків без look down - clear flag."
  },
  {
    "question": "Що зберігає PlayerData клас і навіщо?",
    "options": [
      "Тільки username та UUID",
      "Violations, movement history, combat data, timestamps - для stateful analysis між events",
      "Тільки current location",
      "Player inventory"
    ],
    "correctAnswer": 1,
    "explanation": "PlayerData зберігає historical data: violations per check, attack intervals, hover ticks, last locations. Це дозволяє робити stateful analysis - порівнювати поточну поведінку з минулою для pattern detection."
  },
  {
    "question": "Чому важливо використовувати async tasks для heavy calculations в anti-cheat?",
    "options": [
      "Для безпеки даних",
      "Heavy calculations на main thread викликають server lag/TPS drop, async виконує їх паралельно",
      "Async швидший за sync завжди",
      "Bukkit API вимагає async"
    ],
    "correctAnswer": 1,
    "explanation": "Minecraft server main thread обробляє game loop (20 TPS). Heavy calculations (complex analysis, ML inference) блокують main thread = lag. Async tasks виконуються на окремих threads, не впливаючи на TPS."
  },
  {
    "question": "Що таке ping compensation в speed check?",
    "options": [
      "Блокування гравців з high ping",
      "Збільшення tolerance based on ping (1.0 + ping/1000) для запобігання false positives через latency",
      "Зменшення max speed для laggy players",
      "Kick гравців з ping >200ms"
    ],
    "correctAnswer": 1,
    "explanation": "Високий ping викликає packet delay, через що server бачить рух гравця як ''телепортацію''. Ping compensation додає tolerance пропорційно ping (100ms ping = 10% tolerance), зменшуючи false positives."
  },
  {
    "question": "Чому violation level (VL) decay важливий?",
    "options": [
      "Для економії RAM",
      "Без decay, legitimate гравці накопичують VL через rare false positives і отримують бан, decay очищує old violations",
      "Decay не потрібен",
      "Для швидшого ban"
    ],
    "correctAnswer": 1,
    "explanation": "Навіть best AC має occasional false positives. Без VL decay, legitimate гравець може накопичити VL через lag spikes/edge cases і отримати несправедливий бан. Decay (-1 VL кожні 5 хв) дає ''чисту історію''."
  },
  {
    "question": "Що таке coefficient of variation в hit pattern analysis?",
    "options": [
      "Кількість hits per second",
      "Standard deviation / mean - normalized consistency metric, де низькі значення вказують на bot behavior",
      "Average damage dealt",
      "Ping measurement"
    ],
    "correctAnswer": 1,
    "explanation": "Coefficient of variation (CV) = std dev / mean. Це normalized consistency: CV 0.15 = 15% варіація. Human CV: 20-40%, bot CV: <15%. Використовується для порівняння consistency незалежно від attack speed."
  },
  {
    "question": "Чому scaffold check обмежує max place distance до 5.5 blocks?",
    "options": [
      "5.5 - випадкове число",
      "Vanilla Minecraft max reach = 5.0 blocks, 5.5 = tolerance для ping/hitbox, більше - scaffold/reach cheat",
      "5.5 blocks - ліміт Bukkit API",
      "Для оптимізації"
    ],
    "correctAnswer": 1,
    "explanation": "Vanilla Minecraft block interaction reach = 5.0 blocks. 5.5 blocks = 10% tolerance для edge cases (ping, hitbox на кордоні). Якщо гравець ставить блоки >5.5 blocks, це scaffold з reach extension."
  },
  {
    "question": "Як реалізувати batch processing для VL decay для 1000+ online players?",
    "options": [
      "runTask every tick",
      "runTaskTimerAsynchronously every 5 min, iterate all PlayerData, call decayViolations() - не блокує main thread",
      "Manual decay кожного гравця",
      "Не використовувати decay"
    ],
    "correctAnswer": 1,
    "explanation": "Для 1000+ гравців, individual decay кожен tick = performance issue. Batch processing: async task кожні 5 хв (6000 ticks) iterate всі PlayerData. Async не блокує main thread, periodic execution економить CPU."
  },
  {
    "question": "Чому важливо кешувати frequent calculations типу getMaxSpeed()?",
    "options": [
      "Для красивого коду",
      "getMaxSpeed() викликається кожен PlayerMoveEvent (багато разів/сек), caching уникає recalculation, зменшуючи CPU usage",
      "Кешування не впливає на performance",
      "Bukkit API вимагає caching"
    ],
    "correctAnswer": 1,
    "explanation": "PlayerMoveEvent triggers кожен рух гравця (часто >20/sec). Recalculating max speed кожен event (potion effects, blocks, etc) = wasted CPU. Cache results = compute once, reuse many times, clear on state change."
  }
]',
    600,
    6,
    false
  );

  RAISE NOTICE 'Module 3, Lesson 6 (Quiz) created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-4' AND m.order_index = 3
ORDER BY l.order_index;
