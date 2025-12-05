-- =============================================
-- Модуль 9: Custom Items та GUI системи
-- =============================================

-- Урок 9.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-9', 'lesson-9-1',
  'ItemStack API - створення custom items',
  '18 хв', 'text',
  '# Custom Items з ItemStack API

Створюємо унікальні предмети з NBT даними та метою.

## ItemStack Builder

```java
import org.bukkit.Material;
import org.bukkit.enchantments.Enchantment;
import org.bukkit.inventory.ItemFlag;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;

public class ItemBuilder {
    
    private final ItemStack item;
    
    public ItemBuilder(Material material) {
        this.item = new ItemStack(material);
    }
    
    public ItemBuilder(Material material, int amount) {
        this.item = new ItemStack(material, amount);
    }
    
    public ItemBuilder setName(String name) {
        ItemMeta meta = item.getItemMeta();
        meta.setDisplayName(name);
        item.setItemMeta(meta);
        return this;
    }
    
    public ItemBuilder setLore(String... lore) {
        ItemMeta meta = item.getItemMeta();
        meta.setLore(Arrays.asList(lore));
        item.setItemMeta(meta);
        return this;
    }
    
    public ItemBuilder setLore(List<String> lore) {
        ItemMeta meta = item.getItemMeta();
        meta.setLore(lore);
        item.setItemMeta(meta);
        return this;
    }
    
    public ItemBuilder addEnchant(Enchantment enchant, int level) {
        item.addUnsafeEnchantment(enchant, level);
        return this;
    }
    
    public ItemBuilder setUnbreakable(boolean unbreakable) {
        ItemMeta meta = item.getItemMeta();
        meta.setUnbreakable(unbreakable);
        item.setItemMeta(meta);
        return this;
    }
    
    public ItemBuilder addFlags(ItemFlag... flags) {
        ItemMeta meta = item.getItemMeta();
        meta.addItemFlags(flags);
        item.setItemMeta(meta);
        return this;
    }
    
    public ItemBuilder setCustomModelData(int data) {
        ItemMeta meta = item.getItemMeta();
        meta.setCustomModelData(data);
        item.setItemMeta(meta);
        return this;
    }
    
    public ItemBuilder glow() {
        addEnchant(Enchantment.DURABILITY, 1);
        addFlags(ItemFlag.HIDE_ENCHANTS);
        return this;
    }
    
    public ItemStack build() {
        return item;
    }
}

// Використання
ItemStack sword = new ItemBuilder(Material.DIAMOND_SWORD)
    .setName("§6§lЛегендарний Меч")
    .setLore(
        "§7Урон: §c+50",
        "§7Швидкість: §a+10%",
        "",
        "§6§lЛЕГЕНДАРНИЙ МЕЧ"
    )
    .addEnchant(Enchantment.DAMAGE_ALL, 10)
    .addEnchant(Enchantment.FIRE_ASPECT, 2)
    .setUnbreakable(true)
    .addFlags(ItemFlag.HIDE_ATTRIBUTES, ItemFlag.HIDE_UNBREAKABLE)
    .build();
```

## PersistentDataContainer (NBT)

```java
import org.bukkit.NamespacedKey;
import org.bukkit.persistence.PersistentDataContainer;
import org.bukkit.persistence.PersistentDataType;

public class CustomItemManager {
    
    private final JavaPlugin plugin;
    
    public CustomItemManager(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    // Створити ключ
    private NamespacedKey createKey(String key) {
        return new NamespacedKey(plugin, key);
    }
    
    // Встановити NBT дані
    public ItemStack setCustomData(ItemStack item, String key, String value) {
        ItemMeta meta = item.getItemMeta();
        PersistentDataContainer data = meta.getPersistentDataContainer();
        
        data.set(createKey(key), PersistentDataType.STRING, value);
        
        item.setItemMeta(meta);
        return item;
    }
    
    // Отримати NBT дані
    public String getCustomData(ItemStack item, String key) {
        if (item == null || !item.hasItemMeta()) return null;
        
        ItemMeta meta = item.getItemMeta();
        PersistentDataContainer data = meta.getPersistentDataContainer();
        
        return data.get(createKey(key), PersistentDataType.STRING);
    }
    
    // Перевірити наявність NBT
    public boolean hasCustomData(ItemStack item, String key) {
        if (item == null || !item.hasItemMeta()) return false;
        
        ItemMeta meta = item.getItemMeta();
        PersistentDataContainer data = meta.getPersistentDataContainer();
        
        return data.has(createKey(key), PersistentDataType.STRING);
    }
    
    // Видалити NBT
    public ItemStack removeCustomData(ItemStack item, String key) {
        ItemMeta meta = item.getItemMeta();
        PersistentDataContainer data = meta.getPersistentDataContainer();
        
        data.remove(createKey(key));
        
        item.setItemMeta(meta);
        return item;
    }
    
    // Різні типи даних
    public ItemStack setInteger(ItemStack item, String key, int value) {
        ItemMeta meta = item.getItemMeta();
        meta.getPersistentDataContainer().set(
            createKey(key), 
            PersistentDataType.INTEGER, 
            value
        );
        item.setItemMeta(meta);
        return item;
    }
    
    public ItemStack setDouble(ItemStack item, String key, double value) {
        ItemMeta meta = item.getItemMeta();
        meta.getPersistentDataContainer().set(
            createKey(key), 
            PersistentDataType.DOUBLE, 
            value
        );
        item.setItemMeta(meta);
        return item;
    }
    
    public ItemStack setBoolean(ItemStack item, String key, boolean value) {
        ItemMeta meta = item.getItemMeta();
        meta.getPersistentDataContainer().set(
            createKey(key), 
            PersistentDataType.BYTE, 
            (byte) (value ? 1 : 0)
        );
        item.setItemMeta(meta);
        return item;
    }
}
```

