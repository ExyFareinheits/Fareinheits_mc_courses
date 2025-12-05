-- =============================================
-- Модуль 3: Event система та Listeners
-- =============================================

-- Урок 3.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-3', 'lesson-3-1',
  'Що таке Events та як вони працюють',
  '15 хв', 'text',
  '# Event система в Minecraft

Events - це події що відбуваються на сервері. Плагіни можуть їх "слухати" і реагувати.

## Основна концепція

```java
// Коли гравець заходить → викликається PlayerJoinEvent
// Коли блок ламається → викликається BlockBreakEvent
// Коли моб вмирає → викликається EntityDeathEvent
```

## Створення Listener

```java
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerJoinEvent;

public class JoinListener implements Listener {
    
    @EventHandler
    public void onPlayerJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        player.sendMessage("Вітаємо на сервері!");
        
        // Змінити повідомлення join
        event.setJoinMessage("§a+ §7" + player.getName());
    }
}
```

## Реєстрація Listener

У головному класі:
```java
@Override
public void onEnable() {
    // Реєструємо listener
    getServer().getPluginManager().registerEvents(
        new JoinListener(), 
        this
    );
}
```

## Популярні Events

### Player Events
```java
// Підключення/Відключення
PlayerJoinEvent
PlayerQuitEvent
PlayerKickEvent

// Рух
PlayerMoveEvent
PlayerTeleportEvent

// Взаємодія
PlayerInteractEvent
PlayerInteractEntityEvent
PlayerInteractAtEntityEvent

// Чат
AsyncPlayerChatEvent
PlayerCommandPreprocessEvent

// Інвентар
InventoryClickEvent
InventoryCloseEvent
InventoryOpenEvent

// Смерть та респавн
PlayerDeathEvent
PlayerRespawnEvent
```

### Block Events
```java
BlockBreakEvent // Зламати блок
BlockPlaceEvent // Поставити блок
BlockBurnEvent  // Блок горить
BlockExplodeEvent // Вибух блоку
SignChangeEvent // Змінити текст на табличці
```

### Entity Events
```java
EntityDamageEvent // Сутність отримує урон
EntityDamageByEntityEvent // Урон від іншої сутності
EntityDeathEvent // Смерть сутності
EntitySpawnEvent // Спавн сутності
EntityTargetEvent // Зміна цілі моба
```

### World Events
```java
WeatherChangeEvent // Зміна погоди
TimeSkipEvent // Пропуск часу
ChunkLoadEvent // Завантаження чанку
ChunkUnloadEvent // Вивантаження чанку
```

## Event Priority

Порядок виконання event handlers:
```java
@EventHandler(priority = EventPriority.LOWEST)
public void onJoinLowest(PlayerJoinEvent event) {
    // Виконається ПЕРШИМ
}

@EventHandler(priority = EventPriority.LOW)
@EventHandler(priority = EventPriority.NORMAL) // За замовчуванням
@EventHandler(priority = EventPriority.HIGH)

@EventHandler(priority = EventPriority.HIGHEST)
public void onJoinHighest(PlayerJoinEvent event) {
    // Виконається ОСТАННІМ (але не найостаннішим)
}

@EventHandler(priority = EventPriority.MONITOR)
public void onJoinMonitor(PlayerJoinEvent event) {
    // Тільки для читання, НЕ ЗМІНЮВАТИ подію!
    // Виконується найостаннішим
}
```

## Скасування Events

```java
@EventHandler
public void onBlockBreak(BlockBreakEvent event) {
    Block block = event.getBlock();
    
    if (block.getType() == Material.BEDROCK) {
        // Заборонити ламати бедрок
        event.setCancelled(true);
        event.getPlayer().sendMessage("§cНе можна ламати бедрок!");
    }
}
```

## Практичний приклад

