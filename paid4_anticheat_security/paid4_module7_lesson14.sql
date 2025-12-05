-- =====================================================
-- МОДУЛЬ 7, УРОК 14: Incident Response Playbook
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
  WHERE module_id = v_module_id AND order_index = 14;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Incident Response: Playbooks та Appeals System',
    'text',
    '# Incident Response: Playbooks та Appeals System

Structured incident response critical для handling security events, griefing, exploits, та ban appeals professionally.

---

## Incident Response Framework

### Incident Severity Levels

```
P0 - Critical (Immediate Response)
- Server crash/exploit in progress
- Mass griefing happening now
- Database breach
- DDoS attack active
Response Time: <5 minutes

P1 - High (Urgent)
- Major griefing discovered
- Dupe exploit confirmed
- Multiple player reports
- X-ray evidence strong
Response Time: <1 hour

P2 - Medium (Important)
- Single player griefing
- Suspicious behavior patterns
- Minor exploit attempts
- Staff misconduct reports
Response Time: <24 hours

P3 - Low (Routine)
- Chat violations
- Minor rule breaks
- General complaints
- Appeal reviews
Response Time: <72 hours
```

---

## Griefing Response Playbook

### Step 1: Initial Report

```
Report Received Via:
- /report command (in-game)
- Discord ticket system
- Staff observation
- Automated alert

Information to Collect:
1. Reporter username
2. Incident location (coordinates)
3. Suspected griefer name
4. Approximate time
5. Description of damage
6. Screenshots/video if available

Template Message:
"Thank you for reporting. A staff member will investigate 
this within [timeframe]. Case ID: #12345"
```

### Step 2: Evidence Collection

```bash
# Teleport to location
/tp [x] [y] [z]

# Initial lookup
/co lookup r:50 t:7d

# Document findings
Evidence Checklist:
□ CoreProtect lookup results (screenshot)
□ Block change count
□ Time of incident
□ Pattern analysis (random vs systematic)
□ Related incidents by same player
□ Chat logs during incident
□ Player history check

# Generate report
/co lookup u:[Suspect] t:30d > suspect_history.txt
```

### Step 3: Determine Intent

```
Griefing Intent Indicators:

Strong Evidence (Ban Worthy):
- Systematic destruction (100+ blocks)
- Targeted player bases
- Repeated incidents
- Admission in chat
- Alt account after previous ban
- Coordinated with others

Weak Evidence (Warning First):
- <20 blocks affected
- Accidental pattern
- First offense
- Confusion about rules
- Claimed areas overlap

Grey Areas:
- PvP raid vs griefing
- Abandoned base "salvaging"
- Revenge griefing after theft
→ Investigate context thoroughly
```

### Step 4: Action Decision

```
Decision Matrix:

IF (First Offense + Minor Damage):
   → Verbal warning
   → Rollback damage
   → Log incident
   → Monitor player

IF (First Offense + Major Damage):
   → Temporary ban (3-7 days)
   → Rollback damage
   → Require appeal
   → Ban note documentation

IF (Repeat Offense):
   → Permanent ban
   → Rollback all changes
   → Alt account detection
   → Report to ban databases

IF (Coordinated Attack):
   → Permanent ban all involved
   → IP ban if necessary
   → Report to community
   → Strengthen protections
```

### Step 5: Execute Action

```bash
# Rollback damage
/co rollback u:[Griefer] t:30d r:500

# Apply punishment
/ban [Griefer] [Duration] [Reason]
# Example: /ban GrieferXYZ 7d "Griefing - destroying spawn builds"

# Document case
/notes add [Griefer] "Case #12345: Griefed spawn, 234 blocks destroyed, 
7 day ban issued, evidence: screenshot_001.png"

# Notify reporter
/mail send [Reporter] "Case #12345 resolved. Griefer banned 7 days, 
damage restored. Thank you for reporting."

# Alert staff
/staffchat "Case #12345 closed: GrieferXYZ banned 7d for spawn griefing"
```