## Custom Item Registry

```java
public class CustomItem {
    
    private final String id;
    private final ItemStack item;
    private final Consumer<PlayerInteractEvent> onInteract;
    
    public CustomItem(String id, ItemStack item, Consumer<PlayerInteractEvent> onInteract) {
        this.id = id;
        this.item = item;
        this.onInteract = onInteract;
    }
    
    public String getId() {
        return id;
    }
    
    public ItemStack getItem() {
        return item.clone();
    }
    
    public void handleInteract(PlayerInteractEvent event) {
        if (onInteract != null) {
            onInteract.accept(event);
        }
    }
}

public class CustomItemRegistry {
    
    private final Map<String, CustomItem> items = new HashMap<>();
    private final CustomItemManager dataManager;
    
    public CustomItemRegistry(CustomItemManager dataManager) {
        this.dataManager = dataManager;
    }
    
    // Зареєструвати custom item
    public void register(CustomItem customItem) {
        items.put(customItem.getId(), customItem);
    }
    
    // Отримати custom item
    public CustomItem get(String id) {
        return items.get(id);
    }
    
    // Створити ItemStack з NBT
    public ItemStack createItem(String id) {
        CustomItem customItem = items.get(id);
        if (customItem == null) return null;
        
        ItemStack item = customItem.getItem();
        return dataManager.setCustomData(item, "custom_item_id", id);
    }
    
    // Перевірити чи це custom item
    public boolean isCustomItem(ItemStack item, String id) {
        String itemId = dataManager.getCustomData(item, "custom_item_id");
        return id.equals(itemId);
    }
    
    // Отримати CustomItem з ItemStack
    public CustomItem getFromItem(ItemStack item) {
        String id = dataManager.getCustomData(item, "custom_item_id");
        return id != null ? items.get(id) : null;
    }
}
```

## Приклади Custom Items

```java
public class CustomItems {
    
    public static void registerItems(CustomItemRegistry registry, CustomItemManager dataManager) {
        
        // Телепортаційний жезл
        registry.register(new CustomItem(
            "teleport_wand",
            new ItemBuilder(Material.BLAZE_ROD)
                .setName("§5§lТелепортаційний Жезл")
                .setLore(
                    "§7ПКМ по блоку - телепортація",
                    "§7Кулдаун: §e5 секунд"
                )
                .glow()
                .build(),
            event -> {
                Player player = event.getPlayer();
                Block block = event.getClickedBlock();
                
                if (block != null && event.getAction().name().contains("RIGHT")) {
                    Location target = block.getLocation().add(0, 1, 0);
                    player.teleport(target);
                    player.sendMessage("§aТелепортовано!");
                    player.playSound(player.getLocation(), Sound.ENTITY_ENDERMAN_TELEPORT, 1f, 1f);
                }
            }
        ));
        
        // Хілка
        registry.register(new CustomItem(
            "healing_potion",
            new ItemBuilder(Material.POTION)
                .setName("§c§lЗцілююча Настоянка")
                .setLore(
                    "§7ПКМ - відновити §c❤ 10 HP",
                    "§7Використань: §e3"
                )
                .build(),
            event -> {
                Player player = event.getPlayer();
                ItemStack item = event.getItem();
                
                // Отримати використання
                int uses = dataManager.getCustomData(item, "uses") != null 
                    ? Integer.parseInt(dataManager.getCustomData(item, "uses"))
                    : 3;
                
                if (uses > 0) {
                    // Хіл
                    double health = Math.min(player.getHealth() + 10, player.getMaxHealth());
                    player.setHealth(health);
                    player.playSound(player.getLocation(), Sound.ENTITY_PLAYER_BURP, 1f, 1f);
                    
                    // Зменшити використання
                    uses--;
                    dataManager.setCustomData(item, "uses", String.valueOf(uses));
                    
                    // Оновити lore
                    ItemMeta meta = item.getItemMeta();
                    List<String> lore = meta.getLore();
                    lore.set(1, "§7Використань: §e" + uses);
                    meta.setLore(lore);
                    item.setItemMeta(meta);
                    
                    if (uses == 0) {
                        player.getInventory().remove(item);
                        player.sendMessage("§cНастоянка використана!");
                    }
                } else {
                    player.sendMessage("§cНемає використань!");
                }
            }
        ));
        
        // Зброя з рівнем
        registry.register(new CustomItem(
            "leveling_sword",
            new ItemBuilder(Material.IRON_SWORD)
                .setName("§6§lМеч що розвивається")
                .setLore(
                    "§7Рівень: §a1",
                    "§7Вбивств: §e0/10",
                    "§7Урон: §c+5"
                )
                .addEnchant(Enchantment.DAMAGE_ALL, 1)
                .build(),
            null  // Обробка в EntityDeathEvent
        ));
    }
}

// Event listener для custom items
@EventHandler
public void onInteract(PlayerInteractEvent event) {
    ItemStack item = event.getItem();
    if (item == null) return;
    
    CustomItem customItem = registry.getFromItem(item);
    if (customItem != null) {
        customItem.handleInteract(event);
        event.setCancelled(true);
    }
}

// Левелінг меча
@EventHandler
public void onKill(EntityDeathEvent event) {
    if (event.getEntity().getKiller() == null) return;
    
    Player killer = event.getEntity().getKiller();
    ItemStack weapon = killer.getInventory().getItemInMainHand();
    
    if (registry.isCustomItem(weapon, "leveling_sword")) {
        // Отримати поточні вбивства
        String killsStr = dataManager.getCustomData(weapon, "kills");
        int kills = killsStr != null ? Integer.parseInt(killsStr) : 0;
        kills++;
        
        // Отримати рівень
        String levelStr = dataManager.getCustomData(weapon, "level");
        int level = levelStr != null ? Integer.parseInt(levelStr) : 1;
        
        int killsNeeded = level * 10;
        
        if (kills >= killsNeeded) {
            // Підвищити рівень
            level++;
            kills = 0;
            
            dataManager.setCustomData(weapon, "level", String.valueOf(level));
            
            // Оновити енчанти
            weapon.removeEnchantment(Enchantment.DAMAGE_ALL);
            weapon.addUnsafeEnchantment(Enchantment.DAMAGE_ALL, level);
            
            killer.sendMessage("§6§lМеч підвищився до рівня " + level + "!");
            killer.playSound(killer.getLocation(), Sound.ENTITY_PLAYER_LEVELUP, 1f, 1f);
        }
        
        dataManager.setCustomData(weapon, "kills", String.valueOf(kills));
        
        // Оновити lore
        ItemMeta meta = weapon.getItemMeta();
        List<String> lore = meta.getLore();
        lore.set(0, "§7Рівень: §a" + level);
        lore.set(1, "§7Вбивств: §e" + kills + "/" + (level * 10));
        lore.set(2, "§7Урон: §c+" + (5 * level));
        meta.setLore(lore);
        weapon.setItemMeta(meta);
    }
}
```

