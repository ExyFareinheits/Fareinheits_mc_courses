-- =============================================
-- Модуль 7: Async/Sync обробка та Scheduler
-- =============================================

-- Урок 7.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-7', 'lesson-7-1',
  'BukkitScheduler - основи',
  '16 хв', 'text',
  '# BukkitScheduler - планувальник задач

BukkitScheduler дозволяє виконувати код з затримкою або періодично.

## Основні методи

```java
import org.bukkit.Bukkit;
import org.bukkit.scheduler.BukkitScheduler;

public class SchedulerExamples {
    
    private final JavaPlugin plugin;
    
    public SchedulerExamples(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    // runTask - виконати на main thread
    public void runSyncTask() {
        Bukkit.getScheduler().runTask(plugin, () -> {
            // Цей код виконається на наступному tick
            Bukkit.broadcastMessage("§aЗадача виконана!");
        });
    }
    
    // runTaskLater - виконати через N ticks
    public void runDelayedTask() {
        // 20 ticks = 1 секунда
        Bukkit.getScheduler().runTaskLater(plugin, () -> {
            Bukkit.broadcastMessage("§eПройшло 5 секунд!");
        }, 100L); // 100 ticks = 5 секунд
    }
    
    // runTaskTimer - повторювати кожні N ticks
    public void runRepeatingTask() {
        Bukkit.getScheduler().runTaskTimer(plugin, () -> {
            // Виконується кожні 3 секунди
            Bukkit.broadcastMessage("§6Періодичне повідомлення");
        }, 0L, 60L); // 0 = початкова затримка, 60 = інтервал (3 сек)
    }
    
    // runTaskAsynchronously - виконати в окремому потоці
    public void runAsyncTask() {
        Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
            // УВАГА: Тут НЕ можна використовувати Bukkit API!
            // Тільки операції з БД, файлами, HTTP запити
            
            // Приклад: важкі обчислення
            int result = calculateSomething();
            
            // Повернутись на main thread для Bukkit API
            Bukkit.getScheduler().runTask(plugin, () -> {
                Bukkit.broadcastMessage("§aРезультат: " + result);
            });
        });
    }
    
    // runTaskTimerAsynchronously - async повторення
    public void runAsyncRepeating() {
        Bukkit.getScheduler().runTaskTimerAsynchronously(plugin, () -> {
            // Async операція (наприклад, перевірка БД)
            checkDatabase();
        }, 0L, 1200L); // Кожну хвилину
    }
}
```

## Конвертація часу

```java
public class TimeConverter {
    
    public static long secondsToTicks(int seconds) {
        return seconds * 20L;
    }
    
    public static long minutesToTicks(int minutes) {
        return minutes * 60L * 20L;
    }
    
    public static long hoursToTicks(int hours) {
        return hours * 3600L * 20L;
    }
}

// Використання
runTaskLater(plugin, task, TimeConverter.secondsToTicks(10)); // 10 секунд
runTaskTimer(plugin, task, 0L, TimeConverter.minutesToTicks(5)); // Кожні 5 хвилин
```

## Збереження task ID

```java
public class AutoSaveManager {
    
    private final JavaPlugin plugin;
    private int taskId = -1;
    
    public AutoSaveManager(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    public void startAutoSave() {
        if (taskId != -1) {
            plugin.getLogger().warning("Auto-save вже запущений!");
            return;
        }
        
        taskId = Bukkit.getScheduler().runTaskTimerAsynchronously(plugin, () -> {
            saveAllData();
        }, 6000L, 6000L).getTaskId(); // Кожні 5 хвилин
        
        plugin.getLogger().info("Auto-save запущено! Task ID: " + taskId);
    }
    
    public void stopAutoSave() {
        if (taskId != -1) {
            Bukkit.getScheduler().cancelTask(taskId);
            plugin.getLogger().info("Auto-save зупинено!");
            taskId = -1;
        }
    }
    
    private void saveAllData() {
        plugin.getLogger().info("Збереження даних...");
        // Логіка збереження
    }
}
```

## Затримка дії гравця

