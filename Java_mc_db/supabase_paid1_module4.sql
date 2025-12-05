-- =============================================
-- Модуль 4: Commands та TabCompleters
-- =============================================

-- Урок 4.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-4', 'lesson-4-1',
  'Основи створення команд',
  '16 хв', 'text',
  '# Створення команд для плагіну

Команди - основний спосіб взаємодії гравців з плагіном.

## Реєстрація команди в plugin.yml

```yaml
name: MyPlugin
version: 1.0.0
main: ua.yourname.myplugin.MyPlugin
api-version: 1.20

commands:
  heal:
    description: Зцілити себе або іншого гравця
    usage: /heal [гравець]
    permission: myplugin.heal
    permission-message: §cУ вас немає прав!
    aliases: [h, зцілити]
  
  kit:
    description: Отримати стартовий набір
    usage: /kit <назва>
    permission: myplugin.kit
```

## Створення CommandExecutor

```java
package ua.yourname.myplugin.commands;

import org.bukkit.command.Command;
import org.bukkit.command.CommandExecutor;
import org.bukkit.command.CommandSender;
import org.bukkit.entity.Player;

public class HealCommand implements CommandExecutor {
    
    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        // Перевірка чи це гравець
        if (!(sender instanceof Player)) {
            sender.sendMessage("§cТільки гравці можуть використовувати цю команду!");
            return true;
        }
        
        Player player = (Player) sender;
        
        // /heal - зцілити себе
        if (args.length == 0) {
            player.setHealth(20.0);
            player.setFoodLevel(20);
            player.sendMessage("§aВи зцілені!");
            return true;
        }
        
        // /heal <гравець> - зцілити іншого
        if (args.length == 1) {
            // Перевірка прав
            if (!player.hasPermission("myplugin.heal.others")) {
                player.sendMessage("§cУ вас немає прав зцілювати інших!");
                return true;
            }
            
            Player target = Bukkit.getPlayer(args[0]);
            
            if (target == null || !target.isOnline()) {
                player.sendMessage("§cГравець не знайдений!");
                return true;
            }
            
            target.setHealth(20.0);
            target.setFoodLevel(20);
            target.sendMessage("§aВас зцілив " + player.getName());
            player.sendMessage("§aВи зцілили " + target.getName());
            return true;
        }
        
        // Невірне використання
        player.sendMessage("§cВикористання: /heal [гравець]");
        return true;
    }
}
```

## Реєстрація в головному класі

```java
public class MyPlugin extends JavaPlugin {
    
    @Override
    public void onEnable() {
        // Реєструємо команду
        getCommand("heal").setExecutor(new HealCommand());
    }
}
```

## Обробка аргументів

```java
public class KitCommand implements CommandExecutor {
    
    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        if (!(sender instanceof Player)) {
            sender.sendMessage("§cТільки для гравців!");
            return true;
        }
        
        Player player = (Player) sender;
        
        // Перевірка аргументів
        if (args.length == 0) {
            player.sendMessage("§eДоступні кіти: starter, pvp, food");
            return true;
        }
        
        String kitName = args[0].toLowerCase();
        
        switch (kitName) {
            case "starter":
                giveStarterKit(player);
                break;
                
            case "pvp":
                if (!player.hasPermission("myplugin.kit.pvp")) {
                    player.sendMessage("§cУ вас немає доступу до цього кіту!");
                    return true;
                }
                givePvPKit(player);
                break;
                
            case "food":
                giveFoodKit(player);
                break;
                
            default:
                player.sendMessage("§cНевідомий кіт: " + kitName);
                player.sendMessage("§eДоступні: starter, pvp, food");
                return true;
        }
        
        player.sendMessage("§aВи отримали кіт: §e" + kitName);
        return true;
    }
    
    private void giveStarterKit(Player player) {
        player.getInventory().addItem(
            new ItemStack(Material.STONE_SWORD),
            new ItemStack(Material.STONE_PICKAXE),
            new ItemStack(Material.BREAD, 16)
        );
    }
    
    private void givePvPKit(Player player) {
        player.getInventory().addItem(
            new ItemStack(Material.DIAMOND_SWORD),
            new ItemStack(Material.DIAMOND_HELMET),
            new ItemStack(Material.GOLDEN_APPLE, 5)
        );
    }
    
    private void giveFoodKit(Player player) {
        player.getInventory().addItem(
            new ItemStack(Material.COOKED_BEEF, 64),
            new ItemStack(Material.BREAD, 64),
            new ItemStack(Material.GOLDEN_APPLE, 3)
        );
    }
}
```

