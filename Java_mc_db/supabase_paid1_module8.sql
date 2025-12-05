-- =============================================
-- Модуль 8: Packet manipulation (ProtocolLib)
-- =============================================

-- Урок 8.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-8', 'lesson-8-1',
  'ProtocolLib - основи роботи з пакетами',
  '20 хв', 'text',
  '# ProtocolLib - робота з пакетами Minecraft

ProtocolLib дозволяє перехоплювати та модифікувати пакети між клієнтом і сервером.

## Встановлення ProtocolLib

1. Завантажити з SpigotMC: https://www.spigotmc.org/resources/protocollib.1997/
2. Покласти в папку `plugins/`
3. Перезапустити сервер

## Додати залежність

pom.xml:
```xml
<repositories>
    <repository>
        <id>dmulloy2-repo</id>
        <url>https://repo.dmulloy2.net/repository/public/</url>
    </repository>
</repositories>

<dependencies>
    <dependency>
        <groupId>com.comphenix.protocol</groupId>
        <artifactId>ProtocolLib</artifactId>
        <version>5.1.0</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

plugin.yml:
```yaml
depend: [ProtocolLib]
```

## Перший PacketAdapter

```java
import com.comphenix.protocol.PacketType;
import com.comphenix.protocol.ProtocolLibrary;
import com.comphenix.protocol.ProtocolManager;
import com.comphenix.protocol.events.PacketAdapter;
import com.comphenix.protocol.events.PacketEvent;

public class PacketListenerExample extends JavaPlugin {
    
    private ProtocolManager protocolManager;
    
    @Override
    public void onEnable() {
        protocolManager = ProtocolLibrary.getProtocolManager();
        
        // Реєструємо listener
        protocolManager.addPacketListener(new PacketAdapter(
            this,
            PacketType.Play.Client.CHAT
        ) {
            @Override
            public void onPacketReceiving(PacketEvent event) {
                // Перехоплюємо повідомлення від клієнта
                String message = event.getPacket().getStrings().read(0);
                
                Player player = event.getPlayer();
                getLogger().info(player.getName() + " написав: " + message);
                
                // Скасувати пакет (повідомлення не надійде)
                // event.setCancelled(true);
            }
        });
    }
}
```

## Типи пакетів

```java
public class PacketTypes {
    
    public void registerListeners() {
        ProtocolManager pm = ProtocolLibrary.getProtocolManager();
        
        // CLIENT → SERVER (отримання)
        pm.addPacketListener(new PacketAdapter(
            plugin,
            PacketType.Play.Client.POSITION,           // Рух гравця
            PacketType.Play.Client.BLOCK_DIG,          // Копання блоку
            PacketType.Play.Client.USE_ITEM,           // Використання предмета
            PacketType.Play.Client.WINDOW_CLICK,       // Клік в інвентарі
            PacketType.Play.Client.ARM_ANIMATION       // Махання рукою
        ) {
            @Override
            public void onPacketReceiving(PacketEvent event) {
                PacketType type = event.getPacketType();
                // Обробка різних типів
            }
        });
        
        // SERVER → CLIENT (відправка)
        pm.addPacketListener(new PacketAdapter(
            plugin,
            PacketType.Play.Server.SPAWN_ENTITY,       // Спавн entity
            PacketType.Play.Server.ENTITY_METADATA,    // Метадані entity
            PacketType.Play.Server.CHAT,               // Повідомлення
            PacketType.Play.Server.TITLE,              // Title екран
            PacketType.Play.Server.BLOCK_CHANGE        // Зміна блоку
        ) {
            @Override
            public void onPacketSending(PacketEvent event) {
                PacketType type = event.getPacketType();
                // Обробка різних типів
            }
        });
    }
}
```

## Читання даних з пакету

```java
@Override
public void onPacketReceiving(PacketEvent event) {
    PacketContainer packet = event.getPacket();
    
    // Строки
    String text = packet.getStrings().read(0);
    
    // Цілі числа
    int value = packet.getIntegers().read(0);
    
    // Float
    float health = packet.getFloat().read(0);
    
    // Boolean
    boolean sneaking = packet.getBooleans().read(0);
    
    // Enum
    EnumWrappers.Hand hand = packet.getHands().read(0);
    
    // Location/Position
    BlockPosition pos = packet.getBlockPositionModifier().read(0);
    
    // ItemStack
    ItemStack item = packet.getItemModifier().read(0);
}
```

## Модифікація пакетів

```java
// Змінити повідомлення в чаті
pm.addPacketListener(new PacketAdapter(
    plugin,
    PacketType.Play.Server.CHAT
) {
    @Override
    public void onPacketSending(PacketEvent event) {
        PacketContainer packet = event.getPacket();
        
        // Читаємо оригінальне повідомлення
        WrappedChatComponent original = packet.getChatComponents().read(0);
        String text = original.getJson();
        
        // Змінюємо текст
        String modified = text.replace("hello", "привіт");
        
        // Записуємо назад
        packet.getChatComponents().write(0, 
            WrappedChatComponent.fromJson(modified)
        );
    }
});
```

## Відправка власних пакетів

```java
public class CustomPacketSender {
    
