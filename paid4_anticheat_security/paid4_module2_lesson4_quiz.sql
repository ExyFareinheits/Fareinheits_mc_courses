-- =====================================================
-- МОДУЛЬ 2, УРОК 4: Quiz - Розуміння Чітів
-- =====================================================
-- Курс: paid-4 (Advanced Anti-Cheat та Security Systems)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 2;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 4;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Quiz: Розуміння Чітів та Detection',
    'quiz',
    '[
  {
    "question": "Чому kernel-mode чіти складно виявити server-side anti-cheat системами?",
    "options": [
      "Kernel-mode чіти використовують шифрування",
      "Server-side AC працює в Ring 3, kernel чіти - в Ring 0, Ring 3 не бачить Ring 0 операції",
      "Kernel-mode чіти занадто швидкі для detection",
      "Server-side AC не має доступу до мережі"
    ],
    "correctAnswer": 1,
    "explanation": "Windows Ring Architecture розділяє привілеї: Ring 0 (kernel) має повний доступ до системи, Ring 3 (user-mode) - обмежений. Server-side anti-cheat працює в Ring 3 і не може моніторити операції в Ring 0, де працюють kernel-mode чіти."
  },
  {
    "question": "Яка основна різниця між user-mode та kernel-mode читами в контексті memory access?",
    "options": [
      "User-mode використовує ReadProcessMemory (детектується), kernel-mode - MmCopyVirtualMemory (не детектується)",
      "User-mode швидший за kernel-mode",
      "Kernel-mode потребує інтернет з''єднання",
      "User-mode працює тільки на Windows 10"
    ],
    "correctAnswer": 0,
    "explanation": "User-mode чіти використовують Windows API функції типу ReadProcessMemory, які можуть бути відслідковані. Kernel-mode чіти використовують kernel API (MmCopyVirtualMemory), які працюють нижче рівня user-mode detection."
  },
  {
    "question": "Що таке DMA (Direct Memory Access) чіт та чому його практично неможливо виявити?",
    "options": [
      "DMA - це software чіт з encryption",
      "DMA - hardware пристрій (PCIe card), що читає RAM напряму в обхід OS, працює нижче kernel рівня",
      "DMA - це kernel driver з особливим підписом",
      "DMA - модифікація клієнта Minecraft"
    ],
    "correctAnswer": 1,
    "explanation": "DMA чіти - це hardware пристрої (PCIe карти), що вставляються в комп''ютер і мають прямий доступ до RAM на hardware рівні, повністю в обхід операційної системи. Software anti-cheat не може їх виявити, бо вони працюють нижче рівня OS."
  },
  {
    "question": "Як kernel-mode чіти обходять Driver Signature Enforcement в Windows?",
    "options": [
      "Використовують підпис Microsoft",
      "Експлуатують вразливі легальні драйвери (vulnerable driver exploit) для завантаження непідписаного cheat driver",
      "Вимикають Windows Defender",
      "Використовують VPN"
    ],
    "correctAnswer": 1,
    "explanation": "Kernel-mode чіти використовують vulnerable driver exploit: спочатку завантажують легальний драйвер з вразливістю (наприклад, capcom.sys), потім експлуатують CVE для виконання kernel code, який завантажує cheat driver, обходячи Driver Signature Enforcement."
  },
  {
    "question": "Яка типова detection rate для kernel-mode чітів згідно тестів 2025?",
    "options": [
      "70-90% (високий рівень detection)",
      "50-60% (середній рівень)",
      "8-30% (дуже низький рівень)",
      "0% (повністю невидимі)"
    ],
    "correctAnswer": 2,
    "explanation": "За даними тестів 2025, kernel-mode чіти типу Entropy мають detection rate 8-30%. Це набагато нижче за user-mode чіти (70-90%), але не 0%, бо деякі behavioral patterns все одно можуть бути виявлені через packet analysis."
  },
  {
    "question": "Чому AI-assisted чіти складно виявити через behavioral analysis?",
    "options": [
      "AI чіти використовують kernel drivers",
      "AI моделі натреновані імітувати human-like рухи з realistic delays, miss rate та fatigue simulation",
      "AI чіти працюють через VPN",
      "AI чіти не відправляють packets"
    ],
    "correctAnswer": 1,
    "explanation": "AI-assisted чіти використовують machine learning моделі, натреновані на тисячах годин реальної людської гри. Вони імітують human-like aim smoothness, realistic reaction time (150-250ms), включають miss rate (5-10%) та навіть симулюють втому. Це робить їх схожими на легітимних гравців."
  },
  {
    "question": "Яка правильна послідовність пакетів для legitimate атаки гравця?",
    "options": [
      "ATTACK → MOVEMENT → LOOK",
      "LOOK → MOVEMENT → SWING_ARM → ATTACK",
      "SWING_ARM → ATTACK → LOOK",
      "MOVEMENT → ATTACK → LOOK → SWING_ARM"
    ],
    "correctAnswer": 1,
    "explanation": "Legitimate гравець спочатку дивиться на ціль (LOOK), рухається до неї (MOVEMENT), махає рукою (SWING_ARM), потім атакує (ATTACK). Smart чіти відтворюють цю послідовність для bypass packet analysis, тоді як naive чіти можуть відправляти packets в неправильному порядку."
  },
  {
    "question": "Що таке vulnerable driver exploit в контексті kernel-mode чітів?",
    "options": [
      "Hack Windows Update сервера",
      "Використання легального драйвера з CVE для завантаження cheat driver через kernel code execution",
      "Модифікація BIOS",
      "Exploit мережевого драйвера для DDoS"
    ],
    "correctAnswer": 1,
    "explanation": "Vulnerable driver exploit - це техніка, де використовується легальний підписаний драйвер з відомою вразливістю (CVE). Через цю вразливість виконується kernel code, який завантажує cheat driver, обходячи Driver Signature Enforcement."
  },
  {
    "question": "Чому DMA чіти маскуються під network card або GPU?",
    "options": [
      "Для кращої швидкості читання memory",
      "Щоб bypass PCIe device detection, виглядаючи як легітимний пристрій",
      "Для підключення до інтернету",
      "Для рендерингу графіки"
    ],
    "correctAnswer": 1,
    "explanation": "DMA hardware маскується під звичайні PCIe пристрої (Realtek Network Card, GPU), щоб не викликати підозр при перевірці списку PCIe devices. Деякі anti-cheat системи можуть перевіряти підключені hardware, тому DMA cards імітують легітимні пристрої."
  },
  {
    "question": "Яка типова ціна kernel-mode чіту типу Entropy в 2025?",
    "options": [
      "$10-20 одноразово",
      "$50-80 на місяць",
      "$200-500 на місяць",
      "$5000+ lifetime"
    ],
    "correctAnswer": 2,
    "explanation": "Kernel-mode чіти типу Entropy коштують $200-500 на місяць через складність розробки, необхідність постійних оновлень, підтримку vulnerable driver exploits та низький detection rate (8-12%). Це дорожче user-mode чітів ($0-150) але дешевше DMA hardware ($500-2000)."
  },
  {
    "question": "Що НЕ може виявити server-side anti-cheat?",
    "options": [
      "Impossible actions (fly, speed >max)",
      "Statistical anomalies (100% hit rate)",
      "Kernel-mode memory reads та DMA hardware access",
      "Wrong packet order"
    ],
    "correctAnswer": 2,
    "explanation": "Server-side AC може виявляти user-mode маніпуляції, impossible actions, statistical anomalies та packet inconsistencies. Але kernel-mode операції (Ring 0) та DMA hardware access (нижче OS) залишаються невидимими для server-side detection."
  },
  {
    "question": "Як smart Killaura чіти обходять behavioral detection через randomization?",
    "options": [
      "Використовують VPN для зміни IP",
      "Додають random delay (80-120ms), miss chance (8%), aim error (-0.5 to 0.5) для імітації human behavior",
      "Шифрують network packets",
      "Змінюють username кожні 5 хвилин"
    ],
    "correctAnswer": 1,
    "explanation": "Smart Killaura чіти використовують randomization для bypass behavioral analysis: додають випадкову затримку між атаками (80-120ms замість кожного tick), включають miss chance (8%), додають aim error. Це робить їх схожими на людську гру з реалістичними неточностями."
  },
  {
    "question": "Що означає MmCopyVirtualMemory в контексті kernel-mode чітів?",
    "options": [
      "User-mode API для копіювання файлів",
      "Kernel API функція для прямого копіювання memory між процесами на kernel рівні",
      "Network protocol для передачі даних",
      "Minecraft game engine функція"
    ],
    "correctAnswer": 1,
    "explanation": "MmCopyVirtualMemory - це Windows kernel API функція, що дозволяє копіювати memory між процесами напряму на kernel рівні (Ring 0). Kernel-mode чіти використовують її для читання Minecraft process memory в обхід user-mode detection."
  },
  {
    "question": "Яка detection rate у best server-side AC (Vulcan, GrimAC) для user-mode чітів?",
    "options": [
      "50-60%",
      "85-92%",
      "95-98%",
      "100%"
    ],
    "correctAnswer": 1,
    "explanation": "Best server-side anti-cheat системи (Vulcan 2.8+, GrimAC 2.3+) досягають 85-92% detection rate для user-mode чітів. Це високий показник для server-side AC, але не 100% через smart bypass techniques. Enterprise client-side AC (Vanguard) досягають 95-98%."
  },
  {
    "question": "Чому 100% detection rate неможливий навіть теоретично?",
    "options": [
      "Anti-cheat системи занадто повільні",
      "Kernel чіти працюють в Ring 0, DMA - нижче OS, AI чіти - занадто realistic, завжди є рівень доступу вище AC",
      "Недостатньо server RAM",
      "Network latency заважає detection"
    ],
    "correctAnswer": 1,
    "explanation": "100% detection неможливий через ієрархію привілеїв: kernel чіти (Ring 0) вище server-side AC (Ring 3), DMA hardware працює нижче OS, AI чіти занадто реалістичні для behavioral analysis. Завжди існує технологія, що працює на рівні вище або нижче anti-cheat."
  }
]',
    600,
    4,
    false
  );

  RAISE NOTICE 'Module 2, Lesson 4 (Quiz) created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-4' AND m.order_index = 2
ORDER BY l.order_index;