## Команди для консолі

```java
@Override
public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
    // Команда працює і для гравців, і для консолі
    
    if (args.length == 0) {
        sender.sendMessage("§cВкажіть гравця!");
        return true;
    }
    
    Player target = Bukkit.getPlayer(args[0]);
    
    if (target == null) {
        sender.sendMessage("§cГравець не в мережі!");
        return true;
    }
    
    // Виконати дію
    target.setHealth(20.0);
    
    // Повідомлення для відправника
    if (sender instanceof Player) {
        sender.sendMessage("§aВи зцілили " + target.getName());
    } else {
        sender.sendMessage("[Консоль] Гравець " + target.getName() + " зцілений");
    }
    
    return true;
}
```

## Практичний приклад

Складна команда з підкомандами:
```java
public class AdminCommand implements CommandExecutor {
    
    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        if (!sender.hasPermission("myplugin.admin")) {
            sender.sendMessage("§cНемає прав!");
            return true;
        }
        
        if (args.length == 0) {
            sendHelpMessage(sender);
            return true;
        }
        
        String subCommand = args[0].toLowerCase();
        
        switch (subCommand) {
            case "reload":
                // /admin reload
                handleReload(sender);
                break;
                
            case "give":
                // /admin give <гравець> <предмет> [кількість]
                if (args.length < 3) {
                    sender.sendMessage("§c/admin give <гравець> <предмет> [кількість]");
                    return true;
                }
                handleGive(sender, args);
                break;
                
            case "tp":
                // /admin tp <гравець1> <гравець2>
                if (args.length < 3) {
                    sender.sendMessage("§c/admin tp <гравець1> <гравець2>");
                    return true;
                }
                handleTeleport(sender, args);
                break;
                
            default:
                sender.sendMessage("§cНевідома підкоманда: " + subCommand);
                sendHelpMessage(sender);
                break;
        }
        
        return true;
    }
    
    private void sendHelpMessage(CommandSender sender) {
        sender.sendMessage("§6=== Admin команди ===");
        sender.sendMessage("§e/admin reload §7- Перезавантажити конфіг");
        sender.sendMessage("§e/admin give <гравець> <предмет> [к-сть] §7- Видати предмет");
        sender.sendMessage("§e/admin tp <гравець1> <гравець2> §7- Телепортувати");
    }
    
    private void handleReload(CommandSender sender) {
        // Логіка перезавантаження
        sender.sendMessage("§aКонфіг перезавантажено!");
    }
    
    private void handleGive(CommandSender sender, String[] args) {
        // args[0] = "give"
        // args[1] = гравець
        // args[2] = предмет
        // args[3] = кількість (опційно)
    }
    
    private void handleTeleport(CommandSender sender, String[] args) {
        // Логіка телепортації
    }
}
```

## Практичне завдання

Створіть команду `/money` з підкомандами:
- `/money balance [гравець]` - баланс
- `/money pay <гравець> <сума>` - перевести гроші
- `/money top` - топ-10 найбагатших
- `/money add <гравець> <сума>` - (тільки для адмінів)',
  1, FALSE
);

-- Урок 4.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-4', 'lesson-4-2',
  'TabCompleter - автодоповнення команд',
  '14 хв', 'text',
  '# Tab-completion для команд