    private final ProtocolManager pm;
    
    public CustomPacketSender() {
        this.pm = ProtocolLibrary.getProtocolManager();
    }
    
    // Відправити Title
    public void sendTitle(Player player, String title, String subtitle) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.TITLE);
        
        packet.getTitleActions().write(0, EnumWrappers.TitleAction.TITLE);
        packet.getChatComponents().write(0, 
            WrappedChatComponent.fromText(title)
        );
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Subtitle
        if (subtitle != null) {
            PacketContainer subPacket = pm.createPacket(PacketType.Play.Server.TITLE);
            subPacket.getTitleActions().write(0, EnumWrappers.TitleAction.SUBTITLE);
            subPacket.getChatComponents().write(0, 
                WrappedChatComponent.fromText(subtitle)
            );
            
            try {
                pm.sendServerPacket(player, subPacket);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    // Відправити ActionBar
    public void sendActionBar(Player player, String message) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.CHAT);
        
        packet.getChatComponents().write(0, 
            WrappedChatComponent.fromText(message)
        );
        packet.getBytes().write(0, (byte) 2); // ActionBar position
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Змінити блок (тільки для гравця)
    public void sendFakeBlock(Player player, Location loc, Material material) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.BLOCK_CHANGE);
        
        packet.getBlockPositionModifier().write(0, 
            new BlockPosition(loc.getBlockX(), loc.getBlockY(), loc.getBlockZ())
        );
        
        packet.getBlockData().write(0, 
            WrappedBlockData.createData(material)
        );
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## Fake Entity (NPC)

