-- =====================================================
-- МОДУЛЬ 6, УРОК 12: Quiz - VPN/Alt Detection
-- =====================================================

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 6;
  
  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 12;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Quiz: VPN/Alt Detection',
    'quiz',
    '[
  {
    "question": "Чому VPN detection важливий для ban enforcement?",
    "options": [
      "VPN споживає bandwidth",
      "Banned players використовують VPN + alt accounts для bypass IP bans, without detection bans неефективні",
      "VPN незаконний",
      "VPN не впливає на bans"
    ],
    "correctAnswer": 1,
    "explanation": "Permanent bans базуються на IP. Player купує alt account ($5-10) + connects через VPN = different IP = bypass ban. Без VPN detection, same cheater повертається 10+ разів, making moderation неефективною."
  },
  {
    "question": "Яка різниця між IPHub та VPNBlocker APIs?",
    "options": [
      "Немає різниці",
      "IPHub дешевший (free tier 1K/day) але 85-90% accuracy, VPNBlocker дорожчий ($10/month) але 90-93% accuracy + risk score",
      "IPHub не працює",
      "VPNBlocker тільки для Tor"
    ],
    "correctAnswer": 1,
    "explanation": "IPHub: free 1,000 requests/day, 85-90% accuracy, fast (<100ms). VPNBlocker: $10/month для 10K/day, 90-93% accuracy, risk score 0-100, slower (150-200ms). Trade-off: cost vs accuracy."
  },
  {
    "question": "Що означає block=1 в IPHub API response?",
    "options": [
      "IP заблокований сервером",
      "IP detected as VPN/proxy (block=0 residential, block=1 VPN/proxy, block=2 datacenter)",
      "API error",
      "Player banned"
    ],
    "correctAnswer": 1,
    "explanation": "IPHub block field: 0 = residential IP (normal), 1 = VPN/proxy/hosting (suspicious), 2 = datacenter (cloud servers). Block=1 означає IP likely VPN, should investigate або kick."
  },
  {
    "question": "Чому important implementувати IP caching для VPN checks?",
    "options": [
      "Для security",
      "Кожен API call коштує money/quota, caching reduces API calls (same IP checked once per hour), saves costs",
      "Caching не потрібен",
      "Для швидкості гри"
    ],
    "correctAnswer": 1,
    "explanation": "Without caching: player reconnects 10 times = 10 API calls. With caching (1 hour): first check uses API, next 9 use cache = 1 API call. Saves 90% requests, reduces costs та API rate limits."
  },
  {
    "question": "Що таке false positive в VPN detection і приклади?",
    "options": [
      "VPN не detected",
      "Legitimate user flagged як VPN: mobile networks (4G/5G), university networks, corporate VPNs часто false flagged",
      "API error",
      "Player використовує cheat"
    ],
    "correctAnswer": 1,
    "explanation": "False positive: API каже VPN але насправді legitimate. Common: mobile ISPs (shared IPs flagged як datacenter), universities (large IP pools), corporate VPNs (legitimate business use). Need whitelist + manual review."
  },
  {
    "question": "Чому AsyncPlayerPreLoginEvent використовується для VPN checks?",
    "options": [
      "Для async operations",
      "Fires BEFORE player joins, can block connection without player seeing server, API call doesn''t block main thread",
      "AsyncPlayerPreLoginEvent не потрібен",
      "Для performance"
    ],
    "correctAnswer": 1,
    "explanation": "AsyncPlayerPreLoginEvent: fires before player loads world, runs async (non-blocking main thread), can disallow connection cleanly. Perfect для VPN check: slow API call (200ms) doesn''t lag server, player rejected before entering."
  },
  {
    "question": "Що таке risk score в VPNBlocker API і як його використовувати?",
    "options": [
      "Player skill level",
      "0-100 value indicating VPN probability: >90 = definitely VPN, 50-90 = suspicious, <50 = likely legitimate",
      "Server risk metric",
      "API performance"
    ],
    "correctAnswer": 1,
    "explanation": "Risk score: machine learning confidence 0-100. >90 = high confidence VPN (kick), 70-90 = suspicious (alert staff), <70 = uncertain (allow but log). Allows nuanced decisions vs binary VPN/not VPN."
  },
  {
    "question": "Чому важливо мати whitelist для VPN detection?",
    "options": [
      "Для bypass security",
      "Handle false positives: whitelist known legitimate IPs/players (staff, YouTubers, corporate users) to prevent incorrect kicks",
      "Whitelist не потрібен",
      "Для admin powers"
    ],
    "correctAnswer": 1,
    "explanation": "Whitelist critical для user experience: staff може use corporate VPN for security, YouTubers travel (mobile networks), universities часто false flagged. Whitelist allows legitimate exceptions while blocking actual ban evaders."
  },
  {
    "question": "Як database logging допомагає з VPN detection?",
    "options": [
      "Database не потрібна",
      "Log всі VPN attempts: track patterns (same player trying multiple IPs), identify serial ban evaders, evidence для appeals",
      "Logging тільки для errors",
      "Database тільки для player data"
    ],
    "correctAnswer": 1,
    "explanation": "VPN logs показують patterns: player BannedUser tried connections з 15 різних IPs за тиждень = clear ban evasion. Logs також serve як evidence during appeals, show false positive rate для tuning."
  },
  {
    "question": "Чому GetIPIntel free але не recommended для busy servers?",
    "options": [
      "GetIPIntel не працює",
      "Rate limits: 500/day, 15/minute дуже низькі, також slow response (300-500ms), busy server exceeds limits",
      "GetIPIntel paid only",
      "API deprecated"
    ],
    "correctAnswer": 1,
    "explanation": "GetIPIntel free але: 500 requests/day limit (busy server hits за 2-3 hours), 15/minute (25 players join = limit hit), slow 300-500ms response. Good для testing або small servers (<50 players), not production scale."
  },
  {
    "question": "Що робити якщо VPN API down або returns error?",
    "options": [
      "Block всіх players",
      "Allow connection (fail-open), log error, alert staff - don''t prevent all joins через API downtime",
      "Kick player",
      "Restart server"
    ],
    "correctAnswer": 1,
    "explanation": "Fail-open principle: якщо API unavailable, allow connection але log incident. Blocking all players через API issue = bad UX, legitimate players can''t join. Monitor errors, switch backup API якщо persistent failures."
  },
  {
    "question": "Як cost-effective використовувати VPN APIs для 500 player server?",
    "options": [
      "Paid API завжди",
      "Start IPHub free (1K/day sufficient для ~200 new connections/day), upgrade to paid тільки якщо exceeding limits",
      "Не використовувати APIs",
      "Multiple paid APIs"
    ],
    "correctAnswer": 1,
    "explanation": "500 average players = ~200 new connections/day (with caching). IPHub free tier 1,000/day = 5x headroom, sufficient. Monitor usage, upgrade до $5/month Basic tier тільки якщо growing past 800 connections/day. Cost-effective scaling."
  },
  {
    "question": "Чому mobile networks (4G/5G) often flagged як VPN?",
    "options": [
      "Mobile networks є VPN",
      "Mobile ISPs use CGNAT (carrier-grade NAT), shared IPs з datacenter characteristics, APIs detect as proxy/hosting",
      "Mobile завжди suspicious",
      "API bug"
    ],
    "correctAnswer": 1,
    "explanation": "Mobile ISPs: thousands users share IP pools, CGNAT infrastructure looks like datacenter (many IPs, shared resources), APIs flag as hosting/proxy. Technical false positive, need whitelist або lower threshold для mobile ASNs."
  },
  {
    "question": "Що таке bypass permission і коли його використовувати?",
    "options": [
      "Admin tool для cheating",
      "Permission (vpnblock.bypass) allows specific players to connect через VPN: staff, content creators, legitimate remote workers",
      "Bypass не потрібен",
      "For all players"
    ],
    "correctAnswer": 1,
    "explanation": "Bypass permission: grant to trusted users with legitimate VPN needs. Staff working remotely, YouTubers traveling, players з ISP false positives. Alternative до IP whitelist, easier management through permission system."
  },
  {
    "question": "Як handling VPN detection відрізняється від anti-cheat detection?",
    "options": [
      "Не відрізняється",
      "VPN: check at login (PreLoginEvent), binary decision (allow/deny), external API. Anti-cheat: continuous monitoring, violation levels, internal checks",
      "VPN detection = anti-cheat",
      "VPN не потребує checks"
    ],
    "correctAnswer": 1,
    "explanation": "VPN detection: one-time check at connection, uses external API (IPHub etc), simple allow/deny. Anti-cheat: continuous runtime monitoring, complex violation system, internal algorithm, gradual punishment. Different purposes, different implementations."
  }
]',
    600,
    12,
    false
  );

  RAISE NOTICE 'Module 6, Lesson 12 (Quiz) created!';
END $$;