## Skull з текстурою гравця

```java
import org.bukkit.inventory.meta.SkullMeta;

public ItemStack getPlayerHead(String playerName) {
    ItemStack skull = new ItemStack(Material.PLAYER_HEAD);
    SkullMeta meta = (SkullMeta) skull.getItemMeta();
    
    meta.setOwningPlayer(Bukkit.getOfflinePlayer(playerName));
    meta.setDisplayName("§eГолова " + playerName);
    
    skull.setItemMeta(meta);
    return skull;
}

// Custom текстура (Base64)
public ItemStack getCustomHead(String texture) {
    ItemStack skull = new ItemStack(Material.PLAYER_HEAD);
    SkullMeta meta = (SkullMeta) skull.getItemMeta();
    
    GameProfile profile = new GameProfile(UUID.randomUUID(), null);
    profile.getProperties().put("textures", 
        new Property("textures", texture));
    
    try {
        Field profileField = meta.getClass().getDeclaredField("profile");
        profileField.setAccessible(true);
        profileField.set(meta, profile);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    skull.setItemMeta(meta);
    return skull;
}
```

## Практичне завдання

Створіть систему custom items:
1. ItemBuilder для легкого створення
2. PersistentDataContainer для NBT даних
3. CustomItemRegistry для реєстрації
4. 3 custom items (телепорт жезл, хілка, меч що левелиться)
5. Event handlers для взаємодії',
  1, FALSE
);

-- Урок 9.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-9', 'lesson-9-2',
  'GUI системи - Inventory API',
  '20 хв', 'text',
  '# Custom GUI з Inventory API

Створення інтерактивних меню для гравців.

## Базовий GUI клас

```java
import org.bukkit.Bukkit;
import org.bukkit.entity.Player;
import org.bukkit.event.inventory.InventoryClickEvent;
import org.bukkit.inventory.Inventory;
import org.bukkit.inventory.InventoryHolder;

public abstract class GUI implements InventoryHolder {
    
    protected Inventory inventory;
    protected String title;
    protected int size;
    
    public GUI(String title, int rows) {
        this.title = title;
        this.size = rows * 9;
        this.inventory = Bukkit.createInventory(this, size, title);
    }
    
    @Override
    public Inventory getInventory() {
        return inventory;
    }
    
    // Абстрактні методи
    public abstract void setItems();
    public abstract void handleClick(InventoryClickEvent event);
    
    // Відкрити GUI
    public void open(Player player) {
        setItems();
        player.openInventory(inventory);
    }
}
```

## GUI Manager

```java
public class GUIManager implements Listener {
    
    private final JavaPlugin plugin;
    
    public GUIManager(JavaPlugin plugin) {
        this.plugin = plugin;
        plugin.getServer().getPluginManager().registerEvents(this, plugin);
    }
    
    @EventHandler
    public void onClick(InventoryClickEvent event) {
        if (event.getClickedInventory() == null) return;
        
        InventoryHolder holder = event.getInventory().getHolder();
        
        if (holder instanceof GUI) {
            event.setCancelled(true);  // Заборонити переміщення items
            
            GUI gui = (GUI) holder;
            gui.handleClick(event);
        }
    }
}
```

