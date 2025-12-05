-- =====================================================
-- МОДУЛЬ 7, УРОК 13: CoreProtect Advanced Usage
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
  
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-4',
      'module-7',
      'Logging та Forensics',
      'CoreProtect advanced, incident response, evidence collection',
      7
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 13;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'CoreProtect Advanced: Forensics та Rollback',
    'text',
    '# CoreProtect Advanced: Forensics та Rollback

CoreProtect - найпотужніший logging plugin для Minecraft. Записує кожну block зміну, container interaction, kill для forensic analysis та rollback.

---

## CoreProtect Capabilities

### Що Логується

```
Block Changes:
- Block place/break (all blocks)
- Block interactions (doors, buttons, levers)
- Liquid flow (water/lava spread)
- Explosions (creeper, TNT, wither)
- Fire spread
- Structure growth (trees, mushrooms)

Container Interactions:
- Chest open/close
- Item add/remove from chests
- Hopper transfers
- Furnace inputs/outputs
- Shulker box operations

Entity Actions:
- Entity kills (PvP, PvE)
- Entity spawns
- Item drops/pickups
- Sheep shearing
- Entity interactions

World Events:
- World edits
- Command executions
- Chat messages
- Sign text changes
- Username changes
```

---

## Installation та Configuration

### Setup Process

```bash
# 1. Download CoreProtect
# https://www.spigotmc.org/resources/coreprotect.8631/

# 2. Install to plugins folder
cp CoreProtect-*.jar server/plugins/

# 3. Restart server (generates config)
# 4. Configure database
```

### config.yml Optimization

```yaml
# CoreProtect Configuration

# MySQL (recommended для production)
use-mysql: true
table-prefix: co_
mysql-host: localhost
mysql-port: 3306
mysql-database: minecraft_logs
mysql-username: coreprotect
mysql-password: strong_password_here

# Performance Settings
max-teleport-distance: 100
lookup-radius: 5

# What to Log
block-place: true
block-break: true
natural-break: true
block-burn: true
block-explode: true
block-spread: true
block-fade: true
block-form: true
bucket: true
hopper-transactions: true
item-transactions: true
entity-kills: true
entity-spawns: false  # High volume, disable unless needed
liquid-tracking: true
chat: true
commands: true
sign-text: true
username-changes: true

# Rollback Settings
rollback-items: true
rollback-entities: true

# Performance Optimization
queue-size: 5000  # Larger = better performance, more RAM
consumer-threads: 2  # Based on CPU cores

# Data Retention
# Automatic purging (recommended)
# Delete data older than 90 days
# /co purge t:90d
```

---

## Basic Commands

### Lookup Commands

```
# Basic lookup at location
/co lookup

# Lookup specific player
/co lookup u:PlayerName

# Lookup time range
/co lookup t:7d  # Last 7 days
/co lookup t:2h  # Last 2 hours
/co lookup t:30m  # Last 30 minutes

# Lookup radius
/co lookup r:10  # 10 blocks radius
/co lookup r:50  # 50 blocks radius

# Lookup specific action
/co lookup a:break  # Only breaks
/co lookup a:place  # Only places
/co lookup a:container  # Container interactions
/co lookup a:kill  # Entity kills
/co lookup a:chat  # Chat messages

# Combined filters
/co lookup u:Griefer t:24h r:100 a:break
# Translation: Show all blocks Griefer broke in last 24h within 100 blocks

# Block type filter
/co lookup b:diamond_ore t:7d
# Show all diamond ore changes last 7 days (x-ray check)

# Multiple users
/co lookup u:Player1,Player2,Player3 t:12h
```

### Rollback Commands

```
# Basic rollback
/co rollback u:Griefer t:24h r:500
# Undo all changes by Griefer in last 24h within 500 blocks

# Rollback with preview
/co rollback u:Griefer t:24h r:500 #preview
# Show what would be rolled back (doesn''t apply)

# Apply after preview
/co apply

# Restore (opposite of rollback)
/co restore u:Player t:1h r:50
# Restore Player''s changes (undo accidental rollback)

# Rollback specific actions
/co rollback u:Griefer t:24h a:break
# Only rollback blocks broken, not placed

# Rollback explosions
/co rollback t:30m r:100 a:explode
# Rollback explosion damage last 30 min

# Rollback fire
/co rollback t:1h r:200 a:burn
# Rollback fire damage

# Global rollback (careful!)
/co rollback u:Griefer t:7d
# Rollback ENTIRE server changes by Griefer last 7 days
```