Listener для welcome системи:
```java
public class WelcomeListener implements Listener {
    private final JavaPlugin plugin;
    
    public WelcomeListener(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    @EventHandler
    public void onJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        
        // Перша поява?
        if (!player.hasPlayedBefore()) {
            // Перший раз
            event.setJoinMessage("§e§l★ §6Новий гравець " + player.getName() + " приєднався!");
            
            // Стартовий кіт
            player.getInventory().addItem(
                new ItemStack(Material.STONE_SWORD),
                new ItemStack(Material.BREAD, 10)
            );
            
            // Телепорт на спавн
            Location spawn = plugin.getConfig().getLocation("spawn");
            if (spawn != null) {
                player.teleport(spawn);
            }
            
            // Title
            player.sendTitle(
                "§6Вітаємо!",
                "§eНа нашому сервері",
                10, 70, 20
            );
        } else {
            // Звичайний вхід
            event.setJoinMessage("§a+ §7" + player.getName());
        }
    }
    
    @EventHandler
    public void onQuit(PlayerQuitEvent event) {
        event.setQuitMessage("§c- §7" + event.getPlayer().getName());
    }
}
```

## Практичне завдання

Створіть `ProtectionListener` що:
1. Забороняє ламати блоки в spawn зоні (радіус 50 блоків від 0,0)
2. Забороняє PvP в spawn зоні
3. Дає повідомлення гравцю коли він входить/виходить зі spawn зони',
  1, FALSE
);

-- Урок 3.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-3', 'lesson-3-2',
  'Робота з Player Events',
  '18 хв', 'text',
  '# Player Events детально

Найважливіші події для роботи з гравцями.

## PlayerInteractEvent

Клік мишкою (ПКМ/ЛКМ):
```java
@EventHandler
public void onInteract(PlayerInteractEvent event) {
    Player player = event.getPlayer();
    Action action = event.getAction();
    
    // Тип дії
    if (action == Action.RIGHT_CLICK_BLOCK) {
        // ПКМ по блоку
        Block block = event.getClickedBlock();
        
        if (block.getType() == Material.CHEST) {
            // Клік по скрині
            event.setCancelled(true);
            player.sendMessage("Ця скриня заблокована!");
        }
    }
    
    if (action == Action.RIGHT_CLICK_AIR || action == Action.RIGHT_CLICK_BLOCK) {
        // ПКМ (в повітря або по блоку)
        ItemStack item = player.getInventory().getItemInMainHand();
        
        if (item.getType() == Material.STICK) {
            // Особлива паличка
            player.sendMessage("§6Ви використали чарівну паличку!");
            event.setCancelled(true);
        }
    }
}
```

## PlayerMoveEvent

Рух гравця (викликається ДУЖЕ часто!):
```java
@EventHandler
public void onMove(PlayerMoveEvent event) {
    Location from = event.getFrom();
    Location to = event.getTo();
    
    // Перевірка чи справді переміщення (не просто поворот голови)
    if (from.getBlockX() != to.getBlockX() ||
        from.getBlockY() != to.getBlockY() ||
        from.getBlockZ() != to.getBlockZ()) {
        
        // Гравець справді рухається
        Player player = event.getPlayer();
        
        // Перевірка зони
        if (isInDangerZone(to)) {
            player.sendMessage("§cОбережно! Небезпечна зона!");
        }
    }
}

// ВАЖЛИВО: Не робити важкі операції в PlayerMoveEvent!
// Викликається 20+ разів на секунду для кожного гравця
```

## AsyncPlayerChatEvent

Чат (async = в окремому потоці):
```java
@EventHandler
public void onChat(AsyncPlayerChatEvent event) {
    Player player = event.getPlayer();
    String message = event.getMessage();
    
    // Фільтр мату
    if (message.contains("badword")) {
        event.setCancelled(true);
        player.sendMessage("§cНе лайтеся!");
        return;
    }
    
    // Зміна формату
    event.setFormat("§7[%1$s§7] §f%2$s");
    // %1$s - ім''я гравця
    // %2$s - повідомлення
    
    // Кастомний формат з рангом
    if (player.hasPermission("server.vip")) {
        event.setFormat("§6[VIP] %1$s§r: %2$s");
    }
    
    // Видалити з чату (тільки для команди)
    Set<Player> recipients = event.getRecipients();
    recipients.removeIf(p -> !p.hasPermission("server.staff"));
}
```

