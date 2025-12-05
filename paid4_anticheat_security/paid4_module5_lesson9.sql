-- =====================================================
-- МОДУЛЬ 5, УРОК 9: Exploit Prevention - Dupe Exploits 2025
-- =====================================================
-- Курс: paid-4 (Advanced Anti-Cheat та Security Systems)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 5;
  
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-4',
      'module-5',
      'Exploit Prevention',
      'Dupe exploits, crash exploits, патчинг vulnerabilities',
      5
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 9;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'Dupe Exploits 2025: Real Cases та Патчинг',
    'text',
    '# Dupe Exploits 2025: Real Cases та Патчинг

Dupe exploits - найбільша загроза для economy серверів. Один exploit може знищити економіку за годину. Цей урок покриває реальні dupe методи 2025 року та їх prevention.

---

## Типи Dupe Exploits

### Inventory Desync Dupes

Експлуатація desync між client та server inventory state.

```
Classic Chest Dupe (2015-2018, patched):
1. Покласти items в chest
2. Disconnect під час saving
3. Server rollback inventory але chest saved
4. Result: items в inventory + chest

Modern Variant (2024):
1. Multi-threaded inventory operations
2. Race condition між InventoryClickEvent handlers
3. Item copied під час processing
```

### Chunk Loading Dupes

Експлуатація chunk save/load механізму.

```
Donkey Dupe (patched 1.19.3):
1. Покласти items на donkey
2. Ride donkey до chunk border
3. Logout exact moment chunk unloads
4. Chunk saves with donkey + items
5. Player inventory не cleared
6. Relog: items в inventory + donkey

Impact: Ukrainian server lost 50M in-game currency (January 2024)
```

### Packet Manipulation Dupes

Відправка malicious packets для inventory manipulation.

```
Shulker Box Dupe (discovered 2023):
1. Modified client sends duplicate UseItemPacket
2. Server processes twice за 1 tick
3. Shulker box placed але також stays в inventory
4. Open shulker, take items, break = duplicate

Prevention: Rate limit UseItemPacket per player
```

---

## Real Case Study 1: Ukrainian Prison Server (2024)

### The Exploit

```
Server: play.prison-example.ua
Economy: 1 diamond = $1000 in-game
Exploit: Anvil rename dupe

How It Worked:
1. Player ставить item в anvil
2. Rename item (triggers inventory update)
3. Modified client sends ClickWindowPacket з negative slot
4. Server bug: item duplicated через inventory refresh
5. Repeat = infinite duplication

Discovery Timeline:
Day 1: Player "DarkMiner" знайшов exploit
Day 2-4: Silent duping, створив 5,000 diamonds
Day 5: Продав diamonds іншим гравцям
Day 7: Economy crashed, diamond price 0
Day 8: Admin виявив через economy monitoring
```

### Detection Method

```java
// Monitoring plugin
public class EconomyMonitor {
    private final Map<Material, Long> itemCreationRate = new HashMap<>();
    
    @EventHandler
    public void onItemCreate(ItemSpawnEvent event) {
        Material type = event.getEntity().getItemStack().getType();
        itemCreationRate.merge(type, 1L, Long::sum);
    }
    
    // Check every 5 minutes
    public void checkAnomalies() {
        for (Map.Entry<Material, Long> entry : itemCreationRate.entrySet()) {
            if (entry.getKey() == Material.DIAMOND && entry.getValue() > 500) {
                alertAdmin("Unusual diamond creation: " + entry.getValue() + " in 5 min");
            }
        }
        itemCreationRate.clear();
    }
}

Alert Log (Day 7):
[14:23] ALERT: Unusual diamond creation: 1,243 in 5 min
[14:28] ALERT: Unusual diamond creation: 2,105 in 5 min
[14:32] Admin investigation started
```

### The Fix

```java
@EventHandler(priority = EventPriority.HIGHEST)
public void onInventoryClick(InventoryClickEvent event) {
    // Validate slot number
    if (event.getSlot() < 0 || event.getSlot() >= event.getInventory().getSize()) {
        event.setCancelled(true);
        Player player = (Player) event.getWhoClicked();
        logSuspiciousActivity(player, "Invalid inventory slot: " + event.getSlot());
        return;
    }
    
    // Additional validation
    if (event.getView().getTitle().contains("Anvil")) {
        ItemStack cursor = event.getCursor();
        ItemStack current = event.getCurrentItem();
        
        // Prevent double-processing
        if (isProcessing(player.getUniqueId())) {
            event.setCancelled(true);
            return;
        }
        
        markProcessing(player.getUniqueId());
        Bukkit.getScheduler().runTaskLater(plugin, 
            () -> unmarkProcessing(player.getUniqueId()), 2L);
    }
}
```