---

## X-Ray Response Playbook

### Detection Process

```
Automated Alert Triggered:
Player: SuspectMiner
Alert: Diamond mining rate anomaly
Rate: 47 diamonds/hour (normal: 15-20)

Investigation:
/co lookup u:SuspectMiner b:diamond_ore t:7d

Analysis:
□ Total diamond ore breaks: 423
□ Average Y level: Y:11 (97% consistency)
□ Time period: 9 hours mining
□ Other ore breaks: 12 coal, 3 iron (suspicious)
□ Mining pattern: Straight lines, no exploration
□ Comparison to legitimate players: 3x normal rate

Evidence Strength: STRONG
```

### Action Steps

```
1. Gather Evidence
/co lookup u:[Player] b:diamond_ore,ancient_debris t:30d
Screenshot results
Note Y-level patterns
Calculate ore/hour rate

2. Secondary Verification
Check other indicators:
- Fast travel between ores
- No cave exploration
- Ignores visible ores (tests vision)
- Strip mine only at optimal Y

3. Confront або Ban
Option A (Soft Approach):
/msg [Player] "Your mining patterns appear suspicious. 
Care to explain your diamond rate?"

Option B (Direct Ban):
/ban [Player] perm "X-Ray: 47 diamonds/hour, Y:11 only, 
no exploration pattern"

4. Rollback Gains
/co rollback u:[Player] t:30d a:container
# Removes items they stored

5. Alert Community
"Player [X] banned for x-ray. If you traded with them, 
items may be removed. Contact staff if affected."
```

---

## Dupe Exploit Response Playbook

### Critical Incident (P0)

```
Alert: Economy inflation detected
Indicator: Diamond count increased 400% in 24h

IMMEDIATE ACTIONS (Within 5 Minutes):

1. STOP THE BLEEDING
/stop
# Shutdown server to prevent further duping

2. BACKUP DATABASE
pg_dump minecraft_db > emergency_backup_$(date +%Y%m%d_%H%M%S).sql

3. INVESTIGATE OFFLINE
# Analyze CoreProtect data
SELECT player, COUNT(*) as diamond_adds
FROM co_container
WHERE item_type = ''DIAMOND''
AND action = 1  -- Item added
AND time > EXTRACT(EPOCH FROM NOW() - INTERVAL ''24 hours'')
GROUP BY player
ORDER BY diamond_adds DESC
LIMIT 10;

Result:
- DuperPlayer1: 5,000 diamonds added
- DuperPlayer2: 3,200 diamonds added
- DuperPlayer3: 2,800 diamonds added

4. FIND EXPLOIT METHOD
/co lookup u:DuperPlayer1 t:24h

Pattern Analysis:
- Repeated chest interactions
- Item appears multiple times
- Timing: 0.1s between duplications

Exploit Type: Chunk dupe (packet manipulation)

5. PATCH EXPLOIT
# Update Paper/Purpur to latest version
# OR apply temporary fix:
# Disable chunk loading during item transfer

6. ROLLBACK DUPED ITEMS
# Calculate legitimate baseline
# Remove excess diamonds from all players

UPDATE player_inventory
SET diamond_count = LEAST(diamond_count, 64)
WHERE diamond_count > 1000;

7. BAN EXPLOITERS
/ban DuperPlayer1 perm "Duplication exploit: 5000 diamonds duped"
/ban DuperPlayer2 perm "Duplication exploit: 3200 diamonds duped"
/ban DuperPlayer3 perm "Duplication exploit: 2800 diamonds duped"

8. SERVER RESTART WITH FIXES
# Update plugins
# Apply patches
# Test exploit fixed

9. COMMUNITY ANNOUNCEMENT
"Server was down for emergency maintenance due to an 
economy exploit. Exploiters banned permanently, duped 
items removed. Server now updated and secured. 
Economy reset to yesterday''s backup state."

Total Downtime: 45-90 minutes
```