## Приклад: Main Menu

```java
public class MainMenuGUI extends GUI {
    
    public MainMenuGUI() {
        super("§6§lГоловне Меню", 3);  // 3 ряди
    }
    
    @Override
    public void setItems() {
        // Заповнити фон
        ItemStack filler = new ItemBuilder(Material.GRAY_STAINED_GLASS_PANE)
            .setName(" ")
            .build();
        
        for (int i = 0; i < size; i++) {
            inventory.setItem(i, filler);
        }
        
        // Кнопки
        inventory.setItem(11, new ItemBuilder(Material.DIAMOND_SWORD)
            .setName("§c§lАрена")
            .setLore("§7Клікни для входу в арену")
            .build());
        
        inventory.setItem(13, new ItemBuilder(Material.CHEST)
            .setName("§e§lМагазин")
            .setLore("§7Купуй різні предмети")
            .build());
        
        inventory.setItem(15, new ItemBuilder(Material.BOOK)
            .setName("§b§lПрофіль")
            .setLore("§7Подивись свою статистику")
            .build());
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player player = (Player) event.getWhoClicked();
        int slot = event.getSlot();
        
        switch (slot) {
            case 11:  // Арена
                player.closeInventory();
                player.sendMessage("§aТелепортація в арену...");
                // Логіка телепортації
                break;
                
            case 13:  // Магазин
                new ShopGUI().open(player);
                break;
                
            case 15:  // Профіль
                new ProfileGUI(player).open(player);
                break;
        }
    }
}
```

## Paginated GUI (з сторінками)

```java
public class PaginatedGUI extends GUI {
    
    private int currentPage = 0;
    private final List<ItemStack> items;
    private final int itemsPerPage = 45;  // 5 рядів по 9
    
    public PaginatedGUI(String title, List<ItemStack> items) {
        super(title, 6);  // 6 рядів
        this.items = items;
    }
    
    @Override
    public void setItems() {
        inventory.clear();
        
        // Предмети для поточної сторінки
        int start = currentPage * itemsPerPage;
        int end = Math.min(start + itemsPerPage, items.size());
        
        for (int i = start; i < end; i++) {
            inventory.setItem(i - start, items.get(i));
        }
        
        // Навігація
        if (currentPage > 0) {
            inventory.setItem(48, new ItemBuilder(Material.ARROW)
                .setName("§e◀ Попередня сторінка")
                .build());
        }
        
        if (end < items.size()) {
            inventory.setItem(50, new ItemBuilder(Material.ARROW)
                .setName("§eНаступна сторінка ▶")
                .build());
        }
        
        // Інфо
        inventory.setItem(49, new ItemBuilder(Material.PAPER)
            .setName("§6Сторінка " + (currentPage + 1) + "/" + getTotalPages())
            .build());
    }
    
    private int getTotalPages() {
        return (int) Math.ceil((double) items.size() / itemsPerPage);
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player player = (Player) event.getWhoClicked();
        int slot = event.getSlot();
        
        if (slot == 48 && currentPage > 0) {
            // Попередня сторінка
            currentPage--;
            setItems();
            
        } else if (slot == 50 && (currentPage + 1) < getTotalPages()) {
            // Наступна сторінка
            currentPage++;
            setItems();
            
        } else if (slot < itemsPerPage) {
            // Клік по предмету
            ItemStack clicked = event.getCurrentItem();
            if (clicked != null && clicked.getType() != Material.AIR) {
                player.sendMessage("§aВи вибрали: " + clicked.getItemMeta().getDisplayName());
            }
        }
    }
}
```

## Confirmation GUI

```java
public class ConfirmGUI extends GUI {
    
    private final Runnable onConfirm;
    private final Runnable onCancel;
    
    public ConfirmGUI(String question, Runnable onConfirm, Runnable onCancel) {
        super("§cПідтвердження", 3);
        this.onConfirm = onConfirm;
        this.onCancel = onCancel;
        
        // Додати питання в title не можна, тому в центр
        inventory.setItem(13, new ItemBuilder(Material.PAPER)
            .setName("§e" + question)
            .build());
    }
    
    @Override
    public void setItems() {
        // Зелені скло (Так)
        ItemStack yes = new ItemBuilder(Material.GREEN_STAINED_GLASS_PANE)
            .setName("§a§lТАК")
            .setLore("§7Клікни для підтвердження")
            .build();
        
        for (int i = 0; i < 9; i++) {
            inventory.setItem(i, yes);
            inventory.setItem(i + 9, yes);
        }
        
        // Червоні скло (Ні)
        ItemStack no = new ItemBuilder(Material.RED_STAINED_GLASS_PANE)
            .setName("§c§lНІ")
            .setLore("§7Клікни для скасування")
            .build();
        
        for (int i = 18; i < 27; i++) {
            inventory.setItem(i, no);
        }
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player player = (Player) event.getWhoClicked();
        int slot = event.getSlot();
        
        player.closeInventory();
        
        if (slot < 18) {
            // ТАК
            if (onConfirm != null) {
                onConfirm.run();
            }
        } else {
            // НІ
            if (onCancel != null) {
                onCancel.run();
            }
        }
    }
}

// Використання
new ConfirmGUI(
    "Видалити свій дім?",
    () -> {
        player.sendMessage("§cДім видалено!");
        deleteHome(player);
    },
    () -> {
        player.sendMessage("§eСкасовано");
    }
).open(player);
```

