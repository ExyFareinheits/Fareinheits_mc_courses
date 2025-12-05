-- =====================================================
-- МОДУЛЬ 3, УРОК 5: Custom Anti-Cheat Checks (Java Implementation)
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
  
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-4',
      'module-3',
      'Custom Anti-Cheat Development',
      'Розробка власних перевірок, packet analysis, ProtocolLib integration',
      3
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 5;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Custom Anti-Cheat Checks: Java Implementation',
    'text',
    '# Custom Anti-Cheat Checks: Java Implementation

Цей урок покриває практичну розробку власних anti-cheat перевірок на Java. Ви навчитеся створювати detection algorithms для найпоширеніших чітів: Killaura, Fly, Speed, Scaffold.

---

## Архітектура Custom Anti-Cheat Plugin

### Базова Структура

```
CustomAC/
├── src/main/java/
│   ├── checks/
│   │   ├── Check.java (abstract base)
│   │   ├── combat/
│   │   │   ├── KillauraCheck.java
│   │   │   ├── ReachCheck.java
│   │   │   └── AutoClickerCheck.java
│   │   ├── movement/
│   │   │   ├── FlyCheck.java
│   │   │   ├── SpeedCheck.java
│   │   │   └── NoFallCheck.java
│   │   └── player/
│   │       ├── ScaffoldCheck.java
│   │       └── TimerCheck.java
│   ├── data/
│   │   └── PlayerData.java
│   ├── utils/
│   │   ├── MathUtils.java
│   │   └── LocationUtils.java
│   └── CustomAC.java (main)
```

### Base Check Class

```java
package com.example.customac.checks;

import org.bukkit.entity.Player;
import java.util.UUID;

public abstract class Check {
    private final String checkName;
    private final String checkType;
    private final int maxViolations;
    
    public Check(String checkName, String checkType, int maxViolations) {
        this.checkName = checkName;
        this.checkType = checkType;
        this.maxViolations = maxViolations;
    }
    
    public abstract void check(Player player);
    
    protected void flag(Player player, String details, double certainty) {
        PlayerData data = PlayerDataManager.getData(player.getUniqueId());
        data.addViolation(checkName, certainty);
        
        int currentVL = data.getViolations(checkName);
        
        if (currentVL >= maxViolations) {
            punish(player, currentVL);
        }
        
        alertStaff(player, checkName, details, currentVL, certainty);
    }
    
    protected abstract void punish(Player player, int violationLevel);
    
    private void alertStaff(Player player, String check, String details, 
                           int vl, double certainty) {
        String message = String.format(
            "[AC] %s failed %s (VL: %d, Certainty: %.1f%%) - %s",
            player.getName(), check, vl, certainty * 100, details
        );
        
        Bukkit.getOnlinePlayers().stream()
            .filter(p -> p.hasPermission("customac.alerts"))
            .forEach(p -> p.sendMessage(message));
    }
}
```

---

## Killaura Detection

### Type A: Rotation Analysis

Killaura чіти часто роблять нереальні повороти голови. Legitimate гравці не можуть повернутися на 180 градусів за 1 tick.