---

## Ban Appeal System

### Appeal Submission Form

```
Ban Appeal Template (Discord/Web Form):

Minecraft Username: __________
Ban Reason: __________
Ban Date: __________
Your Explanation: __________ (500 char max)
Why Should We Unban You: __________ (500 char max)
Will You Follow Rules: Yes/No
Evidence/Screenshots: [Upload]

Auto-Response:
"Your appeal has been submitted. Case ID: #AP-12345
Review time: 3-7 days for permanent bans, 1-3 days for temp bans.
Please be patient, arguing will delay your appeal."
```

### Appeal Review Process

```
Step 1: Evidence Verification
□ Pull original ban evidence
□ Review CoreProtect logs
□ Check staff notes
□ Verify ban reason accuracy

Step 2: Appeal Quality Check
Red Flags (Likely Deny):
- "I didn''t do it" (no explanation)
- "My friend/brother did it"
- Blaming lag/glitches
- Threats or insults
- Appeals immediately after ban
- Multiple appeals (impatient)

Green Flags (Consider Accept):
- Admits wrongdoing
- Shows understanding of rules
- Apologetic tone
- Time served (>6 months)
- First offense
- Willing to accept conditions

Step 3: Decision Matrix

IF (False Positive Ban):
   → Immediate unban
   → Apologize
   → Compensation (rank/items)
   → Review staff training

IF (Minor Offense + Good Appeal + Time Served):
   → Unban with warning
   → Reset player data
   → Monitoring period
   → One final chance

IF (Major Offense + Poor Appeal):
   → Deny appeal
   → Explain why
   → Suggest reappeal after [time]

IF (Alt Account + Ban Evasion):
   → Permanent deny
   → Ban new accounts
   → IP ban if persistent
```

### Appeal Response Templates

```
ACCEPTED (Minor Grief):
"Your appeal has been accepted. You were banned for griefing 
[player]''s base on [date]. Your explanation and apology are 
noted. You will be unbanned with the following conditions:

1. Your inventory/balance will be reset
2. You will be monitored for 30 days
3. Any further violations result in permanent ban
4. You must read /rules before playing

Welcome back. Please follow server rules."

DENIED (X-Ray):
"Your appeal has been denied. Evidence shows:
- 47 diamonds/hour mining rate (normal: 15-20)
- 97% mining at Y:11 only
- No cave exploration pattern
- Direct paths to ores

This is clear x-ray usage. You may reappeal in 6 months 
with a more honest explanation. Ban remains permanent."

PARTIAL ACCEPTANCE (Time Served):
"Your appeal for a permanent grief ban (2 years ago) has been 
accepted with conditions:

1. Ban reduced to time served (2 years)
2. Fresh start (inventory/rank reset)
3. Probation period: 60 days
4. Any violations = permanent ban

You''ve served significant time. We believe in second chances. 
Don''t waste this opportunity."
```

---

## Automated Alert Systems

### Alert Configuration

