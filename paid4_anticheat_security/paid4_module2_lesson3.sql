-- =====================================================
-- МОДУЛЬ 2, УРОК 3: Як працюють чіти 2025 (Technical Deep Dive)
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
  
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-4',
      'module-2',
      'Розуміння Чітів: Від User-mode до Kernel',
      'Технічний розбір як працюють чіти 2025, driver-based exploits, bypass методи',
      2
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 3;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Як працюють чіти 2025: kernel-mode, drivers, DMA',
    'text',
    '# Як Працюють Minecraft Чіти: Technical Deep Dive

## Еволюція Чітів (2015-2025)

```
2015-2018: Client-side модифікації
├── Forge mods (LiquidBounce, Wurst)
├── Виявлення: ModList packets
└── Detection rate: 99%

2018-2020: Ghost Clients (приховані)
├── Vape, Ghost Client, Sigma
├── Виявлення: Behavioral analysis
└── Detection rate: 85-90%

2020-2023: External чіти
├── C++ injectors, memory manipulation
├── Виявлення: Pattern matching
└── Detection rate: 70-80%

2023-2025: Kernel-mode + AI чіти
├── Driver-based (Entropy, Fade)
├── DMA hardware (PCIe cards)
├── ML-assisted movement
└── Detection rate: 10-30% (майже неможливо)
```

---

## Рівні Доступу (Windows Rings)

### Ring Architecture

```
┌─────────────────────────────────────┐
│  Ring 0 (Kernel Mode)               │  ← Найвищий доступ
│  - Windows Kernel                   │
│  - Device Drivers                   │
│  - KERNEL-MODE CHEATS ⚠️            │
├─────────────────────────────────────┤
│  Ring 1-2 (Reserved)                │
│  - Не використовується              │
├─────────────────────────────────────┤
│  Ring 3 (User Mode)                 │  ← Звичайні програми
│  - Minecraft (java.exe)             │
│  - Anti-Cheat plugins               │
│  - USER-MODE CHEATS                 │
└─────────────────────────────────────┘

Проблема:
- Server-side anti-cheat працює в Ring 3
- Kernel-mode чіти працюють в Ring 0
- Ring 0 може ЧИТАТИ і ПИСАТИ Ring 3 пам''ять
- Ring 3 НЕ МОЖЕ виявити Ring 0 активність
```

---

## User-Mode Чіти (2018-2023)

### Принцип Роботи

```cpp
// Приклад: Killaura cheat (simplified)

#include <Windows.h>
#include <jni.h>

// 1. Attach до Minecraft процесу
HANDLE hProcess = OpenProcess(
    PROCESS_ALL_ACCESS, 
    FALSE, 
    minecraft_pid
);

// 2. Знайти адресу EntityList у пам''яті
uintptr_t entityListAddress = findPattern(
    hProcess,
    "48 8B 05 ? ? ? ? 48 8B 48 10"  // signature
);

// 3. Читати entities з пам''яті
struct Entity {
    float x, y, z;
    float health;
    char name[16];
};

Entity* entities = readMemory<Entity*>(
    hProcess, 
    entityListAddress
);

// 4. Знайти найближчого гравця
Entity* target = nullptr;
float minDistance = 6.0f;

for (int i = 0; i < maxEntities; i++) {
    Entity* entity = &entities[i];
    
    float distance = calculateDistance(
        playerPos, 
        {entity->x, entity->y, entity->z}
    );
    
    if (distance < minDistance && entity->health > 0) {
        target = entity;
        minDistance = distance;
    }
}

// 5. Автоматична атака
if (target != nullptr) {
    // Обчислити кут повороту
    float yaw = calculateYaw(playerPos, targetPos);
    float pitch = calculatePitch(playerPos, targetPos);
    
    // Записати rotation у пам''ять
    writeMemory(hProcess, yawAddress, yaw);
    writeMemory(hProcess, pitchAddress, pitch);
    
    // Симулювати ЛКМ
    sendPacket(hProcess, PACKET_ATTACK, target->entityId);
}
```

### Detection Методи (User-Mode)

```
✅ Pattern Matching:
- Сканування signatures чіту
- Перевірка DLL injection (LoadLibrary)

✅ Behavioral Analysis:
- Нереальна точність атаки (>95%)
- Миттєва реакція (<50ms)
- Perfect aim (кут завжди точний)

✅ Packet Analysis:
- Нереальний rotation snap (180° за 1 tick)
- Attack packets без look packets
- Impossible movement patterns

Detection Rate: 70-90% ✅
```

---

## Kernel-Mode Чіти (2023-2025)

### Entropy Cheat (Case Study)

**Ціна:** $200-500/міс  
**Detection Rate:** 8-12% (за даними тестів)  
**Метод:** Kernel driver + HWID spoofer

### Технічна Архітектура

```
1. Kernel Driver (.sys file)
   ↓
2. Завантаження через Vulnerable Driver Exploit
   └── Vulnerable drivers: capcom.sys, DBUtil_2_3.sys
   ↓
3. Driver працює в Ring 0 (kernel space)
   ↓
4. Читає Minecraft process memory БЕЗ detection
   └── Використовує MmCopyVirtualMemory (kernel function)
   ↓
5. Записує rotation/movement packets
   └── Через kernel callbacks (не помічає user-mode AC)
```

