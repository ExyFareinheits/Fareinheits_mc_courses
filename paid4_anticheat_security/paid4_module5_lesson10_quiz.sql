-- =====================================================
-- МОДУЛЬ 5, УРОК 10: Quiz - Exploit Prevention
-- =====================================================

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 5;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 10;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Quiz: Exploit Prevention',
    'quiz',
    '[
  {
    "question": "Як працював anvil rename dupe exploit в Ukrainian Prison Server case?",
    "options": [
      "Просто rename anvil багато разів",
      "Modified client відправляв ClickWindowPacket з negative slot під час rename, server bug дублював item",
      "Anvil crashнув server",
      "Exploit використовував VPN"
    ],
    "correctAnswer": 1,
    "explanation": "Exploit експлуатував bug в обробці ClickWindowPacket: коли client відправляв packet з negative slot number під час anvil rename операції, server неправильно обробляв inventory update і дублював item. Fix: validate slot >= 0."
  },
  {
    "question": "Чому async inventory save небезпечний для dupe prevention?",
    "options": [
      "Async повільніший",
      "Між async task start та execution, inventory може змінитися, race condition дозволяє item duplication",
      "Async використовує більше RAM",
      "Bukkit API не підтримує async"
    ],
    "correctAnswer": 1,
    "explanation": "Async save створює race condition: player може modify inventory між моментом коли async task started та коли він executes. Це може призвести до save old state + player має new items = dupe. Solution: synchronous atomic saves або proper locking."
  },
  {
    "question": "Що таке inventory transaction locking і навіщо він потрібен?",
    "options": [
      "Encryption inventory data",
      "Блокування inventory modifications під час critical operations (save, trade) для prevent race conditions",
      "Password на inventory",
      "Anti-theft система"
    ],
    "correctAnswer": 1,
    "explanation": "Inventory locking: під час critical операцій (save, transfer, trade) встановлюється lock, що блокує інші modifications. Це запобігає race conditions де два concurrent operations можуть створити inconsistent state і dupe items."
  },
  {
    "question": "Як minion dupe exploit використовував race condition?",
    "options": [
      "Minion spawn багато разів",
      "Player ламав minion exact moment async collection завершувалась, item добавлявся в inventory + minion drop",
      "Minion teleportувався",
      "Minion мав infinite durability"
    ],
    "correctAnswer": 1,
    "explanation": "Race condition: async task добавляв item в minion storage, але player breakнув minion до завершення check. Result: item added to player inventory (від collection) + minion dropped with items inside. Fix: synchronous atomic operations with proper state checks."
  },
  {
    "question": "Чому важливо validate packet slot numbers?",
    "options": [
      "Для statystyki",
      "Modified clients можуть send negative/invalid slots, server bug може duplicate items через incorrect slot handling",
      "Slot numbers не мають значення",
      "Для performance optimization"
    ],
    "correctAnswer": 1,
    "explanation": "Modified clients можуть відправляти packets з invalid slots (negative, >inventory size). Якщо server не validates, це може trigger bugs в inventory handling code що дублюють items або crashять server. Always validate: 0 <= slot < inventory.size()."
  },
  {
    "question": "Що таке economy monitoring та як він виявляє dupes?",
    "options": [
      "Перевірка балансу гравців",
      "Tracking item creation/destruction rates, алерт на unusual spikes (напр. 1000+ diamonds за 5 хв)",
      "Counting money transactions",
      "Player wealth leaderboard"
    ],
    "correctAnswer": 1,
    "explanation": "Economy monitoring: track скільки items (особливо valuable: diamonds, netherite) створюється per time period. Normal rate: ~50-100 diamonds/hour. Dupe: 1000+ за 5 хвилин = clear anomaly. Alert staff для investigation before economy destroyed."
  },
  {
    "question": "Чому chunk border operations ризиковані для dupes?",
    "options": [
      "Chunk borders лагають",
      "Chunk save/load може create desync: entity saved в chunk але player inventory також має items, logout timing critical",
      "Chunk borders заборонені",
      "Нічого ризикового"
    ],
    "correctAnswer": 1,
    "explanation": "Chunk border exploits: entity (donkey, minion) на chunk boundary, player logout exact moment chunk unloads. Chunk saves entity state, але player inventory не properly cleared. Relog: items в обох місцях. Prevention: atomic chunk transactions + proper state sync."
  },
  {
    "question": "Що означає atomic transaction в контексті inventory operations?",
    "options": [
      "Швидка операція",
      "Operation виконується повністю або не виконується взагалі, no partial states, prevent inconsistencies",
      "Операція з atoms",
      "Database transaction"
    ],
    "correctAnswer": 1,
    "explanation": "Atomic transaction: operation або succeeds повністю або fails повністю, немає partial/intermediate states. Для inventory: transfer items = remove from source AND add to destination atomically. Якщо fails mid-operation, rollback to original state. Prevents dupes від partial transfers."
  },
  {
    "question": "Як використати synchronized blocks для prevent race conditions?",
    "options": [
      "Для time synchronization",
      "synchronized(object) блокує concurrent access до critical section, only one thread executes at time",
      "Synchronized не працює в Minecraft",
      "Для network sync"
    ],
    "correctAnswer": 1,
    "explanation": "synchronized block: гарантує що тільки один thread може execute code block одночасно. Для inventory: synchronized(player.getInventory()) під час save/modify operations запобігає concurrent modifications що можуть create race conditions і dupes."
  },
  {
    "question": "Чому client-server inventory desync небезпечний?",
    "options": [
      "Lag збільшується",
      "Якщо client має outdated inventory state, operations based на client data можуть duplicate items через incorrect assumptions",
      "Desync не впливає на dupes",
      "Client завжди синхронізований"
    ],
    "correctAnswer": 1,
    "explanation": "Inventory desync: client думає має item A, server knows має item B. Якщо server processes client request based на client state without validation, може duplicate items. Solution: server authoritative, always validate client requests against server state, re-sync client на mismatch."
  },
  {
    "question": "Що робить inventory freeze під час investigation?",
    "options": [
      "Delete inventory",
      "Блокує всі inventory modifications (can''t move/drop items) для preserve evidence під час dupe investigation",
      "Kickає гравця",
      "Backup inventory"
    ],
    "correctAnswer": 1,
    "explanation": "Inventory freeze: коли dupe suspected, lock inventory to prevent player від hiding evidence (dropping items, transferring to alts). Player can play але не може modify inventory. Allows staff investigation без destruction evidence. Unfreeze після conclusion."
  },
  {
    "question": "Чому важливо log всі item creation/destruction events?",
    "options": [
      "Для статистики сервера",
      "Logs дозволяють trace item origin, виявити dupe source, roll back exact duplicated items, prove exploit usage",
      "Database practice",
      "Performance monitoring"
    ],
    "correctAnswer": 1,
    "explanation": "Comprehensive logging: кожен item spawn logged з source (mining, crafting, mob drop, admin give, etc). При dupe investigation, можна trace 5000 diamonds до specific events, identify exploit method, roll back тільки duped items, preserve legitimate items. Critical для fair resolution."
  },
  {
    "question": "Як rate limiting packet processing запобігає exploits?",
    "options": [
      "Зменшує lag",
      "Обмежує packets per second per player, exploit що spam packets (item use, window click) blocked після threshold",
      "Rate limiting не потрібен",
      "Для bandwidth saving"
    ],
    "correctAnswer": 1,
    "explanation": "Багато exploits spam packets (1000s UseItemPacket/sec, rapid ClickWindowPacket). Rate limiting: max 20 critical packets per second per player. Legitimate player: ~5-10/sec. Exploit: blocked after threshold, prevents server processing malicious floods that create dupes."
  },
  {
    "question": "Що таке rollback recovery та коли його використовувати?",
    "options": [
      "Server restart",
      "Restore server state з backup до моменту before exploit discovered, видаляє duped items але loses legitimate progress",
      "Plugin update",
      "Player ban"
    ],
    "correctAnswer": 1,
    "explanation": "Rollback: restore з backup (6 hours ago) коли dupe caused massive economy damage. Trade-off: видаляє duped items але legitimate players lose progress (last 6 hours play). Use тільки для critical exploits де economy destroyed. Communicate transparently, compensate affected players."
  },
  {
    "question": "Чому важливо test з modified clients під час development?",
    "options": [
      "Для fun",
      "Modified clients можуть send packets що vanilla client can''t, виявляє validation bugs before exploiters find them",
      "Modified clients заборонені",
      "Testing не потрібен"
    ],
    "correctAnswer": 1,
    "explanation": "Penetration testing: use modified clients (protocol manipulation tools) під час development для test edge cases: negative slots, oversized packets, rapid spam, invalid item data. Виявити validation bugs in controlled environment before release. Fix before exploiters discover in production."
  }
]',
    600,
    10,
    false
  );

  RAISE NOTICE 'Module 5, Lesson 10 (Quiz) created!';
END $$;