```java
public class DelayedTeleport {
    
    private final Map<UUID, Integer> pendingTeleports = new HashMap<>();
    
    public void teleportWithDelay(Player player, Location location, int seconds) {
        // Скасувати попередній телепорт якщо є
        cancelTeleport(player.getUniqueId());
        
        Location startLocation = player.getLocation().clone();
        
        player.sendMessage("§eTелепортація через " + seconds + " секунд...");
        player.sendMessage("§cНе рухайтесь!");
        
        int taskId = Bukkit.getScheduler().runTaskLater(plugin, () -> {
            // Перевірити чи гравець не рухався
            if (player.getLocation().distance(startLocation) > 0.5) {
                player.sendMessage("§cТелепортація скасована! Ви рухались.");
                pendingTeleports.remove(player.getUniqueId());
                return;
            }
            
            // Перевірити чи гравець онлайн
            if (!player.isOnline()) {
                pendingTeleports.remove(player.getUniqueId());
                return;
            }
            
            player.teleport(location);
            player.sendMessage("§aТелепортовано!");
            pendingTeleports.remove(player.getUniqueId());
            
        }, seconds * 20L).getTaskId();
        
        pendingTeleports.put(player.getUniqueId(), taskId);
    }
    
    public void cancelTeleport(UUID uuid) {
        Integer taskId = pendingTeleports.remove(uuid);
        if (taskId != null) {
            Bukkit.getScheduler().cancelTask(taskId);
        }
    }
    
    // Скасувати якщо гравець отримує урон
    @EventHandler
    public void onDamage(EntityDamageEvent event) {
        if (event.getEntity() instanceof Player) {
            Player player = (Player) event.getEntity();
            if (pendingTeleports.containsKey(player.getUniqueId())) {
                cancelTeleport(player.getUniqueId());
                player.sendMessage("§cТелепортація скасована! Ви отримали урон.");
            }
        }
    }
}
```

## Countdown таймер

```java
public class CountdownTimer {
    
    public void startCountdown(int seconds, Consumer<Integer> onTick, Runnable onComplete) {
        new BukkitRunnable() {
            int remaining = seconds;
            
            @Override
            public void run() {
                if (remaining <= 0) {
                    onComplete.run();
                    cancel();
                    return;
                }
                
                onTick.accept(remaining);
                remaining--;
            }
        }.runTaskTimer(plugin, 0L, 20L);
    }
}

// Використання
CountdownTimer timer = new CountdownTimer();

timer.startCountdown(10, 
    (seconds) -> {
        // Кожну секунду
        Bukkit.broadcastMessage("§e" + seconds + "...");
    },
    () -> {
        // Після завершення
        Bukkit.broadcastMessage("§aПочаток гри!");
        startGame();
    }
);
```

## Система кулдаунів

```java
public class CooldownManager {
    
    private final Map<UUID, Map<String, Long>> cooldowns = new HashMap<>();
    
    public void setCooldown(UUID uuid, String action, long duration) {
        cooldowns.computeIfAbsent(uuid, k -> new HashMap<>())
                 .put(action, System.currentTimeMillis() + duration);
    }
    
    public boolean hasCooldown(UUID uuid, String action) {
        Map<String, Long> playerCooldowns = cooldowns.get(uuid);
        if (playerCooldowns == null) return false;
        
        Long expiry = playerCooldowns.get(action);
        if (expiry == null) return false;
        
        if (System.currentTimeMillis() >= expiry) {
            playerCooldowns.remove(action);
            return false;
        }
        
        return true;
    }
    
    public long getRemainingCooldown(UUID uuid, String action) {
        Map<String, Long> playerCooldowns = cooldowns.get(uuid);
        if (playerCooldowns == null) return 0;
        
        Long expiry = playerCooldowns.get(action);
        if (expiry == null) return 0;
        
        long remaining = expiry - System.currentTimeMillis();
        return remaining > 0 ? remaining : 0;
    }
    
    public String formatCooldown(long milliseconds) {
        long seconds = milliseconds / 1000;
        
        if (seconds >= 3600) {
            return (seconds / 3600) + "год " + ((seconds % 3600) / 60) + "хв";
        } else if (seconds >= 60) {
            return (seconds / 60) + "хв " + (seconds % 60) + "с";
        } else {
            return seconds + "с";
        }
    }
}

// Використання в команді
@Override
public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
    if (!(sender instanceof Player)) return false;
    Player player = (Player) sender;
    
    if (cooldownManager.hasCooldown(player.getUniqueId(), "kit")) {
        long remaining = cooldownManager.getRemainingCooldown(player.getUniqueId(), "kit");
        player.sendMessage("§cКулдаун! Залишилось: " + 
                          cooldownManager.formatCooldown(remaining));
        return true;
    }
    
    giveKit(player);
    cooldownManager.setCooldown(player.getUniqueId(), "kit", 3600000); // 1 година
    player.sendMessage("§aВи отримали кіт!");
    
    return true;
}
```