Автодоповнення робить команди зручнішими для гравців.

## Основи TabCompleter

```java
import org.bukkit.command.Command;
import org.bukkit.command.CommandSender;
import org.bukkit.command.TabCompleter;

import java.util.ArrayList;
import java.util.List;

public class HealCommandTabCompleter implements TabCompleter {
    
    @Override
    public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
        List<String> completions = new ArrayList<>();
        
        // /heal <tab> - показати онлайн гравців
        if (args.length == 1) {
            for (Player player : Bukkit.getOnlinePlayers()) {
                completions.add(player.getName());
            }
        }
        
        return completions;
    }
}
```

## Реєстрація TabCompleter

```java
@Override
public void onEnable() {
    PluginCommand healCmd = getCommand("heal");
    HealCommand executor = new HealCommand();
    
    healCmd.setExecutor(executor);
    healCmd.setTabCompleter(new HealCommandTabCompleter());
}
```

## Фільтрація по введеному тексту

```java
@Override
public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
    List<String> completions = new ArrayList<>();
    
    if (args.length == 1) {
        String input = args[0].toLowerCase();
        
        // Додати тільки тих гравців, чиє ім''я починається з введеного
        for (Player player : Bukkit.getOnlinePlayers()) {
            String name = player.getName();
            if (name.toLowerCase().startsWith(input)) {
                completions.add(name);
            }
        }
    }
    
    return completions;
}
```

## Багаторівневе автодоповнення

Для команди з підкомандами:
```java
public class AdminTabCompleter implements TabCompleter {
    
    @Override
    public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
        List<String> completions = new ArrayList<>();
        
        // /admin <tab> - показати підкоманди
        if (args.length == 1) {
            completions.add("reload");
            completions.add("give");
            completions.add("tp");
            completions.add("ban");
            completions.add("unban");
            
            // Фільтрація
            return filterCompletions(completions, args[0]);
        }
        
        // /admin give <tab> - гравці
        if (args.length == 2 && args[0].equalsIgnoreCase("give")) {
            for (Player player : Bukkit.getOnlinePlayers()) {
                completions.add(player.getName());
            }
            return filterCompletions(completions, args[1]);
        }
        
        // /admin give <гравець> <tab> - предмети
        if (args.length == 3 && args[0].equalsIgnoreCase("give")) {
            for (Material material : Material.values()) {
                if (material.isItem()) {
                    completions.add(material.name().toLowerCase());
                }
            }
            return filterCompletions(completions, args[2]);
        }
        
        // /admin give <гравець> <предмет> <tab> - кількість
        if (args.length == 4 && args[0].equalsIgnoreCase("give")) {
            completions.add("1");
            completions.add("64");
            return completions;
        }
        
        return completions;
    }
    
    private List<String> filterCompletions(List<String> completions, String input) {
        List<String> filtered = new ArrayList<>();
        String lowerInput = input.toLowerCase();
        
        for (String completion : completions) {
            if (completion.toLowerCase().startsWith(lowerInput)) {
                filtered.add(completion);
            }
        }
        
        return filtered;
    }
}
```

## Комбінація Executor + TabCompleter в одному класі

```java
public class KitCommand implements CommandExecutor, TabCompleter {
    
    private final List<String> kits = Arrays.asList("starter", "pvp", "food", "mining");
    
    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        // Логіка команди
        return true;
    }
    
    @Override
    public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
        if (args.length == 1) {
            return filterCompletions(kits, args[0]);
        }
        return new ArrayList<>();
    }
    
    private List<String> filterCompletions(List<String> options, String input) {
        return options.stream()
            .filter(option -> option.toLowerCase().startsWith(input.toLowerCase()))
            .collect(Collectors.toList());
    }
}

// Реєстрація
@Override
public void onEnable() {
    PluginCommand kitCmd = getCommand("kit");
    KitCommand kitCommand = new KitCommand();
    
    kitCmd.setExecutor(kitCommand);
    kitCmd.setTabCompleter(kitCommand); // Той же об''єкт
}
```