## Player Selector GUI

```java
public class PlayerSelectorGUI extends PaginatedGUI {
    
    private final Consumer<Player> onSelect;
    
    public PlayerSelectorGUI(Consumer<Player> onSelect) {
        super("§6Вибір гравця", getPlayerHeads());
        this.onSelect = onSelect;
    }
    
    private static List<ItemStack> getPlayerHeads() {
        List<ItemStack> heads = new ArrayList<>();
        
        for (Player online : Bukkit.getOnlinePlayers()) {
            ItemStack head = new ItemBuilder(Material.PLAYER_HEAD)
                .setName("§e" + online.getName())
                .setLore(
                    "§7Здоров''я: §c" + online.getHealth() + "/" + player.getMaxHealth(),
                    "§7Рівень: §a" + online.getLevel(),
                    "",
                    "§eКлікни для вибору"
                )
                .build();
            
            SkullMeta meta = (SkullMeta) head.getItemMeta();
            meta.setOwningPlayer(online);
            head.setItemMeta(meta);
            
            heads.add(head);
        }
        
        return heads;
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player clicker = (Player) event.getWhoClicked();
        ItemStack clicked = event.getCurrentItem();
        
        if (clicked != null && clicked.getType() == Material.PLAYER_HEAD) {
            SkullMeta meta = (SkullMeta) clicked.getItemMeta();
            Player target = meta.getOwningPlayer().getPlayer();
            
            if (target != null && target.isOnline()) {
                clicker.closeInventory();
                onSelect.accept(target);
            } else {
                clicker.sendMessage("§cГравець не в мережі!");
            }
        }
        
        super.handleClick(event);  // Навігація
    }
}

// Використання
new PlayerSelectorGUI(target -> {
    player.sendMessage("§aВи вибрали: " + target.getName());
    player.teleport(target);
}).open(player);
```

## Input GUI (anvil)

```java
import org.bukkit.event.inventory.PrepareAnvilEvent;

public class InputGUI {
    
    public static void open(Player player, String defaultText, Consumer<String> onInput) {
        Inventory anvil = Bukkit.createInventory(null, InventoryType.ANVIL, "§6Введіть текст");
        
        ItemStack paper = new ItemBuilder(Material.PAPER)
            .setName(defaultText)
            .build();
        
        anvil.setItem(0, paper);
        
        player.openInventory(anvil);
        
        // Обробка в event listener
        new BukkitRunnable() {
            @Override
            public void run() {
                if (!player.getOpenInventory().getType().equals(InventoryType.ANVIL)) {
                    cancel();
                    return;
                }
                
                ItemStack result = player.getOpenInventory().getItem(2);
                if (result != null && result.hasItemMeta()) {
                    String input = result.getItemMeta().getDisplayName();
                    player.closeInventory();
                    onInput.accept(input);
                    cancel();
                }
            }
        }.runTaskTimer(plugin, 10L, 5L);
    }
}
```

## Animated GUI

```java
public class LoadingGUI extends GUI {
    
    private int frame = 0;
    private BukkitTask task;
    
    public LoadingGUI() {
        super("§6§lЗавантаження...", 3);
    }
    
    @Override
    public void setItems() {
        // Анімація завантаження
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        // Блокувати кліки
    }
    
    @Override
    public void open(Player player) {
        super.open(player);
        
        // Запустити анімацію
        task = new BukkitRunnable() {
            @Override
            public void run() {
                frame = (frame + 1) % 8;
                updateAnimation();
            }
        }.runTaskTimer(plugin, 0L, 5L);
    }
    
    private void updateAnimation() {
        ItemStack loading = new ItemBuilder(Material.LIME_STAINED_GLASS_PANE)
            .setName("§a■")
            .build();
        
        ItemStack empty = new ItemBuilder(Material.GRAY_STAINED_GLASS_PANE)
            .setName("§7□")
            .build();
        
        for (int i = 0; i < 9; i++) {
            inventory.setItem(i + 9, i == frame ? loading : empty);
        }
    }
    
    public void close(Player player) {
        if (task != null) {
            task.cancel();
        }
        player.closeInventory();
    }
}
```

## Практичне завдання

Створіть GUI систему:
1. GUI базовий клас
2. GUIManager для обробки кліків
3. MainMenuGUI з кнопками
4. PaginatedGUI для списків
5. ConfirmGUI для підтвердження дій
6. PlayerSelectorGUI для вибору гравців',
  2, FALSE
);

-- Урок 9.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-9', 'lesson-9-3',
  'Advanced GUI - Shop, Crafting, Storage',
  '16 хв', 'text',
  '# Advanced GUI Patterns

Складні GUI системи для магазинів, крафтів та сховищ.

## Shop GUI з транзакціями