## Скасування всіх задач при вимкненні

```java
public class TaskManager {
    
    private final JavaPlugin plugin;
    private final List<Integer> taskIds = new ArrayList<>();
    
    public TaskManager(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    public int scheduleTask(Runnable task, long delay) {
        int id = Bukkit.getScheduler().runTaskLater(plugin, task, delay).getTaskId();
        taskIds.add(id);
        return id;
    }
    
    public int scheduleRepeating(Runnable task, long delay, long period) {
        int id = Bukkit.getScheduler().runTaskTimer(plugin, task, delay, period).getTaskId();
        taskIds.add(id);
        return id;
    }
    
    public int scheduleAsync(Runnable task, long delay) {
        int id = Bukkit.getScheduler().runTaskLaterAsynchronously(plugin, task, delay).getTaskId();
        taskIds.add(id);
        return id;
    }
    
    public void cancelAll() {
        taskIds.forEach(id -> Bukkit.getScheduler().cancelTask(id));
        taskIds.clear();
        plugin.getLogger().info("Скасовано " + taskIds.size() + " задач");
    }
}

// В головному класі
@Override
public void onDisable() {
    taskManager.cancelAll();
}
```

## Практичне завдання

Створіть систему з:
1. Auto-save кожні 5 хвилин (async)
2. Затримана телепортація (10 сек, скасування при русі/уроні)
3. Система кулдаунів (команди, здібності)
4. Countdown таймер для ігор
5. TaskManager для управління всіма задачами',
  1, FALSE
);

-- Урок 7.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-7', 'lesson-7-2',
  'Thread Safety та Bukkit API обмеження',
  '18 хв', 'text',
  '# Thread Safety в Minecraft плагінах

**КРИТИЧНО:** Bukkit API можна використовувати ТІЛЬКИ з main thread!

## Що можна робити в async?

✅ **Можна:**
- Запити до баз даних
- Читання/запис файлів
- HTTP запити
- Важкі обчислення
- Робота з власними об''єктами

❌ **ЗАБОРОНЕНО:**
- Виклик Bukkit/Spigot API
- Зміна блоків світу
- Взаємодія з entities
- Інвентарі гравців
- Телепортація
- Відправка повідомлень

## Проблемний код

```java
// ❌ НЕБЕЗПЕЧНО - ConcurrentModificationException!
@EventHandler
public void onJoin(PlayerJoinEvent event) {
    Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
        // ПОМИЛКА: getOnlinePlayers() в async thread!
        for (Player player : Bukkit.getOnlinePlayers()) {
            player.sendMessage("Новий гравець приєднався!"); // ПОМИЛКА!
        }
    });
}

// ✅ ПРАВИЛЬНО
@EventHandler
public void onJoin(PlayerJoinEvent event) {
    // Зібрати дані в async
    Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
        String welcomeMessage = loadWelcomeMessage(); // OK - читання файлу
        
        // Повернутись на main thread для API
        Bukkit.getScheduler().runTask(plugin, () -> {
            for (Player player : Bukkit.getOnlinePlayers()) {
                player.sendMessage(welcomeMessage);
            }
        });
    });
}
```

## Thread-safe обгортка