```java
public class FakePlayer {
    
    private final ProtocolManager pm;
    private final int entityId;
    private final UUID uuid;
    private final String name;
    
    public FakePlayer(String name) {
        this.pm = ProtocolLibrary.getProtocolManager();
        this.entityId = new Random().nextInt(10000) + 10000;
        this.uuid = UUID.randomUUID();
        this.name = name;
    }
    
    public void spawn(Player viewer, Location location) {
        // 1. Додати в tab list
        PacketContainer tabAdd = pm.createPacket(PacketType.Play.Server.PLAYER_INFO);
        tabAdd.getPlayerInfoAction().write(0, EnumWrappers.PlayerInfoAction.ADD_PLAYER);
        
        WrappedGameProfile profile = new WrappedGameProfile(uuid, name);
        PlayerInfoData data = new PlayerInfoData(
            profile, 0, 
            EnumWrappers.NativeGameMode.SURVIVAL,
            WrappedChatComponent.fromText(name)
        );
        
        tabAdd.getPlayerInfoDataLists().write(0, Collections.singletonList(data));
        
        try {
            pm.sendServerPacket(viewer, tabAdd);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // 2. Spawn entity
        PacketContainer spawn = pm.createPacket(PacketType.Play.Server.NAMED_ENTITY_SPAWN);
        spawn.getIntegers().write(0, entityId);
        spawn.getUUIDs().write(0, uuid);
        spawn.getDoubles()
            .write(0, location.getX())
            .write(1, location.getY())
            .write(2, location.getZ());
        
        try {
            pm.sendServerPacket(viewer, spawn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // 3. Видалити з tab через 1 секунду
        Bukkit.getScheduler().runTaskLater(plugin, () -> {
            PacketContainer tabRemove = pm.createPacket(PacketType.Play.Server.PLAYER_INFO);
            tabRemove.getPlayerInfoAction().write(0, EnumWrappers.PlayerInfoAction.REMOVE_PLAYER);
            tabRemove.getPlayerInfoDataLists().write(0, Collections.singletonList(data));
            
            try {
                pm.sendServerPacket(viewer, tabRemove);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }, 20L);
    }
    
    public void destroy(Player viewer) {
        PacketContainer destroy = pm.createPacket(PacketType.Play.Server.ENTITY_DESTROY);
        destroy.getIntegerArrays().write(0, new int[]{entityId});
        
        try {
            pm.sendServerPacket(viewer, destroy);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public int getEntityId() {
        return entityId;
    }
}
```

## Anti-Cheat приклад (fly detection)

```java
pm.addPacketListener(new PacketAdapter(
    plugin,
    PacketType.Play.Client.POSITION
) {
    private final Map<UUID, Location> lastLocations = new HashMap<>();
    
    @Override
    public void onPacketReceiving(PacketEvent event) {
        Player player = event.getPlayer();
        
        if (player.isFlying() || player.getAllowFlight()) {
            return; // Дозволено літати
        }
        
        PacketContainer packet = event.getPacket();
        
        double x = packet.getDoubles().read(0);
        double y = packet.getDoubles().read(1);
        double z = packet.getDoubles().read(2);
        
        Location newLoc = new Location(player.getWorld(), x, y, z);
        Location lastLoc = lastLocations.get(player.getUniqueId());
        
        if (lastLoc != null) {
            double verticalDist = newLoc.getY() - lastLoc.getY();
            
            // Якщо гравець піднявся більше ніж на 1 блок без землі під ногами
            if (verticalDist > 1.0 && !player.isOnGround()) {
                // Можливий fly hack
                plugin.getLogger().warning(player.getName() + " можливо використовує fly!");
                
                // Телепортувати назад
                player.teleport(lastLoc);
                event.setCancelled(true);
            }
        }
        
        lastLocations.put(player.getUniqueId(), newLoc.clone());
    }
});
```

## Практичне завдання

Створіть систему з ProtocolLib:
1. Custom ActionBar з прогрес баром здоров''я
2. Fake блоки (показувати гравцю інші блоки)
3. Fake NPC який махає рукою
4. Логування всіх команд гравців
5. Модифікація chat повідомлень (цензура)',
  1, FALSE
);

-- Урок 8.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-8', 'lesson-8-2',
  'NMS (net.minecraft.server) та версії',
  '16 хв', 'text',
  '# NMS - доступ до внутрішнього коду Minecraft

NMS (net.minecraft.server) - це внутрішній код Minecraft сервера.

## ⚠️ Проблеми з NMS

**Недоліки:**
- Змінюється в кожній версії Minecraft
- Обфусковані назви класів
- Може поламатись після оновлення
- Складний в підтримці

**Коли використовувати:**
- Коли Bukkit API недостатньо
- Для low-level операцій
- Продуктивність критична

## Reflection для доступу до NMS