```java
package com.example.customac.checks.combat;

import org.bukkit.Location;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerMoveEvent;
import com.example.customac.checks.Check;
import com.example.customac.data.PlayerData;

public class KillauraRotationCheck extends Check implements Listener {
    
    // Максимальний реалістичний поворот за 1 tick (50ms)
    private static final double MAX_ROTATION_PER_TICK = 80.0;
    private static final double SUSPICIOUS_ROTATION = 60.0;
    
    public KillauraRotationCheck() {
        super("Killaura (Rotation)", "Combat", 10);
    }
    
    @EventHandler
    public void onMove(PlayerMoveEvent event) {
        Player player = event.getPlayer();
        Location from = event.getFrom();
        Location to = event.getTo();
        
        if (to == null) return;
        
        double yawDelta = Math.abs(to.getYaw() - from.getYaw());
        double pitchDelta = Math.abs(to.getPitch() - from.getPitch());
        
        // Normalize yaw (0-360)
        if (yawDelta > 180) {
            yawDelta = 360 - yawDelta;
        }
        
        double totalRotation = Math.sqrt(
            yawDelta * yawDelta + pitchDelta * pitchDelta
        );
        
        if (totalRotation > MAX_ROTATION_PER_TICK) {
            double certainty = Math.min(
                (totalRotation - MAX_ROTATION_PER_TICK) / 100.0, 
                1.0
            );
            
            flag(player, 
                String.format("Rotation: %.1f°/tick", totalRotation),
                certainty
            );
        }
        
        // Додаткова перевірка: snap rotation
        PlayerData data = PlayerDataManager.getData(player.getUniqueId());
        if (totalRotation > SUSPICIOUS_ROTATION) {
            data.incrementSnapRotations();
            
            if (data.getSnapRotations() > 5) {
                flag(player, 
                    "Multiple snap rotations detected",
                    0.8
                );
                data.resetSnapRotations();
            }
        }
    }
    
    @Override
    protected void punish(Player player, int vl) {
        if (vl >= 30) {
            player.kickPlayer("Killaura detected");
        } else if (vl >= 15) {
            // Setback player position
            PlayerData data = PlayerDataManager.getData(player.getUniqueId());
            player.teleport(data.getLastLegitLocation());
        }
    }
    
    @Override
    public void check(Player player) {
        // Passive check via event listener
    }
}
```

### Type B: Multi-Target Detection

Killaura атакує декілька entities за короткий час. Legitimate гравець атакує 1 ціль за раз.

```java
package com.example.customac.checks.combat;

import org.bukkit.entity.Entity;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import com.example.customac.checks.Check;
import com.example.customac.data.PlayerData;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.UUID;

public class KillauraMultiTargetCheck extends Check implements Listener {
    
    private static final int MAX_TARGETS_PER_SECOND = 2;
    private static final long TIME_WINDOW = 1000L; // 1 second
    
    public KillauraMultiTargetCheck() {
        super("Killaura (Multi-Target)", "Combat", 8);
    }
    
    @EventHandler
    public void onEntityDamage(EntityDamageByEntityEvent event) {
        if (!(event.getDamager() instanceof Player)) return;
        
        Player attacker = (Player) event.getDamager();
        Entity victim = event.getEntity();
        
        PlayerData data = PlayerDataManager.getData(attacker.getUniqueId());
        long currentTime = System.currentTimeMillis();
        
        // Cleanup old attacks
        data.getRecentAttacks()
            .entrySet()
            .removeIf(e -> currentTime - e.getValue() > TIME_WINDOW);
        
        // Add current attack
        data.getRecentAttacks().put(victim.getUniqueId(), currentTime);
        
        int uniqueTargets = data.getRecentAttacks().size();
        
        if (uniqueTargets > MAX_TARGETS_PER_SECOND) {
            double certainty = Math.min(
                (uniqueTargets - MAX_TARGETS_PER_SECOND) / 3.0,
                0.95
            );
            
            flag(attacker,
                String.format("%d targets in 1 second", uniqueTargets),
                certainty
            );
        }
    }
    
    @Override
    protected void punish(Player player, int vl) {
        if (vl >= 20) {
            player.kickPlayer("Multi-target killaura detected");
        }
    }
    
    @Override
    public void check(Player player) {
        // Event-based check
    }
}
```

### Type C: Hit Pattern Analysis

Legitimate гравці мають варіацію в timing атак. Killaura часто атакує з perfect consistency.