## Динамічні completion''и з бази даних

```java
public class WarpTabCompleter implements TabCompleter {
    
    private final WarpManager warpManager;
    
    public WarpTabCompleter(WarpManager warpManager) {
        this.warpManager = warpManager;
    }
    
    @Override
    public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
        List<String> completions = new ArrayList<>();
        
        if (args.length == 1) {
            // Отримати список warp''ів з бази/конфігу
            List<String> warps = warpManager.getAllWarpNames();
            
            String input = args[0].toLowerCase();
            for (String warp : warps) {
                if (warp.toLowerCase().startsWith(input)) {
                    completions.add(warp);
                }
            }
        }
        
        return completions;
    }
}
```

## Контекстно-залежні completion''и

```java
@Override
public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
    List<String> completions = new ArrayList<>();
    
    if (!(sender instanceof Player)) {
        return completions; // Консоль не отримає completions
    }
    
    Player player = (Player) sender;
    
    if (args.length == 1) {
        // Показати різні опції залежно від прав
        if (player.hasPermission("plugin.admin")) {
            completions.add("reload");
            completions.add("debug");
        }
        
        completions.add("help");
        completions.add("info");
        
        return filterCompletions(completions, args[0]);
    }
    
    return completions;
}
```

## StringUtil для фільтрації (Bukkit API)

```java
import org.bukkit.util.StringUtil;

@Override
public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
    List<String> completions = new ArrayList<>();
    List<String> options = Arrays.asList("option1", "option2", "option3");
    
    if (args.length == 1) {
        // StringUtil.copyPartialMatches автоматично фільтрує
        return StringUtil.copyPartialMatches(args[0], options, completions);
    }
    
    return completions;
}
```

## Практичний приклад

Складна система tab-completion:
```java
public class ShopTabCompleter implements TabCompleter {
    
    @Override
    public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
        List<String> completions = new ArrayList<>();
        
        // /shop <tab>
        if (args.length == 1) {
            completions.addAll(Arrays.asList("buy", "sell", "list", "info"));
            return StringUtil.copyPartialMatches(args[0], completions, new ArrayList<>());
        }
        
        String subCommand = args[0].toLowerCase();
        
        // /shop buy <tab>
        if (args.length == 2 && subCommand.equals("buy")) {
            completions.addAll(getShopItems());
            return StringUtil.copyPartialMatches(args[1], completions, new ArrayList<>());
        }
        
        // /shop buy <item> <tab>
        if (args.length == 3 && subCommand.equals("buy")) {
            completions.addAll(Arrays.asList("1", "8", "16", "32", "64"));
            return completions;
        }
        
        // /shop sell <tab> - предмети в інвентарі гравця
        if (args.length == 2 && subCommand.equals("sell")) {
            if (sender instanceof Player) {
                Player player = (Player) sender;
                for (ItemStack item : player.getInventory().getContents()) {
                    if (item != null && item.getType() != Material.AIR) {
                        String name = item.getType().name().toLowerCase();
                        if (!completions.contains(name)) {
                            completions.add(name);
                        }
                    }
                }
            }
            return StringUtil.copyPartialMatches(args[1], completions, new ArrayList<>());
        }
        
        return completions;
    }
    
    private List<String> getShopItems() {
        return Arrays.asList(
            "diamond", "iron_ingot", "gold_ingot",
            "emerald", "bread", "cooked_beef"
        );
    }
}
```

## Практичне завдання

Створіть TabCompleter для команди `/party`:
- `/party create` - створити групу
- `/party invite <гравець>` - запросити
- `/party kick <member>` - виключити (тільки члени вашої party)
- `/party leave` - покинути
- `/party list` - список членів',
  2, FALSE
);

