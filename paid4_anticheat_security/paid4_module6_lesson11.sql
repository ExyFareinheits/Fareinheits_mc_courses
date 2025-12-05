-- =====================================================
-- МОДУЛЬ 6, УРОК 11: VPN/Alt Detection APIs
-- =====================================================
-- Курс: paid-4 (Advanced Anti-Cheat та Security Systems)

DO $$
DECLARE
  v_module_id TEXT;
  v_lesson_id TEXT;
BEGIN
  SELECT id::text INTO v_module_id 
  FROM course_modules 
  WHERE course_id = 'paid-4' AND order_index = 6;
  
  IF v_module_id IS NULL THEN
    INSERT INTO course_modules (course_id, module_id, title, description, order_index)
    VALUES (
      'paid-4',
      'module-6',
      'VPN та Alt Account Detection',
      'VPN detection APIs, browser fingerprinting, device tracking',
      6
    )
    RETURNING id::text INTO v_module_id;
  END IF;

  v_lesson_id := gen_random_uuid()::text;
  
  DELETE FROM course_lessons 
  WHERE module_id = v_module_id AND order_index = 11;
  
  INSERT INTO course_lessons (
    course_id, module_id, lesson_id, title, type, content, duration, order_index, is_free_preview
  ) VALUES (
    'paid-4',
    v_module_id,
    v_lesson_id,
    'VPN Detection APIs: Implementation Guide',
    'text',
    '# VPN Detection APIs: Implementation Guide

VPN та proxy detection критичні для ban evasion prevention. Alt accounts через VPN - головна проблема модерації серверів.

---

## Чому VPN Detection Важливий

### Проблема Alt Accounts

```
Banned Player Workflow:
1. Player banned за cheating
2. Buy new Minecraft account ($5-10)
3. Connect через VPN
4. Different IP = bypass IP ban
5. Continue cheating

Without VPN Detection:
- Permanent bans неефективні
- Same player повертається 10+ разів
- Moderation team frustration
- Legitimate players quit

With VPN Detection:
- Block VPN connections
- Force real IP exposure
- Alt accounts harder to use
- Effective ban enforcement
```

---

## VPN Detection APIs Порівняння

### IPHub API

```
Website: https://iphub.info
Pricing: 
- Free: 1,000 requests/day
- Basic: $5/month (5,000/day)
- Pro: $20/month (50,000/day)

Accuracy: 85-90%
Database Size: 500M+ IPs
Update Frequency: Daily

Response Format:
{
  "ip": "1.2.3.4",
  "countryCode": "US",
  "countryName": "United States",
  "asn": 15169,
  "isp": "Google LLC",
  "block": 1,  // 0 = residential, 1 = VPN/proxy, 2 = datacenter
  "hostname": "google-proxy.com"
}

Pros:
+ Fast response (<100ms)
+ Good free tier
+ Simple API

Cons:
- False positives для mobile networks
- Paid tier required для busy servers
```

### VPNBlocker API

```
Website: https://vpnblocker.net
Pricing:
- Free: 500 requests/day
- Standard: $10/month (10,000/day)
- Premium: $30/month (100,000/day)

Accuracy: 90-93%
Database: 1B+ IPs
Features: VPN/Proxy/Tor/Datacenter detection

Response:
{
  "ip": "1.2.3.4",
  "host-ip": true,
  "vpn-or-proxy": "yes",
  "risk-score": 95,
  "country": "UA",
  "city": "Kyiv",
  "package": "standard"
}

Pros:
+ Highest accuracy
+ Risk score (0-100)
+ Separate Tor detection

Cons:
- More expensive
- Slower response (150-200ms)
```

### GetIPIntel API

```
Website: https://getipintel.net
Pricing: FREE (donation-based)
Rate Limit: 500 requests/day, 15/minute

Response: 
0.99 = Very likely proxy/VPN
0.50 = Uncertain
0.01 = Very likely residential

Pros:
+ Completely free
+ No API key required
+ Machine learning based

Cons:
- Slow (300-500ms)
- Rate limits strict
- Less reliable database
```

---

## Java Implementation

### Basic VPN Check Plugin

```java
package com.example.vpnblock;

import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.AsyncPlayerPreLoginEvent;
import org.bukkit.plugin.java.JavaPlugin;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class VPNBlockPlugin extends JavaPlugin implements Listener {
    
    private String apiKey;
    private String apiProvider; // "iphub" або "vpnblocker"
    private boolean kickVPN;
    private boolean alertStaff;
    
    @Override
    public void onEnable() {
        saveDefaultConfig();
        apiKey = getConfig().getString("api-key");
        apiProvider = getConfig().getString("api-provider", "iphub");
        kickVPN = getConfig().getBoolean("kick-vpn-users", true);
        alertStaff = getConfig().getBoolean("alert-staff", true);
        
        getServer().getPluginManager().registerEvents(this, this);
    }
    
    @EventHandler
    public void onPreLogin(AsyncPlayerPreLoginEvent event) {
        String playerName = event.getName();
        String ip = event.getAddress().getHostAddress();
        
        // Skip localhost
        if (ip.equals("127.0.0.1") || ip.startsWith("192.168.")) {
            return;
        }
        
        try {
            VPNCheckResult result = checkVPN(ip);
            
            if (result.isVPN()) {
                // Log to database
                logVPNAttempt(playerName, ip, result);
                
                if (kickVPN) {
                    event.disallow(
                        AsyncPlayerPreLoginEvent.Result.KICK_OTHER,
                        "§cVPN/Proxy detected!\n\n" +
                        "§7Please disable your VPN to connect.\n" +
                        "§7If you think this is an error, contact staff."
                    );
                }
                
                if (alertStaff) {
                    alertStaffAsync(playerName, ip, result);
                }
            }
            
        } catch (Exception e) {
            getLogger().warning("VPN check failed for " + ip + ": " + e.getMessage());
            // Allow connection on API failure
        }
    }
    
    private VPNCheckResult checkVPN(String ip) throws Exception {
        if (apiProvider.equals("iphub")) {
            return checkIPHub(ip);
        } else if (apiProvider.equals("vpnblocker")) {
            return checkVPNBlocker(ip);
        }
        throw new IllegalArgumentException("Unknown API provider: " + apiProvider);
    }
    
    private VPNCheckResult checkIPHub(String ip) throws Exception {
        String apiUrl = "http://v2.api.iphub.info/ip/" + ip;
        
        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("X-Key", apiKey);
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);
        
        int responseCode = conn.getResponseCode();
        if (responseCode != 200) {
            throw new Exception("API returned code " + responseCode);
        }
        
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(conn.getInputStream())
        );
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();
        
        JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
        
        int block = json.get("block").getAsInt();
        String country = json.get("countryCode").getAsString();
        String isp = json.get("isp").getAsString();
        
        return new VPNCheckResult(
            block == 1, // VPN/proxy
            block,
            country,
            isp,
            "IPHub"
        );
    }
    
    private VPNCheckResult checkVPNBlocker(String ip) throws Exception {
        String apiUrl = "https://api.vpnblocker.net/v2/json/" + ip + "/" + apiKey;
        
        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);
        
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(conn.getInputStream())
        );
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();
        
        JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
        
        String vpnStatus = json.get("vpn-or-proxy").getAsString();
        int riskScore = json.has("risk-score") ? json.get("risk-score").getAsInt() : 0;
        String country = json.get("country").getAsString();
        
        return new VPNCheckResult(
            vpnStatus.equals("yes"),
            riskScore,
            country,
            "N/A",
            "VPNBlocker"
        );
    }
    
    private void logVPNAttempt(String player, String ip, VPNCheckResult result) {
        // Log to database або file
        getLogger().info(String.format(
            "VPN detected: %s from %s (%s, %s) - Risk: %d",
            player, ip, result.getCountry(), result.getIsp(), result.getRiskScore()
        ));
    }
    
    private void alertStaffAsync(String player, String ip, VPNCheckResult result) {
        getServer().getScheduler().runTask(this, () -> {
            String message = String.format(
                "§c[VPN] §f%s §7attempted connection from §c%s §7(%s)",
                player, ip, result.getCountry()
            );
            
            getServer().getOnlinePlayers().stream()
                .filter(p -> p.hasPermission("vpnblock.alerts"))
                .forEach(p -> p.sendMessage(message));
        });
    }
}

class VPNCheckResult {
    private final boolean isVPN;
    private final int riskScore;
    private final String country;
    private final String isp;
    private final String provider;
    
    public VPNCheckResult(boolean isVPN, int riskScore, String country, 
                          String isp, String provider) {
        this.isVPN = isVPN;
        this.riskScore = riskScore;
        this.country = country;
        this.isp = isp;
        this.provider = provider;
    }
    
    public boolean isVPN() { return isVPN; }
    public int getRiskScore() { return riskScore; }
    public String getCountry() { return country; }
    public String getIsp() { return isp; }
    public String getProvider() { return provider; }
}
```

### Config.yml

```yaml
# VPN Block Configuration

# API Provider: iphub, vpnblocker, getipintel
api-provider: iphub

# API Key (not needed for getipintel)
api-key: your_api_key_here

# Actions
kick-vpn-users: true
alert-staff: true

# Whitelist IPs (never check these)
whitelist-ips:
  - 1.2.3.4
  - 5.6.7.8

# Whitelist players (bypass VPN check)
whitelist-players:
  - Admin1
  - Moderator2

# Cache settings (reduce API calls)
cache-enabled: true
cache-duration-minutes: 60

# Bypass permission: vpnblock.bypass
```

---

## Advanced Features

### IP Caching

```java
public class VPNCache {
    private final Map<String, CachedResult> cache = new ConcurrentHashMap<>();
    private final long cacheDuration;
    
    public VPNCache(long cacheDurationMinutes) {
        this.cacheDuration = cacheDurationMinutes * 60 * 1000;
    }
    
    public VPNCheckResult get(String ip) {
        CachedResult cached = cache.get(ip);
        if (cached != null && !cached.isExpired()) {
            return cached.getResult();
        }
        return null;
    }
    
    public void put(String ip, VPNCheckResult result) {
        cache.put(ip, new CachedResult(result, System.currentTimeMillis()));
    }
    
    public void cleanup() {
        long now = System.currentTimeMillis();
        cache.entrySet().removeIf(entry -> 
            now - entry.getValue().getTimestamp() > cacheDuration
        );
    }
    
    private static class CachedResult {
        private final VPNCheckResult result;
        private final long timestamp;
        
        public CachedResult(VPNCheckResult result, long timestamp) {
            this.result = result;
            this.timestamp = timestamp;
        }
        
        public boolean isExpired() {
            return System.currentTimeMillis() - timestamp > 3600000; // 1 hour
        }
        
        public VPNCheckResult getResult() { return result; }
        public long getTimestamp() { return timestamp; }
    }
}
```

### Database Logging

```java
public class VPNLogger {
    private final Connection database;
    
    public void logAttempt(String player, String ip, VPNCheckResult result, 
                          boolean allowed) {
        String query = "INSERT INTO vpn_logs (player, ip, is_vpn, risk_score, " +
                      "country, isp, provider, allowed, timestamp) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement stmt = database.prepareStatement(query)) {
            stmt.setString(1, player);
            stmt.setString(2, ip);
            stmt.setBoolean(3, result.isVPN());
            stmt.setInt(4, result.getRiskScore());
            stmt.setString(5, result.getCountry());
            stmt.setString(6, result.getIsp());
            stmt.setString(7, result.getProvider());
            stmt.setBoolean(8, allowed);
            stmt.setTimestamp(9, new Timestamp(System.currentTimeMillis()));
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public List<VPNAttempt> getRecentAttempts(int limit) {
        String query = "SELECT * FROM vpn_logs ORDER BY timestamp DESC LIMIT ?";
        List<VPNAttempt> attempts = new ArrayList<>();
        
        try (PreparedStatement stmt = database.prepareStatement(query)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                attempts.add(new VPNAttempt(
                    rs.getString("player"),
                    rs.getString("ip"),
                    rs.getBoolean("is_vpn"),
                    rs.getTimestamp("timestamp")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return attempts;
    }
}
```

---

## Best Practices

### Whitelist Management

```java
@Command("vpnwhitelist")
public void whitelistCommand(CommandSender sender, String[] args) {
    if (args.length < 2) {
        sender.sendMessage("Usage: /vpnwhitelist <add|remove|list> [player|ip]");
        return;
    }
    
    String action = args[0];
    
    if (action.equals("add")) {
        String target = args[1];
        if (target.matches("\\d+\\.\\d+\\.\\d+\\.\\d+")) {
            addIPWhitelist(target);
            sender.sendMessage("Added IP to whitelist: " + target);
        } else {
            addPlayerWhitelist(target);
            sender.sendMessage("Added player to whitelist: " + target);
        }
    } else if (action.equals("remove")) {
        // Similar logic
    } else if (action.equals("list")) {
        sender.sendMessage("Whitelisted IPs: " + getWhitelistedIPs());
        sender.sendMessage("Whitelisted Players: " + getWhitelistedPlayers());
    }
}
```

### False Positive Handling

```
Common False Positives:
1. Mobile networks (4G/5G) - часто flagged як datacenter
2. University networks - shared IPs
3. Corporate VPNs - legitimate use
4. Cloud gaming services (GeForce NOW, etc)

Solutions:
- Manual whitelist для known false positives
- Risk score threshold (block only >80)
- Appeal process для blocked players
- Multiple API cross-check
```

---

## Cost Analysis

```
Server Size: 500 average players
New connections: ~200/day
API calls needed: 200/day

Option 1: IPHub Free (1,000/day)
Cost: $0/month
Coverage: Sufficient

Option 2: IPHub Basic (5,000/day)
Cost: $5/month
Coverage: 25x headroom

Option 3: VPNBlocker Standard (10,000/day)
Cost: $10/month
Coverage: 50x headroom
Accuracy: +3-5% better

Recommendation: Start free, upgrade якщо >800 connections/day
```

---

## Висновок

VPN detection вимагає:

**Implementation:**
- Choose API based on budget/accuracy needs
- Implement caching для reduce costs
- Database logging для analytics
- Whitelist system для false positives

**Maintenance:**
- Monitor false positive rate
- Update whitelist regularly
- Check API status/limits
- Review logs weekly

**Balance:**
- Security vs player experience
- Block obvious VPNs
- Allow edge cases
- Clear communication

Наступний урок покриває browser fingerprinting для додаткового layer detection.',
    5400,
    11,
    false
  );

  RAISE NOTICE 'Module 6, Lesson 11 created!';
END $$;
