-- =============================================
-- Модуль 6: Databases (MySQL, SQLite, MongoDB)
-- =============================================

-- Урок 6.1
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-6', 'lesson-6-1',
  'MySQL - підключення та основи',
  '18 хв', 'text',
  '# MySQL для Minecraft плагінів

MySQL - найпопулярніша база даних для серверів Minecraft.

## Додати залежності

pom.xml:
```xml
<dependencies>
    <!-- MySQL Connector -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>8.0.33</version>
        <scope>compile</scope>
    </dependency>
    
    <!-- HikariCP - Connection Pool -->
    <dependency>
        <groupId>com.zaxxer</groupId>
        <artifactId>HikariCP</artifactId>
        <version>5.0.1</version>
        <scope>compile</scope>
    </dependency>
</dependencies>
```

## Конфігурація підключення

config.yml:
```yaml
database:
  type: mysql  # або sqlite
  mysql:
    host: localhost
    port: 3306
    database: minecraft
    username: root
    password: password123
    pool-size: 10
```

## Клас для підключення

```java
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

public class DatabaseManager {
    
    private final JavaPlugin plugin;
    private HikariDataSource dataSource;
    
    public DatabaseManager(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    public void connect() {
        try {
            HikariConfig config = new HikariConfig();
            
            String host = plugin.getConfig().getString("database.mysql.host");
            int port = plugin.getConfig().getInt("database.mysql.port");
            String database = plugin.getConfig().getString("database.mysql.database");
            String username = plugin.getConfig().getString("database.mysql.username");
            String password = plugin.getConfig().getString("database.mysql.password");
            
            config.setJdbcUrl("jdbc:mysql://" + host + ":" + port + "/" + database);
            config.setUsername(username);
            config.setPassword(password);
            
            // Налаштування пулу
            config.setMaximumPoolSize(plugin.getConfig().getInt("database.mysql.pool-size", 10));
            config.setMinimumIdle(2);
            config.setMaxLifetime(1800000); // 30 хвилин
            config.setConnectionTimeout(5000); // 5 секунд
            
            // Оптимізація для MySQL
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("useServerPrepStmts", "true");
            
            dataSource = new HikariDataSource(config);
            
            plugin.getLogger().info("Підключено до MySQL!");
            
        } catch (Exception e) {
            plugin.getLogger().severe("Помилка підключення до MySQL: " + e.getMessage());
        }
    }
    
    public Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            throw new SQLException("DataSource не ініціалізовано!");
        }
        return dataSource.getConnection();
    }
    
    public void disconnect() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            plugin.getLogger().info("Відключено від MySQL");
        }
    }
    
    public boolean isConnected() {
        return dataSource != null && !dataSource.isClosed();
    }
}
```

## Створення таблиць