-- Урок 4.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-4', 'lesson-4-3',
  'Просунуті техніки роботи з командами',
  '17 хв', 'text',
  '# Просунута робота з командами

Професійні техніки для складних систем команд.

## Абстрактна система підкоманд

Створимо базовий клас для підкоманд:
```java
public abstract class SubCommand {
    
    public abstract String getName();
    
    public abstract String getDescription();
    
    public abstract String getUsage();
    
    public abstract String getPermission();
    
    public abstract boolean execute(CommandSender sender, String[] args);
    
    public abstract List<String> tabComplete(CommandSender sender, String[] args);
    
    protected boolean hasPermission(CommandSender sender) {
        if (getPermission() == null || getPermission().isEmpty()) {
            return true;
        }
        return sender.hasPermission(getPermission());
    }
}
```

## Приклад підкоманди

```java
public class ReloadSubCommand extends SubCommand {
    
    private final JavaPlugin plugin;
    
    public ReloadSubCommand(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    @Override
    public String getName() {
        return "reload";
    }
    
    @Override
    public String getDescription() {
        return "Перезавантажити конфіг плагіну";
    }
    
    @Override
    public String getUsage() {
        return "/admin reload";
    }
    
    @Override
    public String getPermission() {
        return "myplugin.admin.reload";
    }
    
    @Override
    public boolean execute(CommandSender sender, String[] args) {
        plugin.reloadConfig();
        sender.sendMessage("§aКонфіг перезавантажено!");
        return true;
    }
    
    @Override
    public List<String> tabComplete(CommandSender sender, String[] args) {
        return new ArrayList<>(); // Немає аргументів
    }
}
```

## Менеджер команд

```java
public class CommandManager implements CommandExecutor, TabCompleter {
    
    private final Map<String, SubCommand> subCommands = new HashMap<>();
    
    public CommandManager() {
        // Реєструємо підкоманди
        registerSubCommand(new ReloadSubCommand(plugin));
        registerSubCommand(new GiveSubCommand());
        registerSubCommand(new TeleportSubCommand());
    }
    
    public void registerSubCommand(SubCommand subCommand) {
        subCommands.put(subCommand.getName().toLowerCase(), subCommand);
    }
    
    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        if (args.length == 0) {
            sendHelp(sender);
            return true;
        }
        
        String subCommandName = args[0].toLowerCase();
        SubCommand subCommand = subCommands.get(subCommandName);
        
        if (subCommand == null) {
            sender.sendMessage("§cНевідома команда: " + subCommandName);
            return true;
        }
        
        if (!subCommand.hasPermission(sender)) {
            sender.sendMessage("§cУ вас немає прав!");
            return true;
        }
        
        // Передаємо аргументи без першого (назви підкоманди)
        String[] subArgs = Arrays.copyOfRange(args, 1, args.length);
        return subCommand.execute(sender, subArgs);
    }
    
    @Override
    public List<String> onTabComplete(CommandSender sender, Command command, String alias, String[] args) {
        List<String> completions = new ArrayList<>();
        
        // Перший аргумент - список підкоманд
        if (args.length == 1) {
            for (SubCommand subCommand : subCommands.values()) {
                if (subCommand.hasPermission(sender)) {
                    completions.add(subCommand.getName());
                }
            }
            return StringUtil.copyPartialMatches(args[0], completions, new ArrayList<>());
        }
        
        // Делегуємо tab-completion підкоманді
        if (args.length >= 2) {
            String subCommandName = args[0].toLowerCase();
            SubCommand subCommand = subCommands.get(subCommandName);
            
            if (subCommand != null && subCommand.hasPermission(sender)) {
                String[] subArgs = Arrays.copyOfRange(args, 1, args.length);
                return subCommand.tabComplete(sender, subArgs);
            }
        }
        
        return completions;
    }
    
    private void sendHelp(CommandSender sender) {
        sender.sendMessage("§6=== Доступні команди ===");
        for (SubCommand subCommand : subCommands.values()) {
            if (subCommand.hasPermission(sender)) {
                sender.sendMessage("§e" + subCommand.getUsage() + " §7- " + subCommand.getDescription());
            }
        }
    }
}
```