```java
public class ThreadSafePlayer {
    
    private final UUID uuid;
    private final String name;
    
    public ThreadSafePlayer(Player player) {
        this.uuid = player.getUniqueId();
        this.name = player.getName();
    }
    
    public void sendMessage(String message) {
        Bukkit.getScheduler().runTask(plugin, () -> {
            Player player = Bukkit.getPlayer(uuid);
            if (player != null && player.isOnline()) {
                player.sendMessage(message);
            }
        });
    }
    
    public void teleport(Location location) {
        Bukkit.getScheduler().runTask(plugin, () -> {
            Player player = Bukkit.getPlayer(uuid);
            if (player != null && player.isOnline()) {
                player.teleport(location);
            }
        });
    }
    
    public CompletableFuture<Boolean> giveItem(ItemStack item) {
        CompletableFuture<Boolean> future = new CompletableFuture<>();
        
        Bukkit.getScheduler().runTask(plugin, () -> {
            Player player = Bukkit.getPlayer(uuid);
            if (player != null && player.isOnline()) {
                player.getInventory().addItem(item);
                future.complete(true);
            } else {
                future.complete(false);
            }
        });
        
        return future;
    }
    
    public UUID getUUID() {
        return uuid;
    }
    
    public String getName() {
        return name;
    }
}

// Використання
Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
    // Важка операція
    double balance = database.getBalance(uuid);
    
    // Thread-safe відправка повідомлення
    ThreadSafePlayer safePlayer = new ThreadSafePlayer(player);
    safePlayer.sendMessage("§aВаш баланс: $" + balance);
});
```

## Sync wrapper методи

```java
public class SyncExecutor {
    
    private final JavaPlugin plugin;
    
    public SyncExecutor(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    // Виконати на main thread та чекати результат
    public <T> T callSyncMethod(Callable<T> callable) throws Exception {
        if (Bukkit.isPrimaryThread()) {
            // Вже на main thread
            return callable.call();
        }
        
        // Виконати на main thread та чекати
        Future<T> future = Bukkit.getScheduler().callSyncMethod(plugin, callable);
        return future.get();
    }
    
    // Виконати на main thread без очікування
    public void runSyncMethod(Runnable runnable) {
        if (Bukkit.isPrimaryThread()) {
            runnable.run();
        } else {
            Bukkit.getScheduler().runTask(plugin, runnable);
        }
    }
}

// Використання
SyncExecutor sync = new SyncExecutor(plugin);

Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
    try {
        // Async операція
        PlayerData data = database.loadPlayer(uuid);
        
        // Синхронне виконання на main thread
        Player player = sync.callSyncMethod(() -> Bukkit.getPlayer(uuid));
        
        if (player != null) {
            sync.runSyncMethod(() -> {
                player.setLevel(data.level);
                player.setExp(data.exp);
            });
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    }
});
```

## ConcurrentHashMap для thread-safe даних

```java
public class PlayerDataCache {
    
    // Thread-safe Map
    private final ConcurrentHashMap<UUID, PlayerData> cache = new ConcurrentHashMap<>();
    
    public void load(UUID uuid) {
        Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
            PlayerData data = database.load(uuid);
            
            // Thread-safe операція
            cache.put(uuid, data);
            
            // Повернутись на main thread
            Bukkit.getScheduler().runTask(plugin, () -> {
                Player player = Bukkit.getPlayer(uuid);
                if (player != null) {
                    player.sendMessage("§aДані завантажено!");
                }
            });
        });
    }
    
    public PlayerData get(UUID uuid) {
        return cache.get(uuid);
    }
    
    public void update(UUID uuid, Consumer<PlayerData> updater) {
        // Thread-safe оновлення
        cache.computeIfPresent(uuid, (key, data) -> {
            updater.accept(data);
            return data;
        });
    }
    
    public void saveAll() {
        Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
            // Створити копію для безпечної ітерації
            Map<UUID, PlayerData> snapshot = new HashMap<>(cache);
            
            for (Map.Entry<UUID, PlayerData> entry : snapshot.entrySet()) {
                database.save(entry.getKey(), entry.getValue());
            }
        });
    }
}
```

## AtomicInteger для лічильників