### Recovery Process

```
1. Server rollback to Day 6 backup (before mass duping)
2. Manual inventory check top 100 richest players
3. Confiscate duplicated items (4,832 diamonds removed)
4. Ban DarkMiner + 12 buyers (permanent)
5. Compensate legitimate players affected by rollback
6. Public announcement with transparency

Financial Impact:
- Lost donations: ~$300 (players quit during exploit)
- Recovery time: 8 hours staff work
- Lesson learned: Priceless
```

---

## Real Case Study 2: SkyBlock Server (2023)

### The Exploit: Minion Dupe

```
Server: Premium SkyBlock (1,200 online)
Exploit: Async minion collection dupe

Technical Details:
1. Minions collect resources асинхронно
2. Player breaks minion exact moment it collects item
3. Race condition: item добавляється в inventory
4. Minion drops with items inside
5. Result: items в inventory + minion storage

Code Vulnerability:
public void collectResource() {
    ItemStack resource = generateResource();
    
    // Async task (vulnerable)
    Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
        // Minion може бути removed між перевірками
        if (minion.isPlaced()) {
            minion.getStorage().addItem(resource);  // Added to storage
        }
    });
    
    // Але player вже отримав drop
    player.getInventory().addItem(resource);  // Also added to player
}
```

### Detection

```java
// Red flag: Player ламає 50+ minions за 10 хвилин
@EventHandler
public void onBlockBreak(BlockBreakEvent event) {
    if (isMinion(event.getBlock())) {
        Player player = event.getPlayer();
        PlayerData data = getPlayerData(player);
        
        data.incrementMinionsBreoken();
        
        if (data.getMinionsBreokenInLast10Min() > 30) {
            event.setCancelled(true);
            alertStaff(player.getName() + " suspicious minion breaking pattern");
            
            // Temp ban для investigation
            player.kickPlayer("Suspicious activity detected");
        }
    }
}
```

### The Fix

```java
public void collectResource() {
    ItemStack resource = generateResource();
    
    // Synchronous processing (fixed)
    Bukkit.getScheduler().runTask(plugin, () -> {
        // Atomic check and add
        synchronized (minion) {
            if (minion.isPlaced() && minion.getLocation().getBlock().getType() == Material.MINION) {
                minion.getStorage().addItem(resource);
            } else {
                // Minion removed, don''t add item anywhere
                // Item lost = cost of breaking during collection
            }
        }
    });
}
```

---

## Common Dupe Patterns та Prevention

### Pattern 1: Inventory Transaction Interruption

```java
// Vulnerable pattern
@EventHandler
public void onInventoryClose(InventoryCloseEvent event) {
    saveInventory(event.getPlayer());  // Can be interrupted
}

// Fixed pattern
@EventHandler
public void onInventoryClose(InventoryCloseEvent event) {
    Player player = (Player) event.getPlayer();
    
    // Lock inventory during save
    lockInventory(player.getUniqueId());
    
    try {
        saveInventoryAtomic(player);
    } finally {
        unlockInventory(player.getUniqueId());
    }
}
```

### Pattern 2: Async Data Loss

```java
// Vulnerable: async save може втратити data
public void savePlayerData(Player player) {
    Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
        database.save(player.getUniqueId(), getInventory(player));
    });
}

// Fixed: queue saves, process sequentially
private final Queue<Runnable> saveQueue = new ConcurrentLinkedQueue<>();

public void savePlayerData(Player player) {
    saveQueue.offer(() -> {
        database.save(player.getUniqueId(), getInventory(player));
    });
}

// Process queue on main thread
Bukkit.getScheduler().runTaskTimer(plugin, () -> {
    Runnable save = saveQueue.poll();
    if (save != null) save.run();
}, 0L, 1L);
```

### Pattern 3: Client-Server Desync