## Валідація аргументів

```java
public class ArgumentValidator {
    
    public static boolean isInteger(String str) {
        try {
            Integer.parseInt(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
    
    public static boolean isDouble(String str) {
        try {
            Double.parseDouble(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
    
    public static Player getPlayer(CommandSender sender, String name) {
        Player target = Bukkit.getPlayer(name);
        
        if (target == null || !target.isOnline()) {
            sender.sendMessage("§cГравець §e" + name + " §cне знайдений!");
            return null;
        }
        
        return target;
    }
    
    public static Material getMaterial(CommandSender sender, String name) {
        Material material = Material.matchMaterial(name);
        
        if (material == null) {
            sender.sendMessage("§cНевідомий предмет: §e" + name);
            return null;
        }
        
        return material;
    }
    
    public static int getPositiveInteger(CommandSender sender, String str, String paramName) {
        if (!isInteger(str)) {
            sender.sendMessage("§c" + paramName + " має бути числом!");
            return -1;
        }
        
        int value = Integer.parseInt(str);
        
        if (value <= 0) {
            sender.sendMessage("§c" + paramName + " має бути більше 0!");
            return -1;
        }
        
        return value;
    }
}
```

## Використання валідатора

```java
public class GiveSubCommand extends SubCommand {
    
    @Override
    public boolean execute(CommandSender sender, String[] args) {
        // /admin give <гравець> <предмет> [кількість]
        
        if (args.length < 2) {
            sender.sendMessage("§c" + getUsage());
            return true;
        }
        
        // Валідація гравця
        Player target = ArgumentValidator.getPlayer(sender, args[0]);
        if (target == null) return true;
        
        // Валідація предмету
        Material material = ArgumentValidator.getMaterial(sender, args[1]);
        if (material == null) return true;
        
        // Валідація кількості
        int amount = 1;
        if (args.length >= 3) {
            amount = ArgumentValidator.getPositiveInteger(sender, args[2], "Кількість");
            if (amount == -1) return true;
        }
        
        // Виконати команду
        ItemStack item = new ItemStack(material, amount);
        target.getInventory().addItem(item);
        
        target.sendMessage("§aВи отримали §e" + amount + "x " + material.name());
        sender.sendMessage("§aВидано §e" + amount + "x " + material.name() + " §aгравцю §e" + target.getName());
        
        return true;
    }
    
    // ... інші методи
}
```

## Cooldown система для команд

```java
public class CooldownManager {
    
    private final Map<UUID, Map<String, Long>> cooldowns = new HashMap<>();
    
    public void setCooldown(Player player, String command, long seconds) {
        UUID uuid = player.getUniqueId();
        cooldowns.putIfAbsent(uuid, new HashMap<>());
        
        long expireTime = System.currentTimeMillis() + (seconds * 1000);
        cooldowns.get(uuid).put(command, expireTime);
    }
    
    public boolean hasCooldown(Player player, String command) {
        UUID uuid = player.getUniqueId();
        
        if (!cooldowns.containsKey(uuid)) {
            return false;
        }
        
        Map<String, Long> playerCooldowns = cooldowns.get(uuid);
        
        if (!playerCooldowns.containsKey(command)) {
            return false;
        }
        
        long expireTime = playerCooldowns.get(command);
        
        if (System.currentTimeMillis() >= expireTime) {
            playerCooldowns.remove(command);
            return false;
        }
        
        return true;
    }
    
    public long getRemainingTime(Player player, String command) {
        UUID uuid = player.getUniqueId();
        
        if (!cooldowns.containsKey(uuid)) {
            return 0;
        }
        
        Map<String, Long> playerCooldowns = cooldowns.get(uuid);
        
        if (!playerCooldowns.containsKey(command)) {
            return 0;
        }
        
        long expireTime = playerCooldowns.get(command);
        long remaining = (expireTime - System.currentTimeMillis()) / 1000;
        
        return Math.max(0, remaining);
    }
    
    public String formatTime(long seconds) {
        if (seconds < 60) {
            return seconds + " сек";
        }
        
        long minutes = seconds / 60;
        long remainingSeconds = seconds % 60;
        
        return minutes + " хв " + remainingSeconds + " сек";
    }
}
```