```java
public class DatabaseInitializer {
    
    private final DatabaseManager db;
    
    public DatabaseInitializer(DatabaseManager db) {
        this.db = db;
    }
    
    public void createTables() {
        // Таблиця гравців
        String createPlayers = 
            "CREATE TABLE IF NOT EXISTS players (" +
            "uuid VARCHAR(36) PRIMARY KEY," +
            "username VARCHAR(16) NOT NULL," +
            "balance DOUBLE DEFAULT 0," +
            "level INT DEFAULT 1," +
            "exp INT DEFAULT 0," +
            "first_join BIGINT NOT NULL," +
            "last_seen BIGINT NOT NULL," +
            "play_time BIGINT DEFAULT 0," +
            "INDEX idx_username (username)," +
            "INDEX idx_balance (balance DESC)" +
            ")";
        
        // Таблиця статистики
        String createStats = 
            "CREATE TABLE IF NOT EXISTS player_stats (" +
            "id INT AUTO_INCREMENT PRIMARY KEY," +
            "player_uuid VARCHAR(36) NOT NULL," +
            "kills INT DEFAULT 0," +
            "deaths INT DEFAULT 0," +
            "blocks_broken INT DEFAULT 0," +
            "blocks_placed INT DEFAULT 0," +
            "FOREIGN KEY (player_uuid) REFERENCES players(uuid) ON DELETE CASCADE," +
            "UNIQUE KEY unique_player (player_uuid)" +
            ")";
        
        // Таблиця транзакцій
        String createTransactions = 
            "CREATE TABLE IF NOT EXISTS transactions (" +
            "id INT AUTO_INCREMENT PRIMARY KEY," +
            "from_uuid VARCHAR(36)," +
            "to_uuid VARCHAR(36)," +
            "amount DOUBLE NOT NULL," +
            "reason VARCHAR(255)," +
            "timestamp BIGINT NOT NULL," +
            "INDEX idx_from (from_uuid)," +
            "INDEX idx_to (to_uuid)," +
            "INDEX idx_timestamp (timestamp DESC)" +
            ")";
        
        try (Connection conn = db.getConnection()) {
            conn.createStatement().execute(createPlayers);
            conn.createStatement().execute(createStats);
            conn.createStatement().execute(createTransactions);
            
            System.out.println("Таблиці створено!");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

## CRUD операції

```java
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PlayerDAO {
    
    private final DatabaseManager db;
    
    public PlayerDAO(DatabaseManager db) {
        this.db = db;
    }
    
    // CREATE - Створити гравця
    public void createPlayer(UUID uuid, String username) {
        String sql = "INSERT INTO players (uuid, username, first_join, last_seen) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            long now = System.currentTimeMillis();
            
            stmt.setString(1, uuid.toString());
            stmt.setString(2, username);
            stmt.setLong(3, now);
            stmt.setLong(4, now);
            
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // READ - Отримати баланс
    public double getBalance(UUID uuid) {
        String sql = "SELECT balance FROM players WHERE uuid = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, uuid.toString());
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("balance");
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // UPDATE - Оновити баланс
    public void setBalance(UUID uuid, double balance) {
        String sql = "UPDATE players SET balance = ? WHERE uuid = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setDouble(1, balance);
            stmt.setString(2, uuid.toString());
            
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // DELETE - Видалити гравця
    public void deletePlayer(UUID uuid) {
        String sql = "DELETE FROM players WHERE uuid = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, uuid.toString());
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Перевірити існування
    public boolean exists(UUID uuid) {
        String sql = "SELECT 1 FROM players WHERE uuid = ? LIMIT 1";
        
        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, uuid.toString());
            
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Топ-10 за балансом
    public List<PlayerData> getTopBalance(int limit) {
        List<PlayerData> top = new ArrayList<>();
        String sql = "SELECT uuid, username, balance FROM players ORDER BY balance DESC LIMIT ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    PlayerData data = new PlayerData();
                    data.uuid = UUID.fromString(rs.getString("uuid"));
                    data.username = rs.getString("username");
                    data.balance = rs.getDouble("balance");
                    top.add(data);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return top;
    }
}
```

## Транзакції

```java
public void transferMoney(UUID from, UUID to, double amount) {
    Connection conn = null;
    
    try {
        conn = db.getConnection();
        conn.setAutoCommit(false); // Почати транзакцію
        
        // Перевірити баланс
        String checkSql = "SELECT balance FROM players WHERE uuid = ?";
        try (PreparedStatement stmt = conn.prepareStatement(checkSql)) {
            stmt.setString(1, from.toString());
            ResultSet rs = stmt.executeQuery();
            
            if (!rs.next() || rs.getDouble("balance") < amount) {
                conn.rollback();
                return; // Недостатньо коштів
            }
        }
        
        // Зняти з відправника
        String deductSql = "UPDATE players SET balance = balance - ? WHERE uuid = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deductSql)) {
            stmt.setDouble(1, amount);
            stmt.setString(2, from.toString());
            stmt.executeUpdate();
        }
        
        // Додати отримувачу
        String addSql = "UPDATE players SET balance = balance + ? WHERE uuid = ?";
        try (PreparedStatement stmt = conn.prepareStatement(addSql)) {
            stmt.setDouble(1, amount);
            stmt.setString(2, to.toString());
            stmt.executeUpdate();
        }
        
        // Записати транзакцію
        String logSql = "INSERT INTO transactions (from_uuid, to_uuid, amount, reason, timestamp) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(logSql)) {
            stmt.setString(1, from.toString());
            stmt.setString(2, to.toString());
            stmt.setDouble(3, amount);
            stmt.setString(4, "transfer");
            stmt.setLong(5, System.currentTimeMillis());
            stmt.executeUpdate();
        }
        
        conn.commit(); // Підтвердити транзакцію
        
    } catch (SQLException e) {
        if (conn != null) {
            try {
                conn.rollback(); // Відмінити при помилці
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
```

## Практичне завдання

Створіть економічну систему:
- Таблиці: players, transactions, shops
- Методи: getBalance, addMoney, removeMoney, transfer
- Топ-10 найбагатших гравців
- Історія транзакцій (останні 50)
- Логування всіх операцій',
  1, FALSE
);

-- Урок 6.2
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-6', 'lesson-6-2',
  'SQLite - локальна база даних',
  '14 хв', 'text',
  '# SQLite для Minecraft плагінів

SQLite - проста файлова БД, ідеальна для малих-середніх серверів.

## Переваги SQLite

✅ Не потребує окремого сервера
✅ Один файл = вся база
✅ Швидка для малих обсягів
✅ Легка міграція (просто скопіювати файл)
✅ Вбудована в Java

## Додати залежність

pom.xml:
```xml
<dependencies>
    <!-- SQLite JDBC -->
    <dependency>
        <groupId>org.xerial</groupId>
        <artifactId>sqlite-jdbc</artifactId>
        <version>3.43.0.0</version>
        <scope>compile</scope>
    </dependency>
</dependencies>
```

## Клас для SQLite

```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class SQLiteDatabase {
    
    private final JavaPlugin plugin;
    private Connection connection;
    private final File databaseFile;
    
    public SQLiteDatabase(JavaPlugin plugin) {
        this.plugin = plugin;
        this.databaseFile = new File(plugin.getDataFolder(), "database.db");
    }
    
    public void connect() {
        try {
            if (!plugin.getDataFolder().exists()) {
                plugin.getDataFolder().mkdirs();
            }
            
            Class.forName("org.sqlite.JDBC");
            
            String url = "jdbc:sqlite:" + databaseFile.getAbsolutePath();
            connection = DriverManager.getConnection(url);
            
            plugin.getLogger().info("Підключено до SQLite!");
            
        } catch (ClassNotFoundException | SQLException e) {
            plugin.getLogger().severe("Помилка підключення до SQLite: " + e.getMessage());
        }
    }
    
    public Connection getConnection() {
        try {
            if (connection == null || connection.isClosed()) {
                connect();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return connection;
    }
    
    public void disconnect() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                plugin.getLogger().info("Відключено від SQLite");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

## Створення таблиць SQLite

```java
public void createTables() {
    String createPlayers = 
        "CREATE TABLE IF NOT EXISTS players (" +
        "uuid TEXT PRIMARY KEY," +
        "username TEXT NOT NULL," +
        "balance REAL DEFAULT 0," +
        "level INTEGER DEFAULT 1," +
        "exp INTEGER DEFAULT 0," +
        "first_join INTEGER NOT NULL," +
        "last_seen INTEGER NOT NULL," +
        "play_time INTEGER DEFAULT 0" +
        ")";
    
    String createStats = 
        "CREATE TABLE IF NOT EXISTS player_stats (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "player_uuid TEXT NOT NULL," +
        "kills INTEGER DEFAULT 0," +
        "deaths INTEGER DEFAULT 0," +
        "blocks_broken INTEGER DEFAULT 0," +
        "blocks_placed INTEGER DEFAULT 0," +
        "FOREIGN KEY (player_uuid) REFERENCES players(uuid) ON DELETE CASCADE," +
        "UNIQUE(player_uuid)" +
        ")";
    
    // Індекси для оптимізації
    String createIndexes = 
        "CREATE INDEX IF NOT EXISTS idx_username ON players(username);" +
        "CREATE INDEX IF NOT EXISTS idx_balance ON players(balance DESC);";
    
    try (Connection conn = getConnection()) {
        conn.createStatement().execute(createPlayers);
        conn.createStatement().execute(createStats);
        conn.createStatement().execute(createIndexes);
        
        plugin.getLogger().info("Таблиці SQLite створено!");
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
```

## Універсальний DatabaseManager

Підтримка MySQL та SQLite:
```java
public class DatabaseManager {
    
    private final JavaPlugin plugin;
    private Connection connection;
    private boolean isMySQL;
    
    public DatabaseManager(JavaPlugin plugin) {
        this.plugin = plugin;
    }
    
    public void connect() {
        String type = plugin.getConfig().getString("database.type", "sqlite");
        
        if (type.equalsIgnoreCase("mysql")) {
            connectMySQL();
        } else {
            connectSQLite();
        }
    }
    
    private void connectMySQL() {
        try {
            HikariConfig config = new HikariConfig();
            // ... MySQL config
            dataSource = new HikariDataSource(config);
            isMySQL = true;
            plugin.getLogger().info("Використовується MySQL");
        } catch (Exception e) {
            plugin.getLogger().warning("MySQL недоступний, перехід на SQLite");
            connectSQLite();
        }
    }
    
    private void connectSQLite() {
        try {
            File dbFile = new File(plugin.getDataFolder(), "database.db");
            String url = "jdbc:sqlite:" + dbFile.getAbsolutePath();
            connection = DriverManager.getConnection(url);
            isMySQL = false;
            plugin.getLogger().info("Використовується SQLite");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public String getAutoIncrementKeyword() {
        return isMySQL ? "AUTO_INCREMENT" : "AUTOINCREMENT";
    }
    
    public String getTextType() {
        return isMySQL ? "VARCHAR(255)" : "TEXT";
    }
    
    public String getBigIntType() {
        return isMySQL ? "BIGINT" : "INTEGER";
    }
}
```

## Batch операції (оптимізація)

```java
public void saveMultiplePlayers(List<PlayerData> players) {
    String sql = "INSERT OR REPLACE INTO players (uuid, username, balance, level) VALUES (?, ?, ?, ?)";
    
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        conn.setAutoCommit(false);
        
        for (PlayerData player : players) {
            stmt.setString(1, player.uuid.toString());
            stmt.setString(2, player.username);
            stmt.setDouble(3, player.balance);
            stmt.setInt(4, player.level);
            stmt.addBatch();
        }
        
        stmt.executeBatch();
        conn.commit();
        
        plugin.getLogger().info("Збережено " + players.size() + " гравців");
        
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
```

## Міграція з SQLite на MySQL

```java
public class DatabaseMigrator {
    
    public void migrateSQLiteToMySQL(SQLiteDatabase sqlite, MySQLDatabase mysql) {
        plugin.getLogger().info("Початок міграції SQLite → MySQL...");
        
        try {
            // Міграція гравців
            String selectPlayers = "SELECT * FROM players";
            try (ResultSet rs = sqlite.getConnection().createStatement().executeQuery(selectPlayers)) {
                
                String insertPlayer = "INSERT INTO players (uuid, username, balance, level, exp, first_join, last_seen) " +
                                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
                
                PreparedStatement stmt = mysql.getConnection().prepareStatement(insertPlayer);
                int count = 0;
                
                while (rs.next()) {
                    stmt.setString(1, rs.getString("uuid"));
                    stmt.setString(2, rs.getString("username"));
                    stmt.setDouble(3, rs.getDouble("balance"));
                    stmt.setInt(4, rs.getInt("level"));
                    stmt.setInt(5, rs.getInt("exp"));
                    stmt.setLong(6, rs.getLong("first_join"));
                    stmt.setLong(7, rs.getLong("last_seen"));
                    stmt.addBatch();
                    count++;
                    
                    if (count % 100 == 0) {
                        stmt.executeBatch();
                        plugin.getLogger().info("Міґровано " + count + " гравців...");
                    }
                }
                
                stmt.executeBatch();
                plugin.getLogger().info("Міграція завершена! Всього: " + count + " гравців");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

## Backup системи

```java
public class DatabaseBackup {
    
    public void backupSQLite(File dbFile) {
        File backupFolder = new File(plugin.getDataFolder(), "backups");
        if (!backupFolder.exists()) {
            backupFolder.mkdirs();
        }
        
        String timestamp = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss").format(new Date());
        File backupFile = new File(backupFolder, "database_" + timestamp + ".db");
        
        try {
            Files.copy(dbFile.toPath(), backupFile.toPath());
            plugin.getLogger().info("Backup створено: " + backupFile.getName());
        } catch (IOException e) {
            plugin.getLogger().severe("Помилка створення backup: " + e.getMessage());
        }
    }
    
    // Автоматичний backup
    public void scheduleBackups() {
        new BukkitRunnable() {
            @Override
            public void run() {
                backupSQLite(new File(plugin.getDataFolder(), "database.db"));
            }
        }.runTaskTimerAsynchronously(plugin, 72000L, 72000L); // Кожну годину
    }
}
```

## Вакуум SQLite (оптимізація)

```java
public void vacuumDatabase() {
    try (Connection conn = getConnection()) {
        conn.createStatement().execute("VACUUM");
        plugin.getLogger().info("SQLite база оптимізована (VACUUM)");
    } catch (SQLException e) {
        e.printStackTrace();
    }
}

// Автоматичний vacuum при вимкненні
@Override
public void onDisable() {
    if (!isMySQL) {
        vacuumDatabase();
    }
    disconnect();
}
```

## Порівняння MySQL vs SQLite

**MySQL переваги:**
- Краща продуктивність для великих даних
- Concurrent доступ
- Розширені функції
- Network доступ

**SQLite переваги:**
- Простота налаштування
- Один файл
- Швидше для малих обсягів
- Легкий backup

**Рекомендації:**
- **SQLite**: <100 гравців, простий плагін
- **MySQL**: >100 гравців, network сервера

## Практичне завдання

Реалізуйте систему з підтримкою обох БД:
- Автовибір (MySQL → SQLite fallback)
- Міграція між БД
- Автоматичний backup SQLite
- VACUUM при вимкненні
- Команда `/db info` (тип БД, розмір, к-сть записів)',
  2, FALSE
);

-- Урок 6.3
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-6', 'lesson-6-3',
  'Async queries та Connection Pooling',
  '16 хв', 'text',
  '# Асинхронна робота з базами даних

**НІКОЛИ** не блокуйте main thread запитами до БД!

## Чому async?

```java
// ❌ ПОГАНО - блокує main thread
@EventHandler
public void onJoin(PlayerJoinEvent event) {
    Player player = event.getPlayer();
    
    // Запит до БД займає 50-200ms
    double balance = database.getBalance(player.getUniqueId());
    player.sendMessage("Баланс: " + balance);
    
    // За цей час сервер "завис" для всіх гравців!
}

// ✅ ДОБРЕ - async
@EventHandler
public void onJoin(PlayerJoinEvent event) {
    Player player = event.getPlayer();
    
    Bukkit.getScheduler().runTaskAsynchronously(plugin, () -> {
        double balance = database.getBalance(player.getUniqueId());
        
        // Повернутись на main thread для взаємодії з API
        Bukkit.getScheduler().runTask(plugin, () -> {
            player.sendMessage("Баланс: " + balance);
        });
    });
}
```

## Async утиліта

```java
public class AsyncDatabase {
    
    private final JavaPlugin plugin;
    private final DatabaseManager db;
    
    public AsyncDatabase(JavaPlugin plugin, DatabaseManager db) {
        this.plugin = plugin;
        this.db = db;
    }
    
    public CompletableFuture<Double> getBalanceAsync(UUID uuid) {
        return CompletableFuture.supplyAsync(() -> {
            return db.getBalance(uuid);
        });
    }
    
    public CompletableFuture<Void> setBalanceAsync(UUID uuid, double balance) {
        return CompletableFuture.runAsync(() -> {
            db.setBalance(uuid, balance);
        });
    }
    
    public CompletableFuture<Boolean> existsAsync(UUID uuid) {
        return CompletableFuture.supplyAsync(() -> {
            return db.exists(uuid);
        });
    }
}

// Використання
asyncDb.getBalanceAsync(player.getUniqueId()).thenAccept(balance -> {
    // Цей код виконається async коли запит завершиться
    Bukkit.getScheduler().runTask(plugin, () -> {
        player.sendMessage("Ваш баланс: $" + balance);
    });
});
```

## CompletableFuture chains

```java
// Послідовність async операцій
public void transferMoneyAsync(UUID from, UUID to, double amount, Consumer<Boolean> callback) {
    
    // Перевірити баланс
    asyncDb.getBalanceAsync(from)
        .thenCompose(balance -> {
            if (balance < amount) {
                return CompletableFuture.completedFuture(false);
            }
            
            // Виконати переказ
            return asyncDb.setBalanceAsync(from, balance - amount)
                .thenCompose(v -> asyncDb.getBalanceAsync(to))
                .thenCompose(toBalance -> asyncDb.setBalanceAsync(to, toBalance + amount))
                .thenApply(v -> true);
        })
        .thenAccept(success -> {
            // Повернутись на main thread
            Bukkit.getScheduler().runTask(plugin, () -> {
                callback.accept(success);
            });
        })
        .exceptionally(ex -> {
            ex.printStackTrace();
            Bukkit.getScheduler().runTask(plugin, () -> {
                callback.accept(false);
            });
            return null;
        });
}

// Використання
transferMoneyAsync(playerUUID, targetUUID, 100.0, success -> {
    if (success) {
        player.sendMessage("§aПереказ успішний!");
    } else {
        player.sendMessage("§cНедостатньо коштів!");
    }
});
```

## Cache система

```java
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;

public class CachedDatabase {
    
    private final AsyncDatabase asyncDb;
    private final Cache<UUID, Double> balanceCache;
    private final Cache<UUID, PlayerData> playerCache;
    
    public CachedDatabase(AsyncDatabase asyncDb) {
        this.asyncDb = asyncDb;
        
        // Cache на 10 хвилин, макс 1000 записів
        this.balanceCache = Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .maximumSize(1000)
            .build();
        
        this.playerCache = Caffeine.newBuilder()
            .expireAfterWrite(15, TimeUnit.MINUTES)
            .maximumSize(500)
            .build();
    }
    
    public CompletableFuture<Double> getBalance(UUID uuid) {
        // Спробувати з кешу
        Double cached = balanceCache.getIfPresent(uuid);
        if (cached != null) {
            return CompletableFuture.completedFuture(cached);
        }
        
        // Завантажити з БД
        return asyncDb.getBalanceAsync(uuid).thenApply(balance -> {
            balanceCache.put(uuid, balance);
            return balance;
        });
    }
    
    public CompletableFuture<Void> setBalance(UUID uuid, double balance) {
        // Оновити кеш
        balanceCache.put(uuid, balance);
        
        // Оновити БД async
        return asyncDb.setBalanceAsync(uuid, balance);
    }
    
    public void invalidate(UUID uuid) {
        balanceCache.invalidate(uuid);
        playerCache.invalidate(uuid);
    }
    
    public void saveAll() {
        // Зберегти всі закешовані зміни
        balanceCache.asMap().forEach((uuid, balance) -> {
            asyncDb.setBalanceAsync(uuid, balance);
        });
    }
}
```

## Batch async операції

```java
public CompletableFuture<Void> saveAllPlayersAsync(Collection<Player> players) {
    List<CompletableFuture<Void>> futures = new ArrayList<>();
    
    for (Player player : players) {
        CompletableFuture<Void> future = CompletableFuture.runAsync(() -> {
            savePlayerData(player.getUniqueId());
        });
        futures.add(future);
    }
    
    // Чекати поки всі збережуться
    return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]));
}

// Використання при вимкненні сервера
@Override
public void onDisable() {
    plugin.getLogger().info("Збереження даних...");
    
    try {
        saveAllPlayersAsync(Bukkit.getOnlinePlayers())
            .get(10, TimeUnit.SECONDS); // Чекати макс 10 секунд
        
        plugin.getLogger().info("Дані збережено!");
    } catch (Exception e) {
        plugin.getLogger().severe("Помилка збереження: " + e.getMessage());
    }
}
```

## Retry механізм

```java
public <T> CompletableFuture<T> retryQuery(Supplier<T> query, int maxAttempts) {
    return CompletableFuture.supplyAsync(() -> {
        int attempts = 0;
        Exception lastException = null;
        
        while (attempts < maxAttempts) {
            try {
                return query.get();
            } catch (Exception e) {
                lastException = e;
                attempts++;
                
                if (attempts < maxAttempts) {
                    try {
                        Thread.sleep(1000 * attempts); // Exponential backoff
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                }
            }
        }
        
        throw new RuntimeException("Не вдалося виконати запит після " + maxAttempts + " спроб", lastException);
    });
}

// Використання
retryQuery(() -> db.getBalance(uuid), 3)
    .thenAccept(balance -> {
        player.sendMessage("Баланс: " + balance);
    })
    .exceptionally(ex -> {
        player.sendMessage("§cПомилка завантаження даних");
        ex.printStackTrace();
        return null;
    });
```

## Deadlock запобігання

```java
public class SafeTransactionManager {
    
    private final Set<UUID> lockedPlayers = ConcurrentHashMap.newKeySet();
    
    public CompletableFuture<Boolean> transfer(UUID from, UUID to, double amount) {
        // Упорядкувати UUID щоб уникнути deadlock
        UUID first = from.compareTo(to) < 0 ? from : to;
        UUID second = from.compareTo(to) < 0 ? to : from;
        
        return CompletableFuture.supplyAsync(() -> {
            // Заблокувати в правильному порядку
            synchronized (getLock(first)) {
                synchronized (getLock(second)) {
                    // Виконати транзакцію
                    return performTransfer(from, to, amount);
                }
            }
        });
    }
    
    private Object getLock(UUID uuid) {
        // Використати String pool для locks
        return uuid.toString().intern();
    }
}
```

## Моніторинг запитів

```java
public class QueryMonitor {
    
    private final Map<String, QueryStats> stats = new ConcurrentHashMap<>();
    
    public <T> T executeAndTrack(String queryName, Supplier<T> query) {
        long start = System.nanoTime();
        
        try {
            T result = query.get();
            long duration = (System.nanoTime() - start) / 1_000_000; // ms
            
            recordSuccess(queryName, duration);
            return result;
            
        } catch (Exception e) {
            recordFailure(queryName);
            throw e;
        }
    }
    
    private void recordSuccess(String queryName, long duration) {
        stats.computeIfAbsent(queryName, k -> new QueryStats())
            .recordSuccess(duration);
        
        if (duration > 100) {
            plugin.getLogger().warning("Повільний запит " + queryName + ": " + duration + "ms");
        }
    }
    
    public void printStats() {
        plugin.getLogger().info("=== Query Statistics ===");
        stats.forEach((name, stat) -> {
            plugin.getLogger().info(String.format(
                "%s: avg=%.2fms, max=%dms, count=%d, errors=%d",
                name, stat.getAverage(), stat.getMax(), stat.getCount(), stat.getErrors()
            ));
        });
    }
}
```

## Практичне завдання

Створіть async систему:
1. AsyncDatabase wrapper з CompletableFuture
2. Cache з Caffeine (балансів, статистики)
3. Batch збереження при вимкненні
4. Retry механізм (3 спроби)
5. Query monitoring (час виконання, помилки)
6. Команда `/db stats` для перегляду статистики',
  3, FALSE
);

-- Квіз для Модуля 6
INSERT INTO course_lessons (
  course_id, module_id, lesson_id, title, duration, type, content, quiz_data, order_index, is_free_preview
)
VALUES (
  'paid-1', 'module-6', 'lesson-6-4',
  'Тест: Бази даних',
  '10 хв', 'quiz', '',
  '{
    "id": "quiz-6-4",
    "questions": [
      {
        "id": "q1",
        "question": "Що таке HikariCP?",
        "options": [
          "MySQL драйвер",
          "Connection pool для оптимізації підключень",
          "ORM фреймворк",
          "Async бібліотека"
        ],
        "correctAnswer": 1,
        "explanation": "HikariCP - найшвидший connection pool для Java, управляє пулом підключень до БД"
      },
      {
        "id": "q2",
        "question": "Чому важливо використовувати PreparedStatement?",
        "options": [
          "Швидше працює",
          "Захист від SQL injection та кращі performance",
          "Простіше писати",
          "Обов''язково для SQLite"
        ],
        "correctAnswer": 1,
        "explanation": "PreparedStatement захищає від SQL injection, кешує запити та оптимізує виконання"
      },
      {
        "id": "q3",
        "question": "Коли використовувати SQLite замість MySQL?",
        "options": [
          "Завжди краще SQLite",
          "Для малих серверів (<100 гравців) та простих плагінів",
          "Тільки для тестування",
          "Ніколи не використовувати SQLite"
        ],
        "correctAnswer": 1,
        "explanation": "SQLite ідеальний для малих-середніх серверів, не потребує налаштування, один файл"
      },
      {
        "id": "q4",
        "question": "Чому database запити мають бути async?",
        "options": [
          "Це не обов''язково",
          "Щоб не блокувати main thread сервера",
          "MySQL вимагає async",
          "Для кращої безпеки"
        ],
        "correctAnswer": 1,
        "explanation": "Запити до БД можуть займати 50-200ms, блокування main thread лагає сервер для всіх гравців"
      },
      {
        "id": "q5",
        "question": "Що робить VACUUM в SQLite?",
        "options": [
          "Видаляє всі дані",
          "Оптимізує та дефрагментує базу даних",
          "Створює backup",
          "Перевіряє на помилки"
        ],
        "correctAnswer": 1,
        "explanation": "VACUUM відновлює простір, дефрагментує та оптимізує SQLite базу після видалення даних"
      }
    ]
  }'::jsonb,
  4, FALSE
);

SELECT 'Модуль 6 додано! 4 уроки створено.' as status;