## InventoryClickEvent

Клік в інвентарі:
```java
@EventHandler
public void onClick(InventoryClickEvent event) {
    Player player = (Player) event.getWhoClicked();
    Inventory inv = event.getInventory();
    
    // Перевірка чи це наш GUI
    if (event.getView().getTitle().equals("§6Магазин")) {
        event.setCancelled(true); // Заборонити брати предмети
        
        ItemStack clicked = event.getCurrentItem();
        if (clicked == null) return;
        
        // Обробка кліків
        switch (clicked.getType()) {
            case DIAMOND_SWORD:
                // Купити меч
                player.sendMessage("§aВи купили меч!");
                player.closeInventory();
                break;
                
            case APPLE:
                // Купити їжу
                player.getInventory().addItem(new ItemStack(Material.APPLE, 10));
                break;
        }
    }
}
```

## PlayerDeathEvent

Смерть гравця:
```java
@EventHandler
public void onDeath(PlayerDeathEvent event) {
    Player player = event.getEntity();
    Player killer = player.getKiller();
    
    // Зміна повідомлення про смерть
    if (killer != null) {
        event.setDeathMessage(
            player.getName() + " §7був вбитий гравцем " + 
            killer.getName()
        );
    } else {
        event.setDeathMessage(player.getName() + " §7загинув");
    }
    
    // Зберегти досвід
    event.setKeepLevel(true);
    event.setDroppedExp(0);
    
    // Не дропати предмети
    event.getDrops().clear();
    
    // Кастомний лут
    event.getDrops().add(new ItemStack(Material.BONE, 3));
}
```

## EntityDamageByEntityEvent

Урон (PvP, PvE):
```java
@EventHandler
public void onDamage(EntityDamageByEntityEvent event) {
    Entity damager = event.getDamager();
    Entity victim = event.getEntity();
    
    // PvP
    if (damager instanceof Player && victim instanceof Player) {
        Player attacker = (Player) damager;
        Player target = (Player) victim;
        
        // Заборонити PvP в спавні
        if (isInSpawn(target.getLocation())) {
            event.setCancelled(true);
            attacker.sendMessage("§cPvP заборонено в спавні!");
            return;
        }
        
        // Збільшити урон на 50%
        event.setDamage(event.getDamage() * 1.5);
    }
    
    // Стріла
    if (damager instanceof Arrow) {
        Arrow arrow = (Arrow) damager;
        if (arrow.getShooter() instanceof Player) {
            Player shooter = (Player) arrow.getShooter();
            shooter.sendMessage("§eВлучний постріл! §c❤ " + 
                String.format("%.1f", event.getFinalDamage()));
        }
    }
}
```

## Комплексний приклад

Система реферального коду:
```java
public class ReferralListener implements Listener {
    private Map<UUID, String> pendingReferrals = new HashMap<>();
    
    @EventHandler
    public void onChat(AsyncPlayerChatEvent event) {
        Player player = event.getPlayer();
        String message = event.getMessage();
        
        // Гравець вводить реф код
        if (pendingReferrals.containsKey(player.getUniqueId())) {
            event.setCancelled(true);
            
            Player referrer = Bukkit.getPlayer(message);
            if (referrer != null && referrer.isOnline()) {
                // Дати винагороду
                referrer.sendMessage("§a+ 100 монет за запрошення " + player.getName());
                player.sendMessage("§aВи отримали бонус від " + referrer.getName());
                
                pendingReferrals.remove(player.getUniqueId());
            } else {
                player.sendMessage("§cГравець не знайдений!");
            }
        }
    }
    
    @EventHandler
    public void onJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        
        if (!player.hasPlayedBefore()) {
            player.sendMessage("§eВведіть нікнейм того хто вас запросив (або skip):");
            pendingReferrals.put(player.getUniqueId(), "");
        }
    }
}
```',
  2, FALSE
);