```java
public class ServerStats {
    
    private final AtomicInteger onlineCount = new AtomicInteger(0);
    private final AtomicLong totalPlayTime = new AtomicLong(0);
    
    @EventHandler
    public void onJoin(PlayerJoinEvent event) {
        onlineCount.incrementAndGet();
    }
    
    @EventHandler
    public void onQuit(PlayerQuitEvent event) {
        onlineCount.decrementAndGet();
    }
    
    public void addPlayTime(long milliseconds) {
        totalPlayTime.addAndGet(milliseconds);
    }
    
    public int getOnlineCount() {
        return onlineCount.get();
    }
    
    public long getTotalPlayTime() {
        return totalPlayTime.get();
    }
}
```

## Sync блоки для критичних секцій

```java
public class BalanceManager {
    
    private final Map<UUID, Double> balances = new HashMap<>();
    private final Object balanceLock = new Object();
    
    public void addBalance(UUID uuid, double amount) {
        synchronized (balanceLock) {
            double current = balances.getOrDefault(uuid, 0.0);
            balances.put(uuid, current + amount);
        }
    }
    
    public boolean removeBalance(UUID uuid, double amount) {
        synchronized (balanceLock) {
            double current = balances.getOrDefault(uuid, 0.0);
            if (current < amount) {
                return false;
            }
            balances.put(uuid, current - amount);
            return true;
        }
    }
    
    public double getBalance(UUID uuid) {
        synchronized (balanceLock) {
            return balances.getOrDefault(uuid, 0.0);
        }
    }
}
```

## Deadlock запобігання

```java
public class SafeTransfer {
    
    // Завжди блокувати в одному порядку!
    public boolean transfer(UUID from, UUID to, double amount) {
        // Упорядкувати UUID
        UUID first = from.compareTo(to) < 0 ? from : to;
        UUID second = from.compareTo(to) < 0 ? to : from;
        
        synchronized (getLock(first)) {
            synchronized (getLock(second)) {
                // Тепер безпечно
                if (balanceManager.getBalance(from) < amount) {
                    return false;
                }
                
                balanceManager.removeBalance(from, amount);
                balanceManager.addBalance(to, amount);
                return true;
            }
        }
    }
    
    private Object getLock(UUID uuid) {
        return uuid.toString().intern();
    }
}
```

## Перевірка поточного потоку

```java
public class ThreadChecker {
    
    public static void ensureMainThread(String operation) {
        if (!Bukkit.isPrimaryThread()) {
            throw new IllegalStateException(
                operation + " має викликатись на main thread!"
            );
        }
    }
    
    public static void ensureAsyncThread(String operation) {
        if (Bukkit.isPrimaryThread()) {
            throw new IllegalStateException(
                operation + " має викликатись async!"
            );
        }
    }
}

// Використання
public void setBlockAsync(Location loc, Material material) {
    ThreadChecker.ensureAsyncThread("setBlockAsync");
    
    // Повернутись на main thread
    Bukkit.getScheduler().runTask(plugin, () -> {
        loc.getBlock().setType(material);
    });
}
```

## Виявлення race conditions

```java
public class RaceConditionExample {
    
    private int counter = 0;
    
    // ❌ НЕБЕЗПЕЧНО - race condition!
    public void unsafeIncrement() {
        Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
            counter++; // НЕ атомарна операція!
        });
    }
    
    // ✅ БЕЗПЕЧНО - AtomicInteger
    private final AtomicInteger safeCounter = new AtomicInteger(0);
    
    public void safeIncrement() {
        Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
            safeCounter.incrementAndGet(); // Атомарна операція
        });
    }
    
    // ✅ БЕЗПЕЧНО - synchronized
    public synchronized void synchronizedIncrement() {
        counter++;
    }
}
```

## Практичне завдання

Створіть thread-safe систему:
1. ThreadSafePlayer wrapper для async операцій
2. ConcurrentHashMap кеш для даних гравців
3. AtomicInteger лічильники статистики
4. Безпечний transfer з deadlock запобіганням
5. Перевірки Bukkit.isPrimaryThread() в критичних місцях
6. Тести race conditions',
  2, FALSE
);

-- Урок 7.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-7', 'lesson-7-3',
  'Advanced Scheduler - BukkitRunnable та patterns',
  '14 хв', 'text',
  '# BukkitRunnable - розширений підхід