### Чому Складно Детектувати?

```cpp
// Звичайний user-mode read (детектується):
ReadProcessMemory(hProcess, address, buffer, size);
// ✅ Anti-cheat бачить: Хтось читає нашу пам''''ять!

// Kernel-mode read (НЕ детектується):
NTSTATUS DriverEntry(PDRIVER_OBJECT DriverObject) {
    // Драйвер працює в kernel space
    
    // Attach до minecraft процесу
    PEPROCESS targetProcess;
    PsLookupProcessByProcessId(minecraft_pid, &targetProcess);
    
    // Читати пам''ять напряму (kernel API)
    SIZE_T bytesRead;
    MmCopyVirtualMemory(
        targetProcess,          // Source process
        entityListAddress,      // Source address
        PsGetCurrentProcess(),  // Our driver
        buffer,                 // Destination
        size,                   // Bytes to read
        KernelMode,             // ⚠️ KERNEL ACCESS
        &bytesRead
    );
    
    // ❌ Anti-cheat НЕ бачить - це kernel operation!
}
```

### Driver Loading (Exploit)

```
Vulnerable Driver Exploit Process:

1. Завантажити легальний vulnerable driver
   └── Приклад: capcom.sys (Capcom rootkit)
   
2. Exploit vulnerability для kernel code execution
   └── CVE-2019-16098 (arbitrary code execution)
   
3. Використати exploit для завантаження CHEAT driver
   └── Обходить Driver Signature Enforcement (DSE)
   
4. Unload vulnerable driver (приховати сліди)

5. Cheat driver працює у Ring 0 (невидимий)

Windows Захист:
- Driver Signature Enforcement ❌ (bypassed)
- PatchGuard ❌ (bypassed через HVCI exploits)
- Secure Boot ❌ (disabled у більшості геймерів)
```

---

## DMA (Direct Memory Access) Чіти

### Що Таке DMA?

```
Hardware-based читінг через PCIe:

                    ┌──────────────┐
                    │   Monitor    │
                    └──────────────┘
                           │
    ┌──────────────────────┴──────────────────────┐
    │          Gaming PC (Minecraft)              │
    │  ┌────────────────────────────────────┐    │
    │  │ RAM (Minecraft process memory)     │    │
    │  └────────────────────────────────────┘    │
    │              ↑ PCIe Bus ↑                   │
    │  ┌────────────────────────────────────┐    │
    │  │ DMA Card (Squirrel/XDMA/Enigma)    │◄───┼─── Ethernet
    │  └────────────────────────────────────┘    │      Cable
    └─────────────────────────────────────────────┘
                                                   │
                         ┌─────────────────────────┘
                         │
                    ┌────┴─────┐
                    │  2nd PC  │  ← Cheat runs here
                    │ (Overlay)│
                    └──────────┘

Як Працює:
1. DMA card вставляється у PCIe slot gaming PC
2. Card має direct access до RAM (hardware level)
3. Читає Minecraft memory БЕЗ OS involvement
4. Відправляє дані на 2nd PC через Ethernet
5. 2nd PC малює overlay (ESP, aim assist)
```

### Чому Неможливо Детектувати?

```
❌ Software anti-cheat НЕ бачить:
- DMA card = hardware device
- Читає RAM напряму (bypass OS)
- Немає process, немає injection
- Немає kernel driver (працює нижче)

❌ Kernel-mode AC НЕ бачить:
- DMA = hardware bus access
- Працює на рівні BIOS/UEFI
- Bypass Windows kernel повністю

✅ Можливе виявлення:
- IOMMU (Intel VT-d / AMD-Vi)
- Перевірка PCIe device list
- Але: DMA cards маскуються під GPU/Network card
```

### Реальні DMA Devices (2025)

```
1. Squirrel DMA ($300-800)
   - Маскується під Realtek Network Card
   - FPGA-based (перепрограмується)
   - Detection rate: <1%

2. XDMA ($500-1200)
   - Military-grade FPGA
   - Маскується під будь-який PCIe device
   - Має built-in HWID spoofer
   - Detection rate: <0.1%

3. Enigma DMA ($1500+)
   - Custom ASIC chip
   - Hardware encryption
   - Неможливо відрізнити від legitного device
   - Detection rate: 0% (теоретично)
```

---

## AI-Assisted Чіти (2024-2025)

### Machine Learning Aim