```java
package com.example.customac.checks.combat;

import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import com.example.customac.checks.Check;
import com.example.customac.data.PlayerData;

import java.util.ArrayList;
import java.util.List;

public class KillauraPatternCheck extends Check implements Listener {
    
    private static final double MAX_CONSISTENCY = 0.15; // 15% std deviation
    private static final int SAMPLE_SIZE = 10;
    
    public KillauraPatternCheck() {
        super("Killaura (Pattern)", "Combat", 12);
    }
    
    @EventHandler
    public void onAttack(EntityDamageByEntityEvent event) {
        if (!(event.getDamager() instanceof Player)) return;
        
        Player attacker = (Player) event.getDamager();
        PlayerData data = PlayerDataManager.getData(attacker.getUniqueId());
        
        long currentTime = System.currentTimeMillis();
        long lastAttackTime = data.getLastAttackTime();
        
        if (lastAttackTime > 0) {
            long timeDelta = currentTime - lastAttackTime;
            data.addAttackInterval(timeDelta);
        }
        
        data.setLastAttackTime(currentTime);
        
        List<Long> intervals = data.getAttackIntervals();
        
        if (intervals.size() >= SAMPLE_SIZE) {
            double consistency = calculateConsistency(intervals);
            
            if (consistency < MAX_CONSISTENCY) {
                double certainty = 1.0 - (consistency / MAX_CONSISTENCY);
                
                flag(attacker,
                    String.format("Hit pattern too consistent: %.2f%%", consistency * 100),
                    certainty
                );
            }
            
            // Keep only recent intervals
            if (intervals.size() > SAMPLE_SIZE * 2) {
                intervals.subList(0, SAMPLE_SIZE).clear();
            }
        }
    }
    
    private double calculateConsistency(List<Long> intervals) {
        // Calculate standard deviation
        double mean = intervals.stream()
            .mapToLong(Long::longValue)
            .average()
            .orElse(0.0);
        
        double variance = intervals.stream()
            .mapToDouble(interval -> Math.pow(interval - mean, 2))
            .average()
            .orElse(0.0);
        
        double stdDev = Math.sqrt(variance);
        
        // Return coefficient of variation (normalized)
        return mean > 0 ? stdDev / mean : 1.0;
    }
    
    @Override
    protected void punish(Player player, int vl) {
        if (vl >= 25) {
            player.kickPlayer("Suspicious attack pattern");
        }
    }
    
    @Override
    public void check(Player player) {
        // Event-based
    }
}
```

---

## Fly Detection

### Type A: Vertical Movement Check

Гравець не може летіти без elytra або creative mode. Перевіряємо вертикальне переміщення.

```java
package com.example.customac.checks.movement;

import org.bukkit.GameMode;
import org.bukkit.Location;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerMoveEvent;
import com.example.customac.checks.Check;

public class FlyCheck extends Check implements Listener {
    
    private static final double MAX_VERTICAL_SPEED = 0.42; // blocks per tick
    private static final double GRAVITY = 0.08;
    
    public FlyCheck() {
        super("Fly", "Movement", 5);
    }
    
    @EventHandler
    public void onMove(PlayerMoveEvent event) {
        Player player = event.getPlayer();
        
        // Ignore creative/spectator/elytra
        if (player.getGameMode() == GameMode.CREATIVE ||
            player.getGameMode() == GameMode.SPECTATOR ||
            player.isGliding()) {
            return;
        }
        
        Location from = event.getFrom();
        Location to = event.getTo();
        
        if (to == null) return;
        
        double yDelta = to.getY() - from.getY();
        
        // Ignore falling
        if (yDelta < 0) return;
        
        // Check if player is on ground
        if (player.isOnGround()) return;
        
        // Calculate expected fall based on gravity
        PlayerData data = PlayerDataManager.getData(player.getUniqueId());
        double expectedY = data.getLastYVelocity() - GRAVITY;
        
        if (yDelta > MAX_VERTICAL_SPEED) {
            double certainty = Math.min(
                (yDelta - MAX_VERTICAL_SPEED) / 1.0,
                0.95
            );
            
            flag(player,
                String.format("Vertical speed: %.3f b/t", yDelta),
                certainty
            );
        }
        
        // Detect hover (no vertical movement while in air)
        if (!player.isOnGround() && Math.abs(yDelta) < 0.01) {
            data.incrementHoverTicks();
            
            if (data.getHoverTicks() > 10) {
                flag(player,
                    String.format("Hovering for %d ticks", data.getHoverTicks()),
                    0.9
                );
            }
        } else {
            data.resetHoverTicks();
        }
        
        data.setLastYVelocity(yDelta);
    }
    
    @Override
    protected void punish(Player player, int vl) {
        PlayerData data = PlayerDataManager.getData(player.getUniqueId());
        player.teleport(data.getLastGroundLocation());
        
        if (vl >= 15) {
            player.kickPlayer("Fly detected");
        }
    }
    
    @Override
    public void check(Player player) {
        // Event listener
    }
}
```