---

## Advanced Investigation Techniques

### Griefing Investigation Workflow

```
Step 1: Initial Report
Player: "Someone destroyed my house!"
Coordinates: X: 1234, Y: 64, Z: 5678

Step 2: Teleport та Inspect
/tp 1234 64 5678
/co lookup r:20 t:7d

Result:
- PlayerA broke 45 blocks 2 days ago
- PlayerB broke 12 blocks 3 days ago

Step 3: Detailed Analysis
/co lookup u:PlayerA t:7d r:50

Findings:
- PlayerA broke 156 blocks total
- Focused destruction pattern
- Multiple visits (timestamps)

Step 4: Evidence Collection
Take screenshots of:
- /co lookup results
- Block locations
- Timestamps
- Pattern analysis

Step 5: Decision
Ban PlayerA (clear griefing intent)
Rollback: /co rollback u:PlayerA t:7d r:100
```

### X-Ray Detection

```
Suspicious Diamond Mining:

# Check player''s diamond ore breaks
/co lookup u:SuspiciousPlayer b:diamond_ore t:30d

Normal Player Pattern:
- 10-20 diamond ore per hour
- Random Y levels (Y: 5-15)
- Natural cave exploration
- Finds coal/iron в process

X-Ray Player Pattern:
- 50+ diamond ore per hour
- Precise Y:11-12 only
- Direct paths (no exploration)
- Ignores other ores

Evidence Collection:
1. /co lookup u:Player b:diamond_ore t:7d
2. Count ore breaks per hour
3. Check Y coordinates consistency
4. Compare to legitimate players
5. Screenshot results

Ban Criteria:
- >40 diamond ore/hour sustained
- >80% at exact Y:11
- No coal/iron/gold mining
- Straight-line mining patterns
```

### Dupe Exploit Investigation

```
Reported: Economy inflated, suspicious diamonds

Step 1: Check Top Item Gainers
# Manual query або use logs
SELECT player, COUNT(*) as diamond_count
FROM co_container
WHERE action = 1  -- Item added
AND type = 264    -- Diamond item ID
AND time > EXTRACT(EPOCH FROM NOW() - INTERVAL ''7 days'')
GROUP BY player
ORDER BY diamond_count DESC
LIMIT 10;

Step 2: Investigate Top Player
/co lookup u:TopPlayer a:container t:7d

Suspicious Pattern:
- 5,000 diamonds added to chest
- All within 2 hour window
- Same chest repeatedly

Step 3: Trace Origin
/co lookup x:1234 y:64 z:5678 t:7d a:container
# Check chest history

Finding:
- Player places item
- Item duplicates
- Removes duplicated items
- Repeats 500+ times

Evidence: Clear dupe exploit
Action: Ban + rollback duplicated items
```

---

## Database Optimization

### MySQL Queries for Analysis

```sql
-- Top griefers by block breaks (last 30 days)
SELECT "user", COUNT(*) as breaks
FROM co_block
WHERE action = 0 AND time > EXTRACT(EPOCH FROM NOW() - INTERVAL ''30 days'')
GROUP BY "user"
ORDER BY breaks DESC
LIMIT 20;

-- Suspicious diamond mining
SELECT "user", COUNT(*) as diamond_count,
       AVG(y) as avg_y_level
FROM co_block
WHERE type = 56  -- Diamond ore
AND action = 0   -- Break
AND time > EXTRACT(EPOCH FROM NOW() - INTERVAL ''7 days'')
GROUP BY "user"
HAVING COUNT(*) > 100
ORDER BY diamond_count DESC;

-- Container theft analysis
SELECT "user", COUNT(*) as items_taken
FROM co_container
WHERE action = 0  -- Item removed
AND time > EXTRACT(EPOCH FROM NOW() - INTERVAL ''24 hours'')
GROUP BY "user"
ORDER BY items_taken DESC
LIMIT 20;

-- Chat log search (ban evasion, threats)
SELECT "user", message, TO_TIMESTAMP(time) as timestamp
FROM co_chat
WHERE message LIKE ''%banned%''
OR message LIKE ''%admin abuse%''
OR message LIKE ''%appeal%''
ORDER BY time DESC
LIMIT 100;

-- Find all actions by banned player (для rollback)
SELECT COUNT(*) as total_actions,
       SUM(CASE WHEN action = 0 THEN 1 ELSE 0 END) as breaks,
       SUM(CASE WHEN action = 1 THEN 1 ELSE 0 END) as places
FROM co_block
WHERE "user" = ''BannedPlayer''
AND time > EXTRACT(EPOCH FROM NOW() - INTERVAL ''90 days'');
```