```java
// Vulnerable: trust client data
@EventHandler
public void onPacketReceive(PacketEvent event) {
    if (event.getPacket() instanceof PacketPlayInWindowClick) {
        PacketPlayInWindowClick packet = (PacketPlayInWindowClick) event.getPacket();
        // Direct processing = can be exploited
        processClick(packet.getSlot(), packet.getItem());
    }
}

// Fixed: validate everything
@EventHandler
public void onPacketReceive(PacketEvent event) {
    if (event.getPacket() instanceof PacketPlayInWindowClick) {
        PacketPlayInWindowClick packet = (PacketPlayInWindowClick) event.getPacket();
        
        // Validate slot
        if (packet.getSlot() < 0 || packet.getSlot() >= 54) {
            event.setCancelled(true);
            return;
        }
        
        // Validate item matches server state
        ItemStack serverItem = getServerInventory(player).getItem(packet.getSlot());
        if (!itemsMatch(serverItem, packet.getItem())) {
            event.setCancelled(true);
            syncInventory(player);  // Re-sync client
            return;
        }
        
        processClickValidated(packet);
    }
}
```

---

## Dupe Detection System

### Automated Monitoring

```java
public class DupeDetectionSystem {
    
    // Track item creation sources
    private final Map<UUID, Map<Material, Integer>> itemSources = new HashMap<>();
    
    @EventHandler
    public void onItemSpawn(ItemSpawnEvent event) {
        Location loc = event.getLocation();
        Player nearestPlayer = getNearestPlayer(loc, 10);
        
        if (nearestPlayer != null) {
            trackItemCreation(nearestPlayer.getUniqueId(), 
                event.getEntity().getItemStack());
        }
    }
    
    @EventHandler
    public void onBlockBreak(BlockBreakEvent event) {
        // Track block drops
        Collection<ItemStack> drops = event.getBlock().getDrops();
        for (ItemStack drop : drops) {
            trackItemCreation(event.getPlayer().getUniqueId(), drop);
        }
    }
    
    // Check for anomalies
    public void analyzePatterns() {
        for (Map.Entry<UUID, Map<Material, Integer>> entry : itemSources.entrySet()) {
            UUID player = entry.getKey();
            Map<Material, Integer> items = entry.getValue();
            
            // Check for unusual item gains
            for (Map.Entry<Material, Integer> item : items.entrySet()) {
                if (item.getKey().name().contains("DIAMOND") && item.getValue() > 64) {
                    flagSuspicious(player, 
                        "Gained " + item.getValue() + " diamonds in 5 minutes");
                }
                
                if (item.getKey().name().contains("NETHERITE") && item.getValue() > 10) {
                    flagSuspicious(player,
                        "Gained " + item.getValue() + " netherite in 5 minutes");
                }
            }
        }
        
        itemSources.clear();
    }
    
    private void flagSuspicious(UUID player, String reason) {
        // Log to database
        database.logSuspicious(player, reason, System.currentTimeMillis());
        
        // Alert staff
        alertStaff("DUPE ALERT: " + Bukkit.getPlayer(player).getName() + " - " + reason);
        
        // Auto-freeze inventory
        freezeInventory(player);
    }
}
```

---

## Prevention Checklist

```
Core Principles:
[ ] Never trust client data
[ ] Validate all inventory operations
[ ] Use atomic transactions
[ ] Lock resources during critical operations
[ ] Log all item creation/destruction
[ ] Monitor economy metrics
[ ] Regular backups (every 6 hours)

Code Review Checklist:
[ ] No async inventory modifications
[ ] All packet handlers validate slot numbers
[ ] Race conditions checked with synchronized blocks
[ ] Chunk save/load operations atomic
[ ] Disconnect handlers save state correctly
[ ] No client-controlled loops
[ ] Rate limiting on critical operations

Testing Process:
[ ] Test with modified clients
[ ] Simulate network interruptions
[ ] Test chunk border cases
[ ] Concurrent operations stress test
[ ] Rollback recovery test
[ ] Performance impact measurement
```

---

## Висновок

Dupe exploits потребують:

**Proactive Defense:**
- Code review з фокусом на async operations
- Packet validation
- Atomic transactions
- Resource locking

**Detection:**
- Economy monitoring
- Unusual item creation alerts
- Player behavior analysis
- Log everything

**Response:**
- Fast rollback capability
- Investigation tools
- Transparent communication
- Learn from incidents

Наступний урок покриває crash exploits та server hardening.',
    5400,
    9,
    false
  );

  RAISE NOTICE 'Module 5, Lesson 9 created!';
END $$;