```java
import org.bukkit.Bukkit;

public class NMSUtil {
    
    private static String version;
    
    static {
        // Отримати версію сервера (наприклад: v1_20_R1)
        String packageName = Bukkit.getServer().getClass().getPackage().getName();
        version = packageName.substring(packageName.lastIndexOf(".") + 1);
    }
    
    public static String getVersion() {
        return version;
    }
    
    // Отримати NMS клас
    public static Class<?> getNMSClass(String className) {
        try {
            return Class.forName("net.minecraft.server." + version + "." + className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // Отримати CraftBukkit клас
    public static Class<?> getCraftClass(String className) {
        try {
            return Class.forName("org.bukkit.craftbukkit." + version + "." + className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // Викликати метод через reflection
    public static Object invokeMethod(Object instance, String methodName, Object... args) {
        try {
            Class<?>[] paramTypes = new Class<?>[args.length];
            for (int i = 0; i < args.length; i++) {
                paramTypes[i] = args[i].getClass();
            }
            
            Method method = instance.getClass().getMethod(methodName, paramTypes);
            return method.invoke(instance, args);
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
```

## Отримати NMS Entity

```java
public class EntityNMS {
    
    public static Object getNMSEntity(Entity entity) {
        try {
            Method getHandle = entity.getClass().getMethod("getHandle");
            return getHandle.invoke(entity);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // Приклад: встановити AI для mob
    public static void setAI(LivingEntity entity, boolean enabled) {
        try {
            Object nmsEntity = getNMSEntity(entity);
            
            // Викликати setNoAI
            Method setNoAI = nmsEntity.getClass().getMethod("setNoAI", boolean.class);
            setNoAI.invoke(nmsEntity, !enabled);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## Відправити NMS пакет

```java
public class NMSPacketSender {
    