---

## Speed Detection

### Type A: Horizontal Movement Check

```java
package com.example.customac.checks.movement;

import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerMoveEvent;
import org.bukkit.potion.PotionEffectType;
import com.example.customac.checks.Check;

public class SpeedCheck extends Check implements Listener {
    
    private static final double BASE_SPEED = 0.36; // blocks per tick
    private static final double SPRINT_MULTIPLIER = 1.3;
    private static final double SPEED_EFFECT_MULTIPLIER = 0.20;
    
    public SpeedCheck() {
        super("Speed", "Movement", 8);
    }
    
    @EventHandler
    public void onMove(PlayerMoveEvent event) {
        Player player = event.getPlayer();
        Location from = event.getFrom();
        Location to = event.getTo();
        
        if (to == null) return;
        
        // Calculate horizontal distance
        double deltaX = to.getX() - from.getX();
        double deltaZ = to.getZ() - from.getZ();
        double horizontalDistance = Math.sqrt(deltaX * deltaX + deltaZ * deltaZ);
        
        // Calculate max allowed speed
        double maxSpeed = BASE_SPEED;
        
        if (player.isSprinting()) {
            maxSpeed *= SPRINT_MULTIPLIER;
        }
        
        // Add speed effect
        if (player.hasPotionEffect(PotionEffectType.SPEED)) {
            int amplifier = player.getPotionEffect(PotionEffectType.SPEED).getAmplifier();
            maxSpeed += SPEED_EFFECT_MULTIPLIER * (amplifier + 1);
        }
        
        // Add ice/soul speed bonus
        Material blockBelow = player.getLocation().subtract(0, 1, 0).getBlock().getType();
        if (blockBelow == Material.ICE || blockBelow == Material.PACKED_ICE) {
            maxSpeed *= 1.2;
        }
        
        // Check if exceeds limit
        if (horizontalDistance > maxSpeed * 1.05) { // 5% tolerance
            double certainty = Math.min(
                (horizontalDistance - maxSpeed) / maxSpeed,
                0.95
            );
            
            flag(player,
                String.format("Speed: %.3f b/t (max: %.3f)", horizontalDistance, maxSpeed),
                certainty
            );
        }
    }
    
    @Override
    protected void punish(Player player, int vl) {
        PlayerData data = PlayerDataManager.getData(player.getUniqueId());
        player.teleport(data.getLastLegitLocation());
        
        if (vl >= 20) {
            player.kickPlayer("Speed hack detected");
        }
    }
    
    @Override
    public void check(Player player) {
        // Event listener
    }
}
```

---

## Scaffold Detection

Scaffold - це чіт, який автоматично ставить блоки під гравцем під час руху.