BukkitRunnable дає більше контролю над задачами.

## Основи BukkitRunnable

```java
import org.bukkit.scheduler.BukkitRunnable;

public class MyTask extends BukkitRunnable {
    
    private final JavaPlugin plugin;
    private int counter = 0;
    
    public MyTask(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    @Override
    public void run() {
        counter++;
        
        Bukkit.broadcastMessage("§eTask виконано: " + counter);
        
        // Зупинити після 10 разів
        if (counter >= 10) {
            cancel();
        }
    }
}

// Запуск
MyTask task = new MyTask(plugin);
task.runTaskTimer(plugin, 0L, 20L); // Кожну секунду
```

## Автоматичне скасування

```java
public class AutoCancelTask extends BukkitRunnable {
    
    private final Player player;
    private int attempts = 0;
    
    public AutoCancelTask(Player player) {
        this.player = player;
    }
    
    @Override
    public void run() {
        // Скасувати якщо гравець offline
        if (!player.isOnline()) {
            cancel();
            return;
        }
        
        attempts++;
        player.sendMessage("§aСпроба #" + attempts);
        
        // Скасувати після 5 спроб
        if (attempts >= 5) {
            player.sendMessage("§cЗавершено!");
            cancel();
        }
    }
}

// Запуск
new AutoCancelTask(player).runTaskTimer(plugin, 0L, 40L); // Кожні 2 секунди
```

## Прогрес бар

```java
public class ProgressBarTask extends BukkitRunnable {
    
    private final Player player;
    private final int totalSteps;
    private int currentStep = 0;
    
    public ProgressBarTask(Player player, int totalSteps) {
        this.player = player;
        this.totalSteps = totalSteps;
    }
    
    @Override
    public void run() {
        if (!player.isOnline() || currentStep >= totalSteps) {
            cancel();
            return;
        }
        
        currentStep++;
        
        // Створити прогрес бар
        int percentage = (currentStep * 100) / totalSteps;
        int bars = currentStep * 20 / totalSteps;
        
        StringBuilder progress = new StringBuilder("§a[");
        for (int i = 0; i < 20; i++) {
            if (i < bars) {
                progress.append("§a█");
            } else {
                progress.append("§7█");
            }
        }
        progress.append("§a] ").append(percentage).append("%");
        
        player.sendMessage(progress.toString());
        
        if (currentStep >= totalSteps) {
            player.sendMessage("§aЗавершено!");
        }
    }
}

// Використання
new ProgressBarTask(player, 10).runTaskTimer(plugin, 0L, 10L);
```

## Chained Tasks (послідовність)

```java
public class ChainedTaskExecutor {
    
    private final JavaPlugin plugin;
    private final List<Runnable> tasks = new ArrayList<>();
    private int currentIndex = 0;
    
    public ChainedTaskExecutor(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    public ChainedTaskExecutor addTask(Runnable task) {
        tasks.add(task);
        return this;
    }
    
    public void execute(long delayBetween) {
        new BukkitRunnable() {
            @Override
            public void run() {
                if (currentIndex >= tasks.size()) {
                    cancel();
                    return;
                }
                
                tasks.get(currentIndex).run();
                currentIndex++;
            }
        }.runTaskTimer(plugin, 0L, delayBetween);
    }
}

// Використання
new ChainedTaskExecutor(plugin)
    .addTask(() -> Bukkit.broadcastMessage("§aКрок 1"))
    .addTask(() -> Bukkit.broadcastMessage("§eКрок 2"))
    .addTask(() -> Bukkit.broadcastMessage("§cКрок 3"))
    .execute(20L); // Затримка 1 секунда між кроками
```

## Повторювана перевірка умови