-- Урок 3.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-3', 'lesson-3-3',
  'Custom Events - створення власних подій',
  '12 хв', 'text',
  '# Створення Custom Events

Ви можете створювати власні події для вашого плагіну!

## Навіщо Custom Events?

- Дозволити іншим плагінам інтегруватися з вашим
- Організувати код краще
- Дати можливість змінювати логіку

## Створення Custom Event

```java
import org.bukkit.entity.Player;
import org.bukkit.event.Cancellable;
import org.bukkit.event.Event;
import org.bukkit.event.HandlerList;

public class PlayerLevelUpEvent extends Event implements Cancellable {
    private static final HandlerList HANDLERS = new HandlerList();
    private boolean cancelled = false;
    
    private final Player player;
    private final int oldLevel;
    private final int newLevel;
    private String reward;
    
    public PlayerLevelUpEvent(Player player, int oldLevel, int newLevel, String reward) {
        this.player = player;
        this.oldLevel = oldLevel;
        this.newLevel = newLevel;
        this.reward = reward;
    }
    
    public Player getPlayer() {
        return player;
    }
    
    public int getOldLevel() {
        return oldLevel;
    }
    
    public int getNewLevel() {
        return newLevel;
    }
    
    public String getReward() {
        return reward;
    }
    
    public void setReward(String reward) {
        this.reward = reward;
    }
    
    @Override
    public boolean isCancelled() {
        return cancelled;
    }
    
    @Override
    public void setCancelled(boolean cancel) {
        this.cancelled = cancel;
    }
    
    @Override
    public HandlerList getHandlers() {
        return HANDLERS;
    }
    
    public static HandlerList getHandlerList() {
        return HANDLERS;
    }
}
```

## Виклик Custom Event

```java
public class LevelManager {
    
    public void addExperience(Player player, int amount) {
        int currentLevel = getLevel(player);
        int currentExp = getExp(player);
        
        currentExp += amount;
        
        // Перевірка рівня
        while (currentExp >= getExpForNextLevel(currentLevel)) {
            currentExp -= getExpForNextLevel(currentLevel);
            currentLevel++;
            
            // Викликаємо custom event
            PlayerLevelUpEvent event = new PlayerLevelUpEvent(
                player, 
                currentLevel - 1, 
                currentLevel,
                "100 монет"
            );
            
            Bukkit.getPluginManager().callEvent(event);
            
            // Перевірити чи event не скасований
            if (!event.isCancelled()) {
                setLevel(player, currentLevel);
                
                // Дати винагороду
                player.sendMessage("§aРівень підвищено! §e" + event.getReward());
            }
        }
        
        setExp(player, currentExp);
    }
}
```

## Слухання Custom Event

```java
public class LevelRewardListener implements Listener {
    
    @EventHandler
    public void onLevelUp(PlayerLevelUpEvent event) {
        Player player = event.getPlayer();
        int level = event.getNewLevel();
        
        // Особливі винагороди за певні рівні
        if (level == 10) {
            event.setReward("Діамантовий меч");
            player.getInventory().addItem(new ItemStack(Material.DIAMOND_SWORD));
        }
        
        if (level == 50) {
            event.setReward("§6★ VIP статус");
            // Дати VIP
        }
        
        // Ефекти
        player.playSound(player.getLocation(), Sound.ENTITY_PLAYER_LEVELUP, 1.0f, 1.0f);
        player.spawnParticle(Particle.TOTEM, player.getLocation(), 50);
        
        // Анонс
        if (level % 10 == 0) {
            Bukkit.broadcastMessage(
                "§e★ " + player.getName() + " §eдосяг рівня §6" + level + "§e!"
            );
        }
    }
    
    @EventHandler(priority = EventPriority.HIGH)
    public void onLevelUpCheck(PlayerLevelUpEvent event) {
        Player player = event.getPlayer();
        
        // Заборонити left якщо гравець в бою
        if (isInCombat(player)) {
            event.setCancelled(true);
            player.sendMessage("§cНе можна підвищити рівень в бою!");
        }
    }
}
```

