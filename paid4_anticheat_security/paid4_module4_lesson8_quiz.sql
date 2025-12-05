-- =====================================================
-- МОДУЛЬ 4, УРОК 8: Quiz - DDoS Protection
-- =====================================================
-- Курс: paid-4 (Advanced Anti-Cheat та Security Systems)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 4;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 8;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Quiz: DDoS Protection',
    'quiz',
    '[
  {
    "question": "Як працює SYN flood атака на TCP рівні?",
    "options": [
      "Відправка великої кількості UDP пакетів",
      "Відправка SYN packets з підробленими IP, сервер чекає ACK response, connection queue заповнюється",
      "Відправка HTTP requests без завершення",
      "Підключення багатьох legitimate клієнтів"
    ],
    "correctAnswer": 1,
    "explanation": "SYN flood експлуатує TCP three-way handshake: атакер відправляє SYN з фейковим IP, сервер відповідає SYN-ACK і чекає ACK, але ACK ніколи не приходить. Connection queue заповнюється half-open connections, блокуючи legitimate з''єднання."
  },
  {
    "question": "Чому Layer 7 DDoS атаки складніше фільтрувати ніж Layer 4?",
    "options": [
      "Layer 7 атаки швидші",
      "Layer 7 атаки використовують legitimate protocol (Minecraft handshake, chunk requests), виглядають як real players",
      "Layer 7 не можна заблокувати",
      "Layer 4 атаки не існують"
    ],
    "correctAnswer": 1,
    "explanation": "Layer 4 атаки (SYN flood) легко виявити через packet patterns. Layer 7 атаки використовують legitimate Minecraft protocol - правильні handshake, login packets. Відрізнити від real player складно, потрібен behavioral analysis."
  },
  {
    "question": "Що таке Proxy Protocol і навіщо TCPShield його використовує?",
    "options": [
      "Протокол для VPN",
      "Метод передачі real player IP від proxy до backend server, інакше server бачить тільки TCPShield IP",
      "Encryption protocol",
      "Anti-cheat detection method"
    ],
    "correctAnswer": 1,
    "explanation": "Коли player підключається через TCPShield, backend server бачить connection з TCPShield IP, не player IP. Proxy Protocol v2 передає original IP в спеціальному header, дозволяючи anti-cheat та IP bans працювати коректно."
  },
  {
    "question": "Чому КРИТИЧНО важливо налаштувати firewall після setup TCPShield?",
    "options": [
      "Для швидшої роботи сервера",
      "Без firewall, атакер може знайти backend IP і атакувати напряму, обходячи TCPShield protection",
      "TCPShield вимагає firewall",
      "Firewall не потрібен"
    ],
    "correctAnswer": 1,
    "explanation": "TCPShield захищає тільки якщо весь traffic йде через їх network. Якщо атакер знайде backend IP (через DNS history, server leaks), він може атакувати напряму. Firewall правила (allow only TCPShield IPs) запобігають bypass."
  },
  {
    "question": "Як handshake flood атака експлуатує Minecraft protocol?",
    "options": [
      "Відправка неправильних packets",
      "Відправка тисяч handshake packets, але не completing login, server holds connections і slots exhausted",
      "Spam chat messages",
      "Crash server через exploits"
    ],
    "correctAnswer": 1,
    "explanation": "Handshake flood: бот відправляє Minecraft handshake packet (connection request), server приймає і чекає login packet, але бот не завершує login. Server holds connection, займаючи slot. При 10K таких connections, legitimate players не можуть зайти."
  },
  {
    "question": "Що робить iptables правило: iptables -A INPUT -p tcp --dport 25565 -s 141.98.233.0/24 -j ACCEPT?",
    "options": [
      "Блокує всі підключення до порту 25565",
      "Дозволяє підключення до порту 25565 ТІЛЬКИ з IP range 141.98.233.0/24 (TCPShield network)",
      "Відкриває порт 25565 для всіх",
      "Redirect traffic на інший порт"
    ],
    "correctAnswer": 1,
    "explanation": "Це whitelist правило: дозволяє TCP connections на порт 25565 тільки з TCPShield IP subnet. В комбінації з DROP rule для інших IPs, це забезпечує що тільки TCPShield може підключитися до backend server."
  },
  {
    "question": "Чому UDP flood attacks легші для атакера ніж TCP SYN flood?",
    "options": [
      "UDP швидший протокол",
      "UDP connectionless протокол (no handshake), не потрібно підтримувати connection state, можна спуфити IP легко",
      "UDP не захищений",
      "TCP сильніший за UDP"
    ],
    "correctAnswer": 1,
    "explanation": "UDP не має connection handshake як TCP. Атакер може відправити UDP packet з підробленим source IP без встановлення connection. TCP SYN flood requires tracking connection state, UDP просто flood packets. Minecraft query protocol (UDP) особливо вразливий."
  },
  {
    "question": "Що таке Shield Score в TCPShield?",
    "options": [
      "Рейтинг сервера",
      "Threat detection metric: аналізує connections/sec, packets/connection, GeoIP distribution для виявлення attacks",
      "Performance score",
      "Player count"
    ],
    "correctAnswer": 1,
    "explanation": "Shield Score - це TCPShield threat detection система. Аналізує patterns: скільки connections per second, скільки packets per connection, geographic distribution. При підозрілих patterns (напр. 2000 conn/sec з одного ASN) - auto-mitigation."
  },
  {
    "question": "Чому важливо disable query protocol (enable-query=false) в server.properties?",
    "options": [
      "Query не потрібен для гри",
      "Query protocol (UDP 25565) відповідає на кожен request з MOTD/player count, легко експлуатується для UDP flood без rate limiting",
      "Query споживає багато RAM",
      "Query конфліктує з TCPShield"
    ],
    "correctAnswer": 1,
    "explanation": "Query protocol відповідає на UDP requests з server info (MOTD, player list). Немає built-in rate limiting, сервер відповідає на кожен packet. Атакер може flood UDP queries, exhaust CPU/bandwidth. Disable query видаляє цей attack vector."
  },
  {
    "question": "Яка головна різниця між TCPShield Free та Premium для persistent DDoS attacks?",
    "options": [
      "Premium швидший",
      "Premium має advanced filtering algorithms, custom firewall rules, higher mitigation capacity - critical для persistent multi-vector attacks",
      "Free version не працює",
      "Premium дає більше bandwidth"
    ],
    "correctAnswer": 1,
    "explanation": "Free tier: basic Layer 3/4 filtering, good для occasional attacks. Premium ($30/month): advanced behavioral analysis, custom rules, higher mitigation capacity (100+ Gbps). Persistent sophisticated attacks (Case Study: 40 Gbps 2 weeks) потребують Premium для effective blocking."
  },
  {
    "question": "Як chunk request spam атака працює на Layer 7?",
    "options": [
      "Spam chat з довгими messages",
      "Бот rapidly teleports, сервер генерує/sends тисячі chunks per second, CPU/RAM exhaustion",
      "Відправка broken packets",
      "DDoS web панелі"
    ],
    "correctAnswer": 1,
    "explanation": "Legitimate player: заходить, отримує ~16 chunks. Chunk spam bot: постійно teleports (sends position packets), кожен teleport triggers chunk generation/send. Server може генерувати 1000+ chunks/sec, exhausting CPU/RAM, causing lag для all players."
  },
  {
    "question": "Що таке Anycast network і як TCPShield його використовує?",
    "options": [
      "VPN service",
      "Один IP address advertised з багатьох locations, traffic routes до nearest PoP, distributed DDoS mitigation",
      "Load balancer",
      "DNS service"
    ],
    "correctAnswer": 1,
    "explanation": "Anycast: одна IP адреса advertised з TCPShield PoPs worldwide (LA, London, Singapore, Frankfurt). Player traffic routes до nearest location автоматично. Attack traffic розподіляється по всіх PoPs, а не б''є один datacenter, distributed mitigation."
  },
  {
    "question": "Чому GeoIP filtering може бути ефективним проти botnets?",
    "options": [
      "Botnets завжди з однієї країни",
      "Багато botnets concentrated в певних країнах (CN, RU), якщо немає legitimate players звідти - можна блокувати",
      "GeoIP filtering завжди працює",
      "VPN не можна обійти GeoIP"
    ],
    "correctAnswer": 1,
    "explanation": "Statistically, багато botnet nodes в China, Russia через large populations + many compromised devices. Якщо ваш server Ukrainian з 0 Chinese players, блокування CN може cut 40-60% bot traffic. Але: блокує і VPN users, і може block legitimate players."
  },
  {
    "question": "Як rate limiting SSH (iptables rule з --limit) запобігає brute force attacks?",
    "options": [
      "Закриває SSH port",
      "Обмежує NEW SSH connections до X per minute, блокує IPs що exceed limit, preventing password brute force",
      "Encrypt SSH traffic",
      "SSH не можна rate limit"
    ],
    "correctAnswer": 1,
    "explanation": "SSH brute force: атакер пробує 1000s passwords. Rate limiting rule: allow 4 new connections per 60 sec from IP, DROP більше. Legitimate admin: 1-2 connections. Brute force: blocked after 4 attempts, must wait 60 sec, making attack impractical."
  },
  {
    "question": "Чому backend IP має залишатися secret навіть після setup TCPShield?",
    "options": [
      "Для security через obscurity",
      "Якщо атакер знає backend IP, він може атакувати напряму, bypassing TCPShield, якщо firewall misconfigured або leaked",
      "TCPShield не працює з public IP",
      "Backend IP не має значення"
    ],
    "correctAnswer": 1,
    "explanation": "TCPShield effective тільки якщо весь traffic йде через нього. Backend IP leak (DNS history, server scan, social engineering) дозволяє атакеру bypass TCPShield. Навіть з firewall, leak IP = constant attack attempts. Keep secret = less attack vectors."
  }
]',
    600,
    8,
    false
  );

  RAISE NOTICE 'Module 4, Lesson 8 (Quiz) created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-4' AND m.order_index = 4
ORDER BY l.order_index;