```java
public class ShopGUI extends PaginatedGUI {
    
    private final Map<Integer, ShopItem> shopItems = new HashMap<>();
    
    public static class ShopItem {
        ItemStack display;
        double price;
        Runnable onPurchase;
        
        public ShopItem(ItemStack display, double price, Runnable onPurchase) {
            this.display = display;
            this.price = price;
            this.onPurchase = onPurchase;
        }
    }
    
    public ShopGUI() {
        super("§6§lМагазин", createDisplayItems());
        setupShopItems();
    }
    
    private void setupShopItems() {
        // Предмет 1
        shopItems.put(0, new ShopItem(
            new ItemBuilder(Material.DIAMOND_SWORD)
                .setName("§bАлмазний Меч")
                .setLore("§7Ціна: §e$500")
                .build(),
            500,
            () -> {
                // Логіка покупки
            }
        ));
        
        // Предмет 2
        shopItems.put(1, new ShopItem(
            new ItemBuilder(Material.GOLDEN_APPLE)
                .setName("§6Золоте Яблуко")
                .setLore("§7Ціна: §e$100")
                .build(),
            100,
            null
        ));
    }
    
    private static List<ItemStack> createDisplayItems() {
        List<ItemStack> items = new ArrayList<>();
        // Додати всі shop items
        return items;
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player player = (Player) event.getWhoClicked();
        int slot = event.getSlot();
        
        if (slot < 45 && shopItems.containsKey(slot)) {
            ShopItem item = shopItems.get(slot);
            
            // Перевірити баланс
            double balance = economy.getBalance(player.getUniqueId());
            
            if (balance >= item.price) {
                // Підтвердження
                new ConfirmGUI(
                    "Купити за $" + item.price + "?",
                    () -> {
                        economy.removeBalance(player.getUniqueId(), item.price);
                        
                        if (item.onPurchase != null) {
                            item.onPurchase.run();
                        } else {
                            // Видати предмет
                            player.getInventory().addItem(item.display.clone());
                        }
                        
                        player.sendMessage("§aКуплено!");
                        open(player);  // Відкрити магазин знову
                    },
                    () -> open(player)
                ).open(player);
                
            } else {
                player.sendMessage("§cНедостатньо коштів! Потрібно: $" + item.price);
                player.closeInventory();
            }
        }
        
        super.handleClick(event);
    }
}
```

## Custom Crafting GUI

```java
public class CustomCraftingGUI extends GUI {
    
    private final Map<String, CustomRecipe> recipes = new HashMap<>();
    
    public static class CustomRecipe {
        Map<Integer, ItemStack> ingredients;  // slot -> item
        ItemStack result;
        
        public CustomRecipe(ItemStack result) {
            this.ingredients = new HashMap<>();
            this.result = result;
        }
        
        public CustomRecipe addIngredient(int slot, ItemStack item) {
            ingredients.put(slot, item);
            return this;
        }
        
        public boolean matches(Inventory craftingInv) {
            for (Map.Entry<Integer, ItemStack> entry : ingredients.entrySet()) {
                ItemStack required = entry.getValue();
                ItemStack actual = craftingInv.getItem(entry.getKey());
                
                if (actual == null || !actual.isSimilar(required) || 
                    actual.getAmount() < required.getAmount()) {
                    return false;
                }
            }
            return true;
        }
    }
    
    public CustomCraftingGUI() {
        super("§6Custom Crafting", 6);
        setupRecipes();
    }
    
    private void setupRecipes() {
        // Рецепт: Legendary Sword
        CustomRecipe legendSword = new CustomRecipe(
            new ItemBuilder(Material.DIAMOND_SWORD)
                .setName("§6§lЛегендарний Меч")
                .addEnchant(Enchantment.DAMAGE_ALL, 10)
                .glow()
                .build()
        );
        legendSword.addIngredient(10, new ItemStack(Material.DIAMOND, 16));
        legendSword.addIngredient(11, new ItemStack(Material.NETHER_STAR, 1));
        legendSword.addIngredient(12, new ItemStack(Material.DIAMOND, 16));
        legendSword.addIngredient(19, new ItemStack(Material.BLAZE_ROD, 1));
        
        recipes.put("legend_sword", legendSword);
    }
    
    @Override
    public void setItems() {
        // Фон
        ItemStack filler = new ItemBuilder(Material.GRAY_STAINED_GLASS_PANE)
            .setName(" ")
            .build();
        
        for (int i = 0; i < size; i++) {
            inventory.setItem(i, filler);
        }
        
        // Crafting slots (3x3)
        int[] craftSlots = {10, 11, 12, 19, 20, 21, 28, 29, 30};
        for (int slot : craftSlots) {
            inventory.setItem(slot, null);
        }
        
        // Result slot
        inventory.setItem(24, null);
        
        // Craft button
        inventory.setItem(42, new ItemBuilder(Material.CRAFTING_TABLE)
            .setName("§a§lСТВОРИТИ")
            .setLore("§7Клікни для крафту")
            .build());
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player player = (Player) event.getWhoClicked();
        int slot = event.getSlot();
        
        // Дозволити клік в crafting slots
        int[] craftSlots = {10, 11, 12, 19, 20, 21, 28, 29, 30};
        if (Arrays.stream(craftSlots).anyMatch(s -> s == slot)) {
            event.setCancelled(false);
            
            // Перевірити рецепти після кліку
            new BukkitRunnable() {
                @Override
                public void run() {
                    checkRecipes(player);
                }
            }.runTaskLater(plugin, 1L);
            return;
        }
        
        // Craft button
        if (slot == 42) {
            craftItem(player);
        }
    }
    
    private void checkRecipes(Player player) {
        for (CustomRecipe recipe : recipes.values()) {
            if (recipe.matches(inventory)) {
                // Показати результат
                inventory.setItem(24, recipe.result.clone());
                return;
            }
        }
        
        // Немає відповідного рецепту
        inventory.setItem(24, null);
    }
    
    private void craftItem(Player player) {
        ItemStack result = inventory.getItem(24);
        
        if (result == null || result.getType() == Material.AIR) {
            player.sendMessage("§cПоставте інгредієнти!");
            return;
        }
        
        // Знайти рецепт
        for (CustomRecipe recipe : recipes.values()) {
            if (recipe.matches(inventory)) {
                // Видалити інгредієнти
                for (Map.Entry<Integer, ItemStack> entry : recipe.ingredients.entrySet()) {
                    ItemStack slot = inventory.getItem(entry.getKey());
                    slot.setAmount(slot.getAmount() - entry.getValue().getAmount());
                }
                
                // Видати результат
                player.getInventory().addItem(recipe.result.clone());
                player.sendMessage("§aПредмет створено!");
                player.playSound(player.getLocation(), Sound.BLOCK_ANVIL_USE, 1f, 1f);
                
                // Очистити result slot
                inventory.setItem(24, null);
                return;
            }
        }
    }
}
```