```java
public class ConditionWaiter extends BukkitRunnable {
    
    private final BooleanSupplier condition;
    private final Runnable onComplete;
    private final long timeout;
    private final long startTime;
    
    public ConditionWaiter(BooleanSupplier condition, Runnable onComplete, long timeoutSeconds) {
        this.condition = condition;
        this.onComplete = onComplete;
        this.timeout = timeoutSeconds * 1000;
        this.startTime = System.currentTimeMillis();
    }
    
    @Override
    public void run() {
        // Перевірити timeout
        if (System.currentTimeMillis() - startTime >= timeout) {
            cancel();
            System.out.println("Timeout! Умова не виконана.");
            return;
        }
        
        // Перевірити умову
        if (condition.getAsBoolean()) {
            onComplete.run();
            cancel();
        }
    }
}

// Використання
new ConditionWaiter(
    () -> player.getLevel() >= 10, // Умова
    () -> player.sendMessage("§aВи досягли 10 рівня!"), // Виконати
    30 // Timeout 30 секунд
).runTaskTimer(plugin, 0L, 20L); // Перевіряти кожну секунду
```

## Система анімації

```java
public class ParticleAnimation extends BukkitRunnable {
    
    private final Location center;
    private double angle = 0;
    private int ticks = 0;
    
    public ParticleAnimation(Location center) {
        this.center = center;
    }
    
    @Override
    public void run() {
        if (ticks++ >= 100) { // 5 секунд
            cancel();
            return;
        }
        
        // Створити коло з частинок
        for (int i = 0; i < 8; i++) {
            double x = center.getX() + Math.cos(angle + (i * Math.PI / 4)) * 2;
            double z = center.getZ() + Math.sin(angle + (i * Math.PI / 4)) * 2;
            double y = center.getY() + 1;
            
            Location particleLoc = new Location(center.getWorld(), x, y, z);
            center.getWorld().spawnParticle(Particle.FLAME, particleLoc, 1, 0, 0, 0, 0);
        }
        
        angle += Math.PI / 16;
    }
}

// Запуск
new ParticleAnimation(player.getLocation()).runTaskTimer(plugin, 0L, 1L);
```

## Task Pool для множинних задач

```java
public class TaskPool {
    
    private final JavaPlugin plugin;
    private final Set<BukkitRunnable> activeTasks = ConcurrentHashMap.newKeySet();
    
    public TaskPool(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    public void submitRepeating(BukkitRunnable task, long delay, long period) {
        activeTasks.add(task);
        
        new BukkitRunnable() {
            @Override
            public void run() {
                if (task.isCancelled()) {
                    activeTasks.remove(task);
                    cancel();
                    return;
                }
                
                task.run();
            }
        }.runTaskTimer(plugin, delay, period);
    }
    
    public void cancelAll() {
        activeTasks.forEach(BukkitRunnable::cancel);
        activeTasks.clear();
    }
    
    public int getActiveCount() {
        return activeTasks.size();
    }
}

// Використання
TaskPool pool = new TaskPool(plugin);

pool.submitRepeating(new MyTask1(), 0L, 20L);
pool.submitRepeating(new MyTask2(), 0L, 40L);

// При вимкненні
pool.cancelAll();
```

## Retry механізм з експоненціальним backoff

```java
public class RetryTask extends BukkitRunnable {
    
    private final Callable<Boolean> action;
    private final Consumer<Boolean> callback;
    private final int maxAttempts;
    private int attempt = 0;
    private long delay = 20L; // 1 секунда
    
    public RetryTask(Callable<Boolean> action, Consumer<Boolean> callback, int maxAttempts) {
        this.action = action;
        this.callback = callback;
        this.maxAttempts = maxAttempts;
    }
    
    @Override
    public void run() {
        attempt++;
        
        try {
            if (action.call()) {
                callback.accept(true);
                cancel();
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        if (attempt >= maxAttempts) {
            callback.accept(false);
            cancel();
            return;
        }
        
        // Exponential backoff
        delay *= 2;
        
        new BukkitRunnable() {
            @Override
            public void run() {
                RetryTask.this.run();
            }
        }.runTaskLater(plugin, delay);
        
        cancel();
    }
}

// Використання
new RetryTask(
    () -> {
        // Спроба підключитись до БД
        return database.connect();
    },
    success -> {
        if (success) {
            plugin.getLogger().info("Підключено!");
        } else {
            plugin.getLogger().severe("Не вдалося підключитись після 5 спроб");
        }
    },
    5 // max спроб
).runTask(plugin);
```