## Async Custom Events

Для довгих операцій:
```java
public class AsyncDatabaseQueryEvent extends Event {
    private static final HandlerList HANDLERS = new HandlerList();
    private final UUID playerId;
    private final String query;
    
    public AsyncDatabaseQueryEvent(UUID playerId, String query) {
        super(true); // true = async event
        this.playerId = playerId;
        this.query = query;
    }
    
    // ... getters
    
    @Override
    public HandlerList getHandlers() {
        return HANDLERS;
    }
    
    public static HandlerList getHandlerList() {
        return HANDLERS;
    }
}
```

## Практичний приклад

Економічна система з custom events:
```java
public class MoneyTransferEvent extends Event implements Cancellable {
    private static final HandlerList HANDLERS = new HandlerList();
    private boolean cancelled = false;
    
    private final UUID from;
    private final UUID to;
    private double amount;
    private String reason;
    
    public MoneyTransferEvent(UUID from, UUID to, double amount, String reason) {
        this.from = from;
        this.to = to;
        this.amount = amount;
        this.reason = reason;
    }
    
    // Дозволити змінювати суму
    public void setAmount(double amount) {
        this.amount = amount;
    }
    
    // ... getters, cancelled, handlers
}

// Використання
public void transferMoney(UUID from, UUID to, double amount) {
    MoneyTransferEvent event = new MoneyTransferEvent(from, to, amount, "transfer");
    Bukkit.getPluginManager().callEvent(event);
    
    if (!event.isCancelled()) {
        // Виконати перевод
        removeMoney(from, event.getAmount());
        addMoney(to, event.getAmount());
    }
}
```

## Практичне завдання

Створіть custom event систему для PvP:
- `PlayerKillStreakEvent` (серія вбивств)
- `PlayerBountyPlacedEvent` (нагорода за голову)
- Інші плагіни мають змогу:
  - Змінювати винагороду
  - Додавати ефекти
  - Скасовувати події',
  3, FALSE
);

-- Квіз для Модуля 3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-3', 'lesson-3-4',
  'Тест: Event система',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-3-4",
    "questions": [
      {
        "id": "q1",
        "question": "Який інтерфейс потрібно імплементувати для Listener?",
        "options": ["EventHandler", "Listener", "EventListener", "BukkitListener"],
        "correctAnswer": 1,
        "explanation": "Клас має імплементувати інтерфейс Listener для обробки подій"
      },
      {
        "id": "q2",
        "question": "Яка анотація використовується для event методів?",
        "options": ["@Event", "@EventHandler", "@Listen", "@Handle"],
        "correctAnswer": 1,
        "explanation": "@EventHandler позначає метод як обробник події"
      },
      {
        "id": "q3",
        "question": "Який EventPriority виконається останнім?",
        "options": ["HIGHEST", "HIGH", "MONITOR", "LAST"],
        "correctAnswer": 2,
        "explanation": "EventPriority.MONITOR виконується останнім і призначений тільки для читання"
      },
      {
        "id": "q4",
        "question": "Як скасувати event?",
        "options": [
          "event.cancel()",
          "event.setCancelled(true)",
          "event.stop()",
          "return false"
        ],
        "correctAnswer": 1,
        "explanation": "event.setCancelled(true) скасовує подію (якщо вона implements Cancellable)"
      },
      {
        "id": "q5",
        "question": "Чому PlayerMoveEvent потрібно використовувати обережно?",
        "options": [
          "Він deprecated",
          "Викликається дуже часто (20+ разів/сек)",
          "Він async",
          "Його не можна скасувати"
        ],
        "correctAnswer": 1,
        "explanation": "PlayerMoveEvent викликається при кожному русі гравця, тому важкі операції можуть лагати сервер"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 3 додано! 4 уроки створено.' as status;