## Personal Storage GUI

```java
public class StorageGUI extends GUI {
    
    private final UUID owner;
    private final int storageSize;
    
    public StorageGUI(UUID owner, int rows) {
        super("§6§lСховище", rows + 1);  // +1 для інфо
        this.owner = owner;
        this.storageSize = rows * 9;
    }
    
    @Override
    public void setItems() {
        // Завантажити items з БД
        loadStorageFromDatabase();
        
        // Інфо панель (нижній ряд)
        int infoRow = size - 9;
        
        inventory.setItem(infoRow, new ItemBuilder(Material.CHEST)
            .setName("§6Місткість")
            .setLore("§7" + getUsedSlots() + "/" + storageSize)
            .build());
        
        inventory.setItem(infoRow + 4, new ItemBuilder(Material.BARRIER)
            .setName("§c§lОчистити все")
            .setLore("§7ПКМ для підтвердження")
            .build());
        
        inventory.setItem(infoRow + 8, new ItemBuilder(Material.HOPPER)
            .setName("§a§lЗберегти")
            .setLore("§7Автозбереження при закритті")
            .build());
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player player = (Player) event.getWhoClicked();
        int slot = event.getSlot();
        
        // Дозволити взаємодію зі storage slots
        if (slot < storageSize) {
            event.setCancelled(false);
            return;
        }
        
        // Очистити
        if (slot == size - 5 && event.isRightClick()) {
            new ConfirmGUI(
                "Очистити сховище?",
                () -> {
                    clearStorage();
                    player.sendMessage("§cСховище очищено!");
                    open(player);
                },
                () -> open(player)
            ).open(player);
        }
    }
    
    private void loadStorageFromDatabase() {
        // Завантажити з БД async
        Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
            List<ItemStack> items = database.loadStorage(owner);
            
            Bukkit.getScheduler().runTask(plugin, () -> {
                for (int i = 0; i < items.size() && i < storageSize; i++) {
                    inventory.setItem(i, items.get(i));
                }
            });
        });
    }
    
    public void saveStorage() {
        List<ItemStack> items = new ArrayList<>();
        
        for (int i = 0; i < storageSize; i++) {
            ItemStack item = inventory.getItem(i);
            if (item != null && item.getType() != Material.AIR) {
                items.add(item);
            }
        }
        
        // Зберегти async
        Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
            database.saveStorage(owner, items);
        });
    }
    
    private int getUsedSlots() {
        int used = 0;
        for (int i = 0; i < storageSize; i++) {
            ItemStack item = inventory.getItem(i);
            if (item != null && item.getType() != Material.AIR) {
                used++;
            }
        }
        return used;
    }
    
    private void clearStorage() {
        for (int i = 0; i < storageSize; i++) {
            inventory.setItem(i, null);
        }
        saveStorage();
    }
}

// Auto-save при закритті
@EventHandler
public void onClose(InventoryCloseEvent event) {
    if (event.getInventory().getHolder() instanceof StorageGUI) {
        StorageGUI storage = (StorageGUI) event.getInventory().getHolder();
        storage.saveStorage();
    }
}
```

## Trading GUI (між гравцями)