```java
// AlertSystem.java
public class AlertSystem extends JavaPlugin {
    
    @EventHandler
    public void onBlockBreak(BlockBreakEvent event) {
        Player player = event.getPlayer();
        Block block = event.getBlock();
        
        // Track diamond mining
        if (block.getType() == Material.DIAMOND_ORE) {
            DiamondTracker.increment(player);
            
            int count = DiamondTracker.getHourlyRate(player);
            if (count > 40) {  // Threshold
                alertStaff(
                    "X-RAY ALERT: " + player.getName() + 
                    " mined " + count + " diamonds/hour"
                );
            }
        }
        
        // Track rapid block breaks (grief bot)
        long breakSpeed = getBreakSpeed(player);
        if (breakSpeed > 10) {  // 10 blocks/second
            alertStaff(
                "GRIEF BOT ALERT: " + player.getName() + 
                " breaking " + breakSpeed + " blocks/sec"
            );
        }
    }
    
    // Container theft alert
    @EventHandler
    public void onInventoryClose(InventoryCloseEvent event) {
        if (event.getInventory().getHolder() instanceof Chest) {
            Player player = (Player) event.getPlayer();
            
            int itemsTaken = calculateItemsTaken(event);
            if (itemsTaken > 20) {
                Location loc = event.getInventory().getLocation();
                alertStaff(
                    "THEFT ALERT: " + player.getName() + 
                    " took " + itemsTaken + " items from chest at " +
                    loc.getBlockX() + ", " + loc.getBlockY() + ", " + loc.getBlockZ()
                );
            }
        }
    }
    
    private void alertStaff(String message) {
        // Send to online staff
        for (Player staff : Bukkit.getOnlinePlayers()) {
            if (staff.hasPermission("alerts.receive")) {
                staff.sendMessage(ChatColor.RED + "[ALERT] " + message);
            }
        }
        
        // Log to Discord webhook (implement webhook sender)
        // sendDiscordAlert(message);
        
        // Store in database
        // logAlert(message, System.currentTimeMillis());
    }
}
```

### Discord Integration

```python
# discord_alerts.py
import discord
from discord.ext import commands
import asyncio

bot = commands.Bot(command_prefix=''!'')

@bot.event
async def on_ready():
    print(f''Alert bot logged in as {bot.user}'')

async def send_alert(channel_id, severity, message):
    channel = bot.get_channel(channel_id)
    
    embed = discord.Embed(
        title=f''🚨 {severity} Alert'',
        description=message,
        color=discord.Color.red() if severity == ''CRITICAL'' else discord.Color.orange()
    )
    embed.set_footer(text=f''Alert Time: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}'')
    
    await channel.send(embed=embed)
    
    # Ping staff role for critical alerts
    if severity == ''CRITICAL'':
        staff_role = discord.utils.get(channel.guild.roles, name=''Staff'')
        await channel.send(f''{staff_role.mention} Immediate attention required!'')

# Example usage from Minecraft server
# POST to webhook with alert data
```

---

## Case Documentation Standards

### Incident Report Template

```markdown
# Incident Report #12345

**Date:** 2025-01-15
**Time:** 14:30 UTC
**Severity:** P1 (High)
**Type:** Mass Griefing

## Summary
Player GrieferXYZ destroyed spawn builds, affecting 5,000+ blocks.

## Timeline
- 14:15: Griefing begins
- 14:25: Player report received
- 14:30: Staff investigates
- 14:35: Evidence collected
- 14:40: Ban issued
- 14:45: Rollback completed

## Evidence
- CoreProtect logs: [screenshot_001.png]
- Block count: 5,234 destroyed
- Pattern: Systematic destruction
- Duration: 10 minutes

## Actions Taken
- Player banned permanently
- Damage rolled back via CoreProtect
- Reporter notified
- Case logged

## Involved Players
- Griefer: GrieferXYZ
- Reporter: HonestPlayer123
- Staff: ModeratorName

## Prevention Recommendations
- Increase staff presence during off-hours
- Implement grief protection in spawn areas
- Review ban evasion detection

## Resolution
Case closed. All damage restored, griefer permanently banned.
```

---

## Висновок

Effective incident response requires:

**Preparation:**
- Clear severity definitions
- Documented playbooks
- Staff training
- Alert systems

**Execution:**
- Fast response times
- Evidence collection
- Consistent decisions
- Professional communication

**Follow-up:**
- Case documentation
- Appeal system
- Prevention improvements
- Community transparency

**Tools:**
- CoreProtect (forensics)
- Discord (communication)
- Database (tracking)
- Automated alerts (detection)

Professional incident response = player trust + server reputation.

Наступний модуль covers automated ban systems та ML-based detection.',
    5400,
    14,
    false
  );

  RAISE NOTICE 'Module 7, Lesson 14 created!';
END $$;