```java
package com.example.customac.checks.player;

import org.bukkit.Material;
import org.bukkit.block.Block;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.block.BlockPlaceEvent;
import com.example.customac.checks.Check;
import com.example.customac.data.PlayerData;

public class ScaffoldCheck extends Check implements Listener {
    
    private static final double MAX_PLACE_SPEED = 10.0; // blocks per second
    private static final double MAX_DISTANCE = 5.5; // blocks
    
    public ScaffoldCheck() {
        super("Scaffold", "Player", 10);
    }
    
    @EventHandler
    public void onBlockPlace(BlockPlaceEvent event) {
        Player player = event.getPlayer();
        Block block = event.getBlock();
        
        PlayerData data = PlayerDataManager.getData(player.getUniqueId());
        long currentTime = System.currentTimeMillis();
        
        // Check place speed
        long lastPlaceTime = data.getLastBlockPlaceTime();
        if (lastPlaceTime > 0) {
            long timeDelta = currentTime - lastPlaceTime;
            
            if (timeDelta < 100) { // Less than 100ms = 10 blocks/sec
                flag(player,
                    String.format("Placing too fast: %dms interval", timeDelta),
                    0.8
                );
            }
        }
        
        // Check place distance
        double distance = player.getLocation().distance(block.getLocation());
        if (distance > MAX_DISTANCE) {
            flag(player,
                String.format("Placed block at %.1f blocks", distance),
                0.9
            );
        }
        
        // Check rotation (scaffold often doesn''t look at block)
        double yaw = player.getLocation().getYaw();
        double pitch = player.getLocation().getPitch();
        
        if (Math.abs(pitch) < 30) { // Not looking down
            data.incrementScaffoldNoLook();
            
            if (data.getScaffoldNoLook() > 5) {
                flag(player,
                    "Placing blocks without looking down",
                    0.85
                );
                data.resetScaffoldNoLook();
            }
        } else {
            data.resetScaffoldNoLook();
        }
        
        data.setLastBlockPlaceTime(currentTime);
    }
    
    @Override
    protected void punish(Player player, int vl) {
        if (vl >= 25) {
            player.kickPlayer("Scaffold detected");
        }
    }
    
    @Override
    public void check(Player player) {
        // Event-based
    }
}
```

---

## PlayerData Class

Клас для зберігання даних гравця між перевірками.

```java
package com.example.customac.data;

import org.bukkit.Location;
import java.util.*;

public class PlayerData {
    private final UUID uuid;
    
    // Violations
    private final Map<String, Integer> violations = new HashMap<>();
    private final Map<String, Long> lastViolationTime = new HashMap<>();
    
    // Movement data
    private Location lastLegitLocation;
    private Location lastGroundLocation;
    private double lastYVelocity;
    private int hoverTicks;
    
    // Combat data
    private long lastAttackTime;
    private final List<Long> attackIntervals = new ArrayList<>();
    private final Map<UUID, Long> recentAttacks = new HashMap<>();
    private int snapRotations;
    
    // Player data
    private long lastBlockPlaceTime;
    private int scaffoldNoLook;
    
    public PlayerData(UUID uuid) {
        this.uuid = uuid;
    }
    
    public void addViolation(String checkName, double certainty) {
        int increment = (int) Math.ceil(certainty * 2);
        violations.merge(checkName, increment, Integer::sum);
        lastViolationTime.put(checkName, System.currentTimeMillis());
    }
    
    public int getViolations(String checkName) {
        return violations.getOrDefault(checkName, 0);
    }
    
    public void decayViolations() {
        long currentTime = System.currentTimeMillis();
        
        violations.entrySet().removeIf(entry -> {
            String check = entry.getKey();
            long lastVL = lastViolationTime.getOrDefault(check, 0L);
            
            // Decay 1 VL every 5 minutes
            if (currentTime - lastVL > 300000) {
                int newVL = entry.getValue() - 1;
                if (newVL <= 0) {
                    lastViolationTime.remove(check);
                    return true;
                }
                entry.setValue(newVL);
            }
            return false;
        });
    }
    
    // Getters and setters
    public Location getLastLegitLocation() { return lastLegitLocation; }
    public void setLastLegitLocation(Location loc) { this.lastLegitLocation = loc; }
    
    public Location getLastGroundLocation() { return lastGroundLocation; }
    public void setLastGroundLocation(Location loc) { this.lastGroundLocation = loc; }
    
    public double getLastYVelocity() { return lastYVelocity; }
    public void setLastYVelocity(double velocity) { this.lastYVelocity = velocity; }
    
    public int getHoverTicks() { return hoverTicks; }
    public void incrementHoverTicks() { this.hoverTicks++; }
    public void resetHoverTicks() { this.hoverTicks = 0; }
    
    public long getLastAttackTime() { return lastAttackTime; }
    public void setLastAttackTime(long time) { this.lastAttackTime = time; }
    
    public List<Long> getAttackIntervals() { return attackIntervals; }
    public void addAttackInterval(long interval) { this.attackIntervals.add(interval); }
    
    public Map<UUID, Long> getRecentAttacks() { return recentAttacks; }
    
    public int getSnapRotations() { return snapRotations; }
    public void incrementSnapRotations() { this.snapRotations++; }
    public void resetSnapRotations() { this.snapRotations = 0; }
    
    public long getLastBlockPlaceTime() { return lastBlockPlaceTime; }
    public void setLastBlockPlaceTime(long time) { this.lastBlockPlaceTime = time; }
    
    public int getScaffoldNoLook() { return scaffoldNoLook; }
    public void incrementScaffoldNoLook() { this.scaffoldNoLook++; }
    public void resetScaffoldNoLook() { this.scaffoldNoLook = 0; }
}
```