    public static void sendPacket(Player player, Object packet) {
        try {
            Object nmsPlayer = getNMSPlayer(player);
            Object connection = nmsPlayer.getClass()
                .getField("playerConnection")
                .get(nmsPlayer);
            
            Method sendPacket = connection.getClass()
                .getMethod("sendPacket", getNMSClass("Packet"));
            
            sendPacket.invoke(connection, packet);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private static Object getNMSPlayer(Player player) throws Exception {
        Method getHandle = player.getClass().getMethod("getHandle");
        return getHandle.invoke(player);
    }
    
    private static Class<?> getNMSClass(String name) throws Exception {
        String version = Bukkit.getServer().getClass().getPackage().getName().split("\\.")[3];
        return Class.forName("net.minecraft.server." + version + "." + name);
    }
}
```

## Version Wrapper (підтримка різних версій)

```java
public interface VersionWrapper {
    void sendTitle(Player player, String title, String subtitle);
    void spawnFakeEntity(Player player, Location location);
    String getServerVersion();
}

public class VersionWrapperFactory {
    
    public static VersionWrapper getWrapper() {
        String version = Bukkit.getVersion();
        
        if (version.contains("1.20")) {
            return new Wrapper_1_20();
        } else if (version.contains("1.19")) {
            return new Wrapper_1_19();
        } else if (version.contains("1.18")) {
            return new Wrapper_1_18();
        } else {
            throw new UnsupportedOperationException("Версія не підтримується: " + version);
        }
    }
}

public class Wrapper_1_20 implements VersionWrapper {
    
    @Override
    public void sendTitle(Player player, String title, String subtitle) {
        // Реалізація для 1.20
        player.sendTitle(title, subtitle, 10, 70, 20);
    }
    
    @Override
    public void spawnFakeEntity(Player player, Location location) {
        // Специфічна реалізація для 1.20
    }
    
    @Override
    public String getServerVersion() {
        return "1.20";
    }
}
```

## Mojang Mappings (1.17+)

```java
// Після 1.17 використовуйте Mojang mappings
public class ModernNMS {
    
    public static void setCustomName(Entity entity, String name) {
        try {
            // 1.17+ Mojang mappings
            Method getHandle = entity.getClass().getMethod("getHandle");
            Object nmsEntity = getHandle.invoke(entity);
            
            // Створити Component
            Class<?> componentClass = Class.forName("net.minecraft.network.chat.Component");
            Method literal = componentClass.getMethod("literal", String.class);
            Object component = literal.invoke(null, name);
            
            // setCustomName
            Method setCustomName = nmsEntity.getClass()
                .getMethod("setCustomName", componentClass);
            setCustomName.invoke(nmsEntity, component);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## Paper''s Brigadier (замість NMS команд)

```java
// Paper має власний API для команд
public class PaperCommands {
    
    public void registerBrigadierCommand() {
        // Використовуйте Paper API замість NMS
        Commands.register(
            plugin,
            Commands.literal("test")
                .then(Commands.argument("player", Arguments.player())
                    .executes(context -> {
                        Player target = context.getArgument("player", Player.class);
                        context.getSource().sendMessage("Гравець: " + target.getName());
                        return 1;
                    })
                )
        );
    }
}
```

## Альтернативи NMS

**1. ProtocolLib** - для пакетів
**2. Citizens API** - для NPC
**3. WorldEdit API** - для роботи зі світом
**4. Paper API** - розширені можливості
**5. Kotlin DSL** - спрощує reflection

## Безпечний NMS wrapper

```java
public class SafeNMS {
    
    private static boolean supported = true;
    
    public static boolean isSupported() {
        return supported;
    }
    
    public static void execute(Runnable nmsCode, Runnable fallback) {
        if (!supported) {
            fallback.run();
            return;
        }
        
        try {
            nmsCode.run();
        } catch (Exception e) {
            plugin.getLogger().warning("NMS код не працює на цій версії!");
            supported = false;
            fallback.run();
        }
    }
}

// Використання
SafeNMS.execute(
    () -> {
        // NMS код
        setCustomAI(entity);
    },
    () -> {
        // Fallback через Bukkit API
        entity.setAI(false);
    }
);
```

## Maven Dependency для конкретної версії

pom.xml:
```xml
<repositories>
    <repository>
        <id>nms-repo</id>
        <url>https://repo.codemc.io/repository/nms/</url>
    </repository>
</repositories>

<dependencies>
    <!-- Spigot NMS 1.20.1 -->
    <dependency>
        <groupId>org.spigotmc</groupId>
        <artifactId>spigot</artifactId>
        <version>1.20.1-R0.1-SNAPSHOT</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

## Перевірка методів через Reflection

```java
public class NMSChecker {
    
    public static boolean hasMethod(Class<?> clazz, String methodName, Class<?>... params) {
        try {
            clazz.getMethod(methodName, params);
            return true;
        } catch (NoSuchMethodException e) {
            return false;
        }
    }
    
    public static void checkVersion() {
        Class<?> entityClass = NMSUtil.getNMSClass("Entity");
        
        if (hasMethod(entityClass, "setNoAI", boolean.class)) {
            plugin.getLogger().info("✅ setNoAI підтримується");
        } else {
            plugin.getLogger().warning("❌ setNoAI не знайдено");
        }
    }
}
```

## Практичне завдання

Створіть систему з NMS:
1. VersionWrapper для підтримки 1.18-1.20
2. Reflection утиліти для безпечного доступу
3. Fallback на Bukkit API якщо NMS не працює
4. Логування підтримуваних версій при запуску
5. Custom AI для mob (без AI, але з пасивним рухом)',
  2, FALSE
);

-- Урок 8.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-8', 'lesson-8-3',
  'Advanced ProtocolLib - custom packets',
  '14 хв', 'text',
  '# Advanced ProtocolLib використання

Створення складних систем з ProtocolLib.

## Scoreboard через пакети

```java
public class PacketScoreboard {
    
    private final ProtocolManager pm;
    private final Player player;
    private final String objectiveName;
    
    public PacketScoreboard(Player player) {
        this.pm = ProtocolLibrary.getProtocolManager();
        this.player = player;
        this.objectiveName = "sidebar_" + player.getUniqueId();
    }
    
    public void create(String title) {
        // Створити objective
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.SCOREBOARD_OBJECTIVE);
        
        packet.getStrings()
            .write(0, objectiveName)  // Назва
            .write(1, title);          // Заголовок
        
        packet.getIntegers()
            .write(0, 0);  // 0 = CREATE
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Показати на sidebar
        displaySidebar();
    }
    
    private void displaySidebar() {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.SCOREBOARD_DISPLAY_OBJECTIVE);
        
        packet.getIntegers()
            .write(0, 1);  // 1 = SIDEBAR position
        
        packet.getStrings()
            .write(0, objectiveName);
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void setLine(int line, String text) {
        // Scoreboard лінії відображаються знизу вгору
        // 0 = найнижча, 15 = найвища
        
        String entry = "§" + Integer.toHexString(line);  // Унікальний entry
        
        // Видалити старий
        removeLine(entry);
        
        // Створити team для кольорів
        createTeam(entry, text);
        
        // Додати score
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.SCOREBOARD_SCORE);
        
        packet.getStrings()
            .write(0, entry)           // Entry name
            .write(1, objectiveName);  // Objective name
        
        packet.getIntegers()
            .write(0, line);  // Score (позиція)
        
        packet.getScoreboardActions()
            .write(0, EnumWrappers.ScoreboardAction.CHANGE);
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void createTeam(String teamName, String text) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.SCOREBOARD_TEAM);
        
        packet.getStrings()
            .write(0, teamName)  // Team name
            .write(1, text)      // Prefix (текст)
            .write(2, "")        // Suffix
            .write(3, "always"); // Name tag visibility
        
        packet.getIntegers()
            .write(0, 0);  // 0 = CREATE
        
        // Додати entry в team
        packet.getSpecificModifier(Collection.class)
            .write(0, Collections.singletonList(teamName));
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void removeLine(String entry) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.SCOREBOARD_SCORE);
        
        packet.getStrings()
            .write(0, entry)
            .write(1, objectiveName);
        
        packet.getScoreboardActions()
            .write(0, EnumWrappers.ScoreboardAction.REMOVE);
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void destroy() {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.SCOREBOARD_OBJECTIVE);
        
        packet.getStrings()
            .write(0, objectiveName);
        
        packet.getIntegers()
            .write(0, 1);  // 1 = REMOVE
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

// Використання
PacketScoreboard scoreboard = new PacketScoreboard(player);
scoreboard.create("§6§lМій Сервер");
scoreboard.setLine(5, "§7Гравців: §a" + Bukkit.getOnlinePlayers().size());
scoreboard.setLine(4, "§7Баланс: §e$1000");
scoreboard.setLine(3, "");
scoreboard.setLine(2, "§ewww.server.net");
```

## Tab List (player list)

```java
public class CustomTabList {
    
    public void updateTabName(Player player, String displayName) {
        ProtocolManager pm = ProtocolLibrary.getProtocolManager();
        
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.PLAYER_INFO);
        
        packet.getPlayerInfoAction()
            .write(0, EnumWrappers.PlayerInfoAction.UPDATE_DISPLAY_NAME);
        
        WrappedGameProfile profile = WrappedGameProfile.fromPlayer(player);
        
        PlayerInfoData data = new PlayerInfoData(
            profile,
            0,
            EnumWrappers.NativeGameMode.SURVIVAL,
            WrappedChatComponent.fromText(displayName)
        );
        
        packet.getPlayerInfoDataLists()
            .write(0, Collections.singletonList(data));
        
        // Відправити всім гравцям
        for (Player online : Bukkit.getOnlinePlayers()) {
            try {
                pm.sendServerPacket(online, packet);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    public void setHeaderFooter(Player player, String header, String footer) {
        ProtocolManager pm = ProtocolLibrary.getProtocolManager();
        
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.PLAYER_LIST_HEADER_FOOTER);
        
        packet.getChatComponents()
            .write(0, WrappedChatComponent.fromText(header))
            .write(1, WrappedChatComponent.fromText(footer));
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## Boss Bar через пакети

```java
public class PacketBossBar {
    
    private final ProtocolManager pm;
    private final UUID bossBarId;
    
    public PacketBossBar() {
        this.pm = ProtocolLibrary.getProtocolManager();
        this.bossBarId = UUID.randomUUID();
    }
    
    public void create(Player player, String title, float health) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.BOSS);
        
        packet.getUUIDs().write(0, bossBarId);
        
        // Action: ADD
        packet.getIntegers().write(0, 0);
        
        packet.getChatComponents()
            .write(0, WrappedChatComponent.fromText(title));
        
        packet.getFloat()
            .write(0, Math.max(0f, Math.min(1f, health)));  // 0.0 - 1.0
        
        // Color: PURPLE
        packet.getEnumModifier(BarColor.class, 0)
            .write(0, BarColor.PURPLE);
        
        // Style: SOLID
        packet.getEnumModifier(BarStyle.class, 1)
            .write(0, BarStyle.SOLID);
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void updateHealth(Player player, float health) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.BOSS);
        
        packet.getUUIDs().write(0, bossBarId);
        packet.getIntegers().write(0, 2);  // Action: UPDATE_HEALTH
        packet.getFloat().write(0, Math.max(0f, Math.min(1f, health)));
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void updateTitle(Player player, String title) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.BOSS);
        
        packet.getUUIDs().write(0, bossBarId);
        packet.getIntegers().write(0, 3);  // Action: UPDATE_TITLE
        packet.getChatComponents().write(0, WrappedChatComponent.fromText(title));
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void remove(Player player) {
        PacketContainer packet = pm.createPacket(PacketType.Play.Server.BOSS);
        
        packet.getUUIDs().write(0, bossBarId);
        packet.getIntegers().write(0, 1);  // Action: REMOVE
        
        try {
            pm.sendServerPacket(player, packet);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## Entity Equipment (броня, предмети)

```java
public void setEntityEquipment(Player viewer, int entityId, ItemStack item, EnumWrappers.ItemSlot slot) {
    ProtocolManager pm = ProtocolLibrary.getProtocolManager();
    
    PacketContainer packet = pm.createPacket(PacketType.Play.Server.ENTITY_EQUIPMENT);
    
    packet.getIntegers().write(0, entityId);
    
    // Slot та ItemStack
    List<Pair<EnumWrappers.ItemSlot, ItemStack>> equipment = new ArrayList<>();
    equipment.add(new Pair<>(slot, item));
    
    packet.getSlotStackPairLists().write(0, equipment);
    
    try {
        pm.sendServerPacket(viewer, packet);
    } catch (Exception e) {
        e.printStackTrace();
    }
}

// Використання
ItemStack sword = new ItemStack(Material.DIAMOND_SWORD);
setEntityEquipment(player, npcEntityId, sword, EnumWrappers.ItemSlot.MAINHAND);
```

## Block Break Animation

```java
public void sendBlockBreakAnimation(Player player, Location loc, int stage) {
    ProtocolManager pm = ProtocolLibrary.getProtocolManager();
    
    PacketContainer packet = pm.createPacket(PacketType.Play.Server.BLOCK_BREAK_ANIMATION);
    
    packet.getIntegers()
        .write(0, player.getEntityId())  // Entity ID
        .write(1, stage);                 // Stage 0-9 (0=none, 9=almost broken)
    
    packet.getBlockPositionModifier()
        .write(0, new BlockPosition(loc.getBlockX(), loc.getBlockY(), loc.getBlockZ()));
    
    // Відправити всім поблизу
    for (Player nearby : loc.getWorld().getPlayers()) {
        if (nearby.getLocation().distance(loc) <= 64) {
            try {
                pm.sendServerPacket(nearby, packet);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

// Анімація копання
new BukkitRunnable() {
    int stage = 0;
    
    @Override
    public void run() {
        if (stage > 9) {
            cancel();
            block.setType(Material.AIR);
            return;
        }
        
        sendBlockBreakAnimation(player, block.getLocation(), stage);
        stage++;
    }
}.runTaskTimer(plugin, 0L, 5L);
```

## World Border через пакети

```java
public void setWorldBorder(Player player, Location center, double size, long timeToReach) {
    ProtocolManager pm = ProtocolLibrary.getProtocolManager();
    
    // Initialize
    PacketContainer init = pm.createPacket(PacketType.Play.Server.WORLD_BORDER);
    init.getWorldBorderActions().write(0, EnumWrappers.WorldBorderAction.INITIALIZE);
    init.getDoubles()
        .write(0, center.getX())
        .write(1, center.getZ())
        .write(2, size)       // Old size
        .write(3, size);      // New size
    init.getLongs().write(0, timeToReach);
    init.getIntegers()
        .write(0, 29999984)   // Portal teleport boundary
        .write(1, 5);         // Warning distance
    
    try {
        pm.sendServerPacket(player, init);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
```

## Практичне завдання

Створіть систему з:
1. Custom scoreboard з live оновленням
2. Tab list з рангами та пінгом
3. Boss bar прогрес квестів
4. Fake block break анімація для minigame
5. Custom world border для arena',
  3, FALSE
);

-- Квіз для Модуля 8
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-8', 'lesson-8-4',
  'Тест: ProtocolLib та NMS',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-8-4",
    "questions": [
      {
        "id": "q1",
        "question": "Що таке ProtocolLib?",
        "options": [
          "База даних бібліотека",
          "Бібліотека для перехоплення та модифікації пакетів",
          "GUI фреймворк",
          "NMS wrapper"
        ],
        "correctAnswer": 1,
        "explanation": "ProtocolLib дозволяє перехоплювати пакети між клієнтом і сервером та модифікувати їх"
      },
      {
        "id": "q2",
        "question": "Чому NMS код проблематичний?",
        "options": [
          "Повільний",
          "Змінюється в кожній версії Minecraft",
          "Заборонений Mojang",
          "Працює тільки на Windows"
        ],
        "correctAnswer": 1,
        "explanation": "NMS код змінюється між версіями Minecraft, що ускладнює підтримку плагінів"
      },
      {
        "id": "q3",
        "question": "Коли використовувати PacketAdapter?",
        "options": [
          "Для роботи з БД",
          "Для перехоплення пакетів між клієнтом та сервером",
          "Для команд",
          "Для конфігів"
        ],
        "correctAnswer": 1,
        "explanation": "PacketAdapter використовується для прослуховування та модифікації пакетів"
      },
      {
        "id": "q4",
        "question": "Що треба вказати в plugin.yml для ProtocolLib?",
        "options": [
          "softdepend: [ProtocolLib]",
          "depend: [ProtocolLib]",
          "libraries: [ProtocolLib]",
          "Нічого не треба"
        ],
        "correctAnswer": 1,
        "explanation": "depend: [ProtocolLib] гарантує що ProtocolLib завантажиться перед вашим плагіном"
      },
      {
        "id": "q5",
        "question": "Яка альтернатива NMS для версійної сумісності?",
        "options": [
          "Використовувати тільки Bukkit API",
          "VersionWrapper pattern з fallback на Bukkit API",
          "Підтримувати тільки одну версію",
          "Використовувати JavaScript"
        ],
        "correctAnswer": 1,
        "explanation": "VersionWrapper дозволяє створити абстракцію з різними реалізаціями для кожної версії"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 8 додано! 4 уроки створено.' as status;