```java
public class TradeGUI extends GUI {
    
    private final Player player1;
    private final Player player2;
    private boolean player1Ready = false;
    private boolean player2Ready = false;
    
    public TradeGUI(Player player1, Player player2) {
        super("§6Торгівля", 6);
        this.player1 = player1;
        this.player2 = player2;
    }
    
    @Override
    public void setItems() {
        // Розділювач
        ItemStack divider = new ItemBuilder(Material.GRAY_STAINED_GLASS_PANE)
            .setName(" ")
            .build();
        
        for (int i = 0; i < 6; i++) {
            inventory.setItem(i * 9 + 4, divider);
        }
        
        // Ready buttons
        updateReadyButtons();
    }
    
    @Override
    public void handleClick(InventoryClickEvent event) {
        Player clicker = (Player) event.getWhoClicked();
        int slot = event.getSlot();
        
        // Player 1 slots (0-3, 9-12, 18-21, 27-30)
        // Player 2 slots (5-8, 14-17, 23-26, 32-35)
        
        if (clicker.equals(player1)) {
            // Дозволити тільки ліву половину
            if (slot % 9 < 4) {
                event.setCancelled(false);
                resetReady();
            } else if (slot == 45) {
                toggleReady(true);
            }
        } else if (clicker.equals(player2)) {
            // Дозволити тільки праву половину  
            if (slot % 9 > 4 && slot % 9 < 9) {
                event.setCancelled(false);
                resetReady();
            } else if (slot == 53) {
                toggleReady(false);
            }
        }
        
        // Перевірити чи обидва готові
        if (player1Ready && player2Ready) {
            completeTrade();
        }
    }
    
    private void toggleReady(boolean isPlayer1) {
        if (isPlayer1) {
            player1Ready = !player1Ready;
        } else {
            player2Ready = !player2Ready;
        }
        updateReadyButtons();
    }
    
    private void resetReady() {
        player1Ready = false;
        player2Ready = false;
        updateReadyButtons();
    }
    
    private void updateReadyButtons() {
        inventory.setItem(45, new ItemBuilder(
            player1Ready ? Material.LIME_STAINED_GLASS_PANE : Material.RED_STAINED_GLASS_PANE
        )
            .setName(player1Ready ? "§a✓ Готовий" : "§c✗ Не готовий")
            .build());
        
        inventory.setItem(53, new ItemBuilder(
            player2Ready ? Material.LIME_STAINED_GLASS_PANE : Material.RED_STAINED_GLASS_PANE
        )
            .setName(player2Ready ? "§a✓ Готовий" : "§c✗ Не готовий")
            .build());
    }
    
    private void completeTrade() {
        // Зібрати items гравців
        List<ItemStack> p1Items = new ArrayList<>();
        List<ItemStack> p2Items = new ArrayList<>();
        
        // ... collect items logic
        
        // Обмін
        p1Items.forEach(item -> player2.getInventory().addItem(item));
        p2Items.forEach(item -> player1.getInventory().addItem(item));
        
        player1.sendMessage("§aОбмін завершено!");
        player2.sendMessage("§aОбмін завершено!");
        
        player1.closeInventory();
        player2.closeInventory();
    }
}
```

## Практичне завдання

Створіть advanced GUI:
1. ShopGUI з категоріями та транзакціями
2. CustomCraftingGUI з власними рецептами
3. StorageGUI з збереженням в БД
4. TradeGUI для обміну між гравцями
5. Auto-save при закритті',
  3, FALSE
);

-- Квіз для Модуля 9
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-9', 'lesson-9-4',
  'Тест: Custom Items та GUI',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-9-4",
    "questions": [
      {
        "id": "q1",
        "question": "Що таке PersistentDataContainer?",
        "options": [
          "База даних",
          "NBT система для збереження custom даних в items",
          "Inventory API",
          "Config файл"
        ],
        "correctAnswer": 1,
        "explanation": "PersistentDataContainer - NBT система в Bukkit для збереження власних даних в ItemStack"
      },
      {
        "id": "q2",
        "question": "Як заборонити переміщення items в custom GUI?",
        "options": [
          "inventory.lock()",
          "event.setCancelled(true) в InventoryClickEvent",
          "inventory.setMovable(false)",
          "Не можна заборонити"
        ],
        "correctAnswer": 1,
        "explanation": "event.setCancelled(true) в InventoryClickEvent handler заборонить будь-яку взаємодію з GUI"
      },
      {
        "id": "q3",
        "question": "Що таке ItemBuilder pattern?",
        "options": [
          "Bukkit клас",
          "Зручний спосіб створення ItemStack з методами-ланцюжками",
          "GUI система",
          "Event listener"
        ],
        "correctAnswer": 1,
        "explanation": "ItemBuilder - custom клас що спрощує створення ItemStack використовуючи builder pattern"
      },
      {
        "id": "q4",
        "question": "Як створити GUI з декількома сторінками?",
        "options": [
          "Використати PaginatedGUI pattern",
          "Створити багато Inventory",
          "Bukkit API автоматично додає сторінки",
          "Не можна створити"
        ],
        "correctAnswer": 0,
        "explanation": "PaginatedGUI pattern дозволяє створити GUI з навігацією між сторінками"
      },
      {
        "id": "q5",
        "question": "Чому треба implements InventoryHolder в GUI класі?",
        "options": [
          "Обов''язкова вимога Bukkit",
          "Щоб ідентифікувати custom GUI в event handlers",
          "Для збереження inventory",
          "Для анімацій"
        ],
        "correctAnswer": 1,
        "explanation": "InventoryHolder дозволяє отримати GUI клас з inventory і обробити кліки правильно"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 9 додано! 4 уроки створено.' as status;