### Database Maintenance

```bash
# Purge old data (older than 90 days)
/co purge t:90d

# Database size check (PostgreSQL)
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||''.''||tablename)) AS size
FROM pg_tables
WHERE schemaname = ''public''
ORDER BY pg_total_relation_size(schemaname||''.''||tablename) DESC;

# Optimize tables (monthly)
OPTIMIZE TABLE co_block;
OPTIMIZE TABLE co_container;
OPTIMIZE TABLE co_chat;
OPTIMIZE TABLE co_command;

# Backup before major operations
mysqldump -u coreprotect -p minecraft_logs > coreprotect_backup.sql
```

---

## Real Case Studies

### Case 1: Mass Griefing (2024)

```
Incident: Spawn destroyed overnight
Damage: 5,000+ blocks broken
Time: 02:00 - 04:00 AM

Investigation:
/co lookup r:100 t:12h

Result:
- User: GrieferAlt123
- 5,234 blocks broken
- 2 hour period
- Systematic destruction

Evidence Collection:
1. Screenshot /co lookup results
2. Video recording of damage
3. Chat logs (threats made earlier)

Resolution:
/co rollback u:GrieferAlt123 t:12h r:200
Ban: Permanent (griefing + alt account)
Report to server list (ban share)

Recovery Time: 15 minutes (automatic rollback)
Manual Cleanup: 30 minutes (decorations)
```

### Case 2: Chest Theft Ring (2023)

```
Report: Multiple players reporting stolen items
Pattern: Base invasions at night

Investigation:
/co lookup a:container t:7d

Discovery:
- 3 coordinated players
- Targeting specific bases
- Using invisibility potions
- Stealing valuable items only

Evidence:
SELECT "user", COUNT(*) as thefts
FROM co_container
WHERE action = 0
AND time > EXTRACT(EPOCH FROM NOW() - INTERVAL ''7 days'')
GROUP BY "user"
HAVING COUNT(*) > 100;

Result:
- ThiefA: 234 items stolen
- ThiefB: 189 items stolen
- ThiefC: 156 items stolen

Action:
Ban all 3 accounts
Restore stolen items:
/co restore u:VictimPlayer t:7d a:container

Lesson: Implement chest protection plugin (LWC)
```

---

## Performance Impact

```
Database Size Growth:
- Small server (50 players): ~500 MB/month
- Medium server (200 players): ~2 GB/month
- Large server (1000 players): ~10 GB/month

Performance Impact:
- CPU: Minimal (<5% with 2 consumer threads)
- RAM: 1-2 GB для queue
- Disk I/O: Moderate (MySQL write-heavy)

Optimization Tips:
1. Use MySQL (not SQLite) для >50 players
2. Increase queue-size для reduce disk writes
3. Disable entity-spawns logging
4. Regular purging (90 day retention)
5. Separate database server для large networks
6. SSD storage recommended
```

---

## Висновок

CoreProtect essential для:

**Moderation:**
- Griefing investigation
- Theft tracking
- Evidence collection
- Ban appeals resolution

**Server Management:**
- Rollback griefing damage
- Restore accidental changes
- X-ray detection
- Dupe exploit investigation

**Best Practices:**
- Regular database maintenance
- 90 day retention policy
- MySQL для production
- Staff training on commands
- Document major incidents

Наступний урок покриває incident response playbooks та automated alert systems.',
    5400,
    13,
    false
  );

  RAISE NOTICE 'Module 7, Lesson 13 created!';
END $$;