## Використання cooldown

```java
public class HomeCommand implements CommandExecutor {
    
    private final CooldownManager cooldownManager;
    
    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        if (!(sender instanceof Player)) {
            sender.sendMessage("§cТільки для гравців!");
            return true;
        }
        
        Player player = (Player) sender;
        
        // Перевірка cooldown (якщо немає bypass права)
        if (!player.hasPermission("myplugin.home.bypass")) {
            if (cooldownManager.hasCooldown(player, "home")) {
                long remaining = cooldownManager.getRemainingTime(player, "home");
                player.sendMessage("§cЗачекайте ще " + cooldownManager.formatTime(remaining));
                return true;
            }
        }
        
        // Телепортація
        Location home = getPlayerHome(player);
        player.teleport(home);
        player.sendMessage("§aТелепортовано додому!");
        
        // Встановити cooldown (5 хвилин)
        if (!player.hasPermission("myplugin.home.bypass")) {
            cooldownManager.setCooldown(player, "home", 300);
        }
        
        return true;
    }
}
```

## Практичне завдання

Створіть систему команд для economy плагіну:
1. Базовий клас SubCommand
2. Підкоманди: balance, pay, top, set, add, remove
3. CommandManager з автоматичним tab-completion
4. Валідація всіх аргументів
5. Cooldown для команди pay (30 секунд)
6. Різні права для різних підкоманд',
  3, FALSE
);

-- Квіз для Модуля 4
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-4', 'lesson-4-4',
  'Тест: Commands та TabCompleters',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-4-4",
    "questions": [
      {
        "id": "q1",
        "question": "Який інтерфейс потрібно імплементувати для створення команди?",
        "options": ["Command", "CommandExecutor", "CommandHandler", "Executor"],
        "correctAnswer": 1,
        "explanation": "CommandExecutor - стандартний інтерфейс для обробки команд у Bukkit API"
      },
      {
        "id": "q2",
        "question": "Де реєструються метадані команди (usage, permission, aliases)?",
        "options": ["У Java коді", "У plugin.yml", "У config.yml", "У commands.yml"],
        "correctAnswer": 1,
        "explanation": "plugin.yml містить секцію commands: з усіма метаданими команд"
      },
      {
        "id": "q3",
        "question": "Що повертає метод onCommand() при успішному виконанні?",
        "options": ["void", "boolean true", "boolean false", "String"],
        "correctAnswer": 1,
        "explanation": "onCommand() повертає true якщо команда виконана успішно, false - показує usage з plugin.yml"
      },
      {
        "id": "q4",
        "question": "Який інтерфейс відповідає за tab-completion?",
        "options": ["TabHandler", "TabCompleter", "AutoComplete", "CommandCompleter"],
        "correctAnswer": 1,
        "explanation": "TabCompleter інтерфейс обробляє автодоповнення при натисканні Tab"
      },
      {
        "id": "q5",
        "question": "Як отримати аргументи команди без першого елемента?",
        "options": [
          "args.skip(1)",
          "Arrays.copyOfRange(args, 1, args.length)",
          "args.subArray(1)",
          "args.slice(1)"
        ],
        "correctAnswer": 1,
        "explanation": "Arrays.copyOfRange(args, 1, args.length) створює новий масив починаючи з індексу 1"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 4 додано! 4 уроки створено.' as status;