## Scheduled Task Manager

```java
public class ScheduledTaskManager {
    
    private final JavaPlugin plugin;
    private final Map<String, BukkitRunnable> tasks = new HashMap<>();
    
    public void register(String name, BukkitRunnable task, long delay, long period) {
        // Скасувати попередню якщо є
        cancel(name);
        
        tasks.put(name, task);
        task.runTaskTimer(plugin, delay, period);
    }
    
    public void cancel(String name) {
        BukkitRunnable task = tasks.remove(name);
        if (task != null) {
            task.cancel();
        }
    }
    
    public boolean isRunning(String name) {
        BukkitRunnable task = tasks.get(name);
        return task != null && !task.isCancelled();
    }
    
    public void cancelAll() {
        tasks.values().forEach(BukkitRunnable::cancel);
        tasks.clear();
    }
    
    public Set<String> getTaskNames() {
        return new HashSet<>(tasks.keySet());
    }
}

// Використання
ScheduledTaskManager manager = new ScheduledTaskManager(plugin);

manager.register("autosave", new AutoSaveTask(), 6000L, 6000L);
manager.register("backup", new BackupTask(), 72000L, 72000L);

// Команда для перегляду
if (args[0].equals("tasks")) {
    sender.sendMessage("§eАктивні задачі:");
    manager.getTaskNames().forEach(name -> {
        sender.sendMessage("§7- " + name);
    });
}
```

## Практичне завдання

Створіть систему з:
1. ProgressBarTask для довгих операцій
2. ChainedTaskExecutor для послідовних дій
3. ParticleAnimation для ефектів
4. RetryTask з exponential backoff
5. ScheduledTaskManager для управління всіма задачами
6. Команди: `/tasks list`, `/tasks cancel <name>`',
  3, FALSE
);

-- Квіз для Модуля 7
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-7', 'lesson-7-4',
  'Тест: Scheduler та Threading',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-7-4",
    "questions": [
      {
        "id": "q1",
        "question": "Скільки ticks в 1 секунді?",
        "options": [
          "10 ticks",
          "20 ticks",
          "30 ticks",
          "60 ticks"
        ],
        "correctAnswer": 1,
        "explanation": "В Minecraft 20 ticks = 1 секунда. Сервер працює з частотою 20 TPS (ticks per second)"
      },
      {
        "id": "q2",
        "question": "Чи можна використовувати Bukkit API в async thread?",
        "options": [
          "Так, завжди безпечно",
          "Ні, ТІЛЬКИ на main thread",
          "Тільки для читання",
          "Тільки для entities"
        ],
        "correctAnswer": 1,
        "explanation": "Bukkit API можна використовувати ТІЛЬКИ з main thread! Async - тільки для БД, файлів, HTTP"
      },
      {
        "id": "q3",
        "question": "Для чого використовується runTaskAsynchronously?",
        "options": [
          "Для роботи з блоками",
          "Для важких операцій (БД, файли) без блокування main thread",
          "Для телепортації гравців",
          "Для відправки повідомлень"
        ],
        "correctAnswer": 1,
        "explanation": "runTaskAsynchronously виконує код в окремому потоці, ідеально для БД запитів, читання файлів, HTTP"
      },
      {
        "id": "q4",
        "question": "Що таке ConcurrentHashMap?",
        "options": [
          "Звичайна HashMap",
          "Thread-safe Map для безпечної роботи з декількох потоків",
          "Async база даних",
          "Scheduler утиліта"
        ],
        "correctAnswer": 1,
        "explanation": "ConcurrentHashMap - thread-safe Map, безпечний для одночасного доступу з різних потоків"
      },
      {
        "id": "q5",
        "question": "Як правильно повернутись на main thread після async?",
        "options": [
          "Thread.join()",
          "Bukkit.getScheduler().runTask(plugin, () -> { ... })",
          "player.sendMessage() безпосередньо",
          "CompletableFuture.await()"
        ],
        "correctAnswer": 1,
        "explanation": "runTask виконує код на main thread, використовуйте його після async для Bukkit API викликів"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 7 додано! 4 уроки створено.' as status;