---

## Тестування та Оптимізація

### Performance Considerations

```java
// 1. Async checks для heavy operations
Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
    // Heavy calculation
    double result = complexAnalysis(data);
    
    // Return to main thread for player interaction
    Bukkit.getScheduler().runTask(plugin, () -> {
        if (result > threshold) {
            flag(player, "Complex check failed", 0.9);
        }
    });
});

// 2. Cache frequent calculations
private final Map<UUID, Double> cachedSpeeds = new HashMap<>();

public double getMaxSpeed(Player player) {
    return cachedSpeeds.computeIfAbsent(player.getUniqueId(), uuid -> {
        return calculateMaxSpeed(player);
    });
}

// 3. Batch processing для decay
Bukkit.getScheduler().runTaskTimerAsynchronously(plugin, () -> {
    PlayerDataManager.getAllData().forEach(PlayerData::decayViolations);
}, 0L, 6000L); // Every 5 minutes
```

### False Positive Reduction

```java
// 1. Ping compensation
double ping = getPing(player);
double tolerance = 1.0 + (ping / 1000.0);
double maxSpeedWithPing = maxSpeed * tolerance;

// 2. Block lag compensation
if (player.getWorld().getPlayers().size() > 100) {
    maxSpeed *= 1.1; // 10% tolerance on laggy servers
}

// 3. Multiple checks required
if (violations.get("Speed") > 5 && violations.get("Fly") > 3) {
    // More certain if multiple checks flag
    certainty = 0.95;
}
```

---

## Висновок

Custom anti-cheat checks вимагають:

**Технічні вміння:**
- Розуміння Minecraft physics (gravity, movement, collision)
- Java event-driven programming
- Statistical analysis (standard deviation, patterns)
- Performance optimization (async, caching)

**Балансування:**
- False positives vs false negatives
- Performance vs accuracy
- Strictness vs player experience

**Постійна підтримка:**
- Тестування на різних versions (1.8, 1.20+)
- Оновлення під нові cheat bypass methods
- Моніторинг false positive rates

Наступний урок покриває packet analysis та ProtocolLib для більш глибокого detection.',
    6000,
    5,
    false
  );

  RAISE NOTICE 'Module 3, Lesson 5 created!';
END $$;

SELECT m.title, l.title, l.order_index, l.duration, l.type
FROM course_modules m
JOIN course_lessons l ON l.module_id = m.id::text
WHERE m.course_id = 'paid-4' AND m.order_index = 3
ORDER BY l.order_index;