```python
# Приклад: ML-based aim smoothing

import tensorflow as tf
import numpy as np

class HumanAimModel:
    def __init__(self):
        # Модель натренована на 10,000+ годин human aim
        self.model = tf.keras.models.load_model(''human_aim.h5'')
    
    def predict_movement(self, current_pos, target_pos):
        # Input: current mouse position, target position
        input_data = np.array([
            current_pos[0], current_pos[1],
            target_pos[0], target_pos[1]
        ])
        
        # Model predict: як би людина рухнула мишку
        predicted_path = self.model.predict(input_data)
        
        # Output: smooth curve (не пряма лінія!)
        return predicted_path

# Usage в чіті:
aim_model = HumanAimModel()

while True:
    target = find_nearest_enemy()
    if target:
        current = get_mouse_position()
        
        # AI predict smooth path
        smooth_path = aim_model.predict_movement(
            current, 
            target.head_position
        )
        
        # Move mouse поступово (не snap!)
        for point in smooth_path:
            move_mouse(point)
            sleep(1ms)  # Human-like delay
```

### Чому Складно Детектувати?

```
❌ Не працює Behavioral Analysis:
- Aim smoothness: HUMAN-LIKE ✅
- Reaction time: 150-250ms (realistic) ✅
- Miss rate: 5-10% (built-in!) ✅
- Fatigue simulation: accuracy ↓ after 30min ✅

Detection Methods (theoretical):
- Server-side ML model (аналіз patterns)
- Перевірка consistency (AI TOO consistent)
- Але: AI можна навчити бути inconsistent 😅
```

---

## Bypass Техніки

### 1. Packet Spoofing

```java
// Legitimate player packets:
MOVEMENT → LOOK → ATTACK → SWING_ARM

// Naive cheat (detected):
ATTACK → MOVEMENT → LOOK
// ❌ Wrong order! Anti-cheat flag

// Smart cheat (bypass):
LOOK → MOVEMENT → SWING_ARM → ATTACK
// ✅ Правильний order, виглядає legit
```

### 2. Randomization (bypass behavioral detection)

```cpp
// Naive Killaura:
if (entityInRange && canAttack) {
    attack(entity);  // Кожен tick = obvious
}

// Smart Killaura (bypass):
float attackDelay = randomFloat(80, 120);  // 80-120ms
float missChance = 0.08f;  // 8% miss rate

if (entityInRange && canAttack) {
    if (timeSinceLastAttack > attackDelay) {
        if (random() > missChance) {
            // Додати human-like error
            float aimError = randomFloat(-0.5, 0.5);
            attack(entity, aimError);
        }
        timeSinceLastAttack = 0;
    }
}
```

### 3. Memory Obfuscation

```cpp
// Naive memory read (pattern detected):
float entityX = *(float*)(entityBase + 0x40);

// Obfuscated read (bypass signature scan):
float entityX = decrypt(
    xor_key,
    *(uint32_t*)(entityBase + random_offset())
);
// Signature постійно міняється = неможливо detect
```

---

## Detection Difficulty Chart

```
User-Mode Cheats:
├── Detection Rate: 70-90%
├── Cost: $0-50
└── Skill Required: Low

External Cheats:
├── Detection Rate: 40-60%
├── Cost: $50-150
└── Skill Required: Medium

Kernel-Mode Cheats:
├── Detection Rate: 8-30%
├── Cost: $200-500/month
└── Skill Required: High

DMA Hardware:
├── Detection Rate: <1%
├── Cost: $500-2000
└── Skill Required: Expert

AI-Assisted:
├── Detection Rate: 5-15%
├── Cost: $300-800
└── Skill Required: Expert (ML knowledge)
```

---

## Що Може Server-Side Anti-Cheat?

### Can Detect:

```
1. User-mode memory manipulation
   - Pattern matching
   - DLL injection detection

2. Impossible actions
   - Fly, speed >max
   - Attack через стіни
   - Instant rotation (>180°/tick)

3. Statistical anomalies
   - 100% hit rate
   - Always critical hits
   - Perfect block timing

4. Packet inconsistencies
   - Wrong packet order
   - Impossible coordinates
   - Negative health
```

### Cannot Detect:

```
1. Kernel-mode memory reads
   - Ring 0 operations invisible to Ring 3

2. DMA hardware access
   - Hardware-level = below OS

3. ML-assisted aim
   - Виглядає як human

4. Smart packet manipulation
   - Якщо packets legitimate + realistic

5. External rendering
   - ESP на 2nd monitor (overlay)
```

---

## Висновок

```
Reality Check:

100% detection НЕМОЖЛИВО
- Kernel cheats = Ring 0 privilege
- DMA hardware = below OS
- AI cheats = too realistic

Best server-side AC: 85-92% (user-mode)
- Vulcan, GrimAC - excellent для standard cheats
- Kernel cheats проходять через

Enterprise AC (Vanguard, FaceIT):
- Kernel-mode anti-cheat (runs in Ring 0)
- Can detect kernel cheats
- Cannot detect DMA hardware
- Detection: 95-98%

Для Minecraft серверів:
- Focus на 90% detection (user-mode)
- Kernel cheats = <5% гравців ($200+/міс)
- DMA hardware = <0.5% ($500-2000)
- ROI: не варто боротися з kernel (занадто дорого)
```

---

**Наступний урок:** Detection Patterns + Custom Checks + Quiz',
    6000,
    3,
    false
  );

  RAISE NOTICE 'Module 2, Lesson 3 created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-4' AND m.order_index = 2
ORDER BY l.order_index;
