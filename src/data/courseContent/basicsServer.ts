import { CourseModule } from '../../types/lesson';

// Безкоштовний курс 1: Основи створення Minecraft-сервера
export const basicsServerModules: CourseModule[] = [
  {
    id: 'module-1',
    title: 'Вступ до Minecraft серверів',
    description: 'Базові поняття та підготовка до створення сервера',
    order: 1,
    lessons: [
      {
        id: 'lesson-1-1',
        title: 'Що таке Minecraft-сервер?',
        duration: '10 хв',
        type: 'text',
        content: `
# Що таке Minecraft-сервер?

Minecraft-сервер - це програма, яка дозволяє кільком гравцям грати разом в одному світі через інтернет або локальну мережу.

## Типи серверів

### 1. Ванільний сервер (Vanilla)
- Офіційний сервер від Mojang
- Без модифікацій
- Чиста гра

### 2. Модифіковані сервери
- **Spigot/Paper** - для плагінів
- **Forge** - для модів
- **Fabric** - легкий модлоадер
- **Hybrid** - комбінація плагінів та модів

## Для чого потрібен власний сервер?

✅ Повний контроль над світом
✅ Гра з друзями без обмежень
✅ Можливість встановлювати моди та плагіни
✅ Створення унікального геймплею
✅ Навчання адмініструванню

## Системні вимоги

**Мінімум:**
- CPU: 2 cores
- RAM: 2GB
- HDD: 5GB
- Internet: 10 Mbps upload

**Рекомендовано:**
- CPU: 4+ cores
- RAM: 4-8GB
- SSD: 10GB+
- Internet: 50+ Mbps upload

## Наступні кроки

У наступних уроках ми:
1. Встановимо Java
2. Завантажимо server.jar
3. Запустимо перший сервер
4. Налаштуємо базові параметри
        `,
      },
      {
        id: 'lesson-1-2',
        title: 'Встановлення Java',
        duration: '15 хв',
        type: 'text',
        content: `
# Встановлення Java

Java - це мова програмування та платформа, на якій працює Minecraft. Для запуску сервера потрібна Java Development Kit (JDK) або Java Runtime Environment (JRE).

## Вибір версії Java

| Minecraft версія | Потрібна Java |
|------------------|---------------|
| 1.17 і нижче     | Java 8 або 11 |
| 1.18 - 1.19      | Java 17       |
| 1.20+            | Java 17 або 21|

## Встановлення на Windows

### Варіант 1: OpenJDK (рекомендовано)

1. Відкрийте [Adoptium](https://adoptium.net/)
2. Виберіть версію Java (17 для новіших версій)
3. Завантажте інсталятор для Windows
4. Запустіть установку
5. Важливо: позначте "Add to PATH"

### Варіант 2: Oracle JDK

1. Відкрийте [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
2. Завантажте інсталятор
3. Встановіть з дефолтними налаштуваннями

## Перевірка встановлення

Відкрийте командний рядок (Win + R → cmd) та введіть:

\`\`\`bash
java -version
\`\`\`

Ви маєте побачити щось на кшталт:
\`\`\`
openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment Temurin-17.0.8+7
\`\`\`

## Налаштування змінних середовища (якщо потрібно)

Якщо команда \`java -version\` не працює:

1. Відкрийте "Параметри системи"
2. Перейдіть в "Додаткові параметри системи"
3. Натисніть "Змінні середовища"
4. Знайдіть змінну PATH
5. Додайте шлях до Java (наприклад: \`C:\\Program Files\\Java\\jdk-17\\bin\`)

## Розуміння JVM (Java Virtual Machine)

JVM - це "двигун", який запускає Java програми. Minecraft сервер - це Java програма, тому:

- JVM виконує байт-код Java
- Управляє пам'яттю (RAM)
- Оптимізує виконання коду
- Збирає сміття (Garbage Collection)

### Як це працює?

\`\`\`
[server.jar] → JVM → Виконання → Minecraft сервер працює
\`\`\`

Коли ми запускаємо сервер командою:
\`\`\`bash
java -Xmx2G -Xms2G -jar server.jar
\`\`\`

- \`java\` - запуск JVM
- \`-Xmx2G\` - максимум 2GB RAM
- \`-Xms2G\` - початково 2GB RAM
- \`-jar server.jar\` - запустити файл сервера
        `,
        codeExamples: [
          {
            id: 'code-1',
            title: 'Перевірка Java',
            language: 'bash',
            code: 'java -version\njava --version',
            explanation: 'Обидві команди показують версію встановленої Java'
          }
        ]
      },
      {
        id: 'quiz-1',
        title: 'Тест: Основи Java та серверів',
        duration: '5 хв',
        type: 'quiz',
        content: 'Перевірте свої знання!',
        quiz: {
          id: 'quiz-1',
          questions: [
            {
              id: 'q1',
              question: 'Яка версія Java потрібна для Minecraft 1.20?',
              options: ['Java 8', 'Java 11', 'Java 17', 'Java 21'],
              correctAnswer: 2,
              explanation: 'Для Minecraft 1.18+ потрібна Java 17 або новіша'
            },
            {
              id: 'q2',
              question: 'Що означає параметр -Xmx2G?',
              options: [
                'Мінімум 2GB RAM',
                'Максимум 2GB RAM',
                '2 ядра CPU',
                '2 гравці онлайн'
              ],
              correctAnswer: 1,
              explanation: '-Xmx встановлює максимальний розмір heap пам\'яті для JVM'
            },
            {
              id: 'q3',
              question: 'Що таке JVM?',
              options: [
                'Java Version Manager',
                'Java Virtual Machine',
                'Java Video Mode',
                'Java Variable Method'
              ],
              correctAnswer: 1,
              explanation: 'JVM (Java Virtual Machine) - віртуальна машина, яка виконує Java програми'
            },
            {
              id: 'q4',
              question: 'Скільки RAM рекомендується для невеликого сервера (5-10 гравців)?',
              options: ['1GB', '2GB', '4GB', '8GB'],
              correctAnswer: 2,
              explanation: '4GB RAM достатньо для комфортної гри 5-10 гравців з декількома плагінами'
            }
          ]
        }
      }
    ]
  },
  {
    id: 'module-2',
    title: 'Перший запуск сервера',
    description: 'Завантаження та запуск вашого першого Minecraft сервера',
    order: 2,
    lessons: [
      {
        id: 'lesson-2-1',
        title: 'Завантаження server.jar',
        duration: '10 хв',
        type: 'text',
        content: `
# Завантаження server.jar

Тепер, коли Java встановлено, завантажимо файл сервера.

## Офіційний сервер (Vanilla)

### Крок 1: Створення папки

Створіть окрему папку для сервера:
\`\`\`
C:\\MinecraftServer
\`\`\`

### Крок 2: Завантаження

1. Відкрийте [minecraft.net/download/server](https://www.minecraft.net/en-us/download/server)
2. Завантажте server.jar
3. Помістіть файл в створену папку

## Paper сервер (рекомендовано)

Paper - оптимізована версія з підтримкою плагінів.

1. Відкрийте [papermc.io/downloads](https://papermc.io/downloads)
2. Виберіть версію Minecraft
3. Завантажте найновіший build
4. Перейменуйте на \`server.jar\`

## Структура файлів сервера

Після першого запуску створяться файли:

\`\`\`
MinecraftServer/
├── server.jar          # Головний файл сервера
├── eula.txt           # Ліцензійна угода
├── server.properties  # Налаштування
├── world/             # Головний світ
├── world_nether/      # Незер
├── world_the_end/     # Край
├── plugins/           # Плагіни (Paper/Spigot)
├── logs/              # Логи сервера
└── banned-players.json # Забанені гравці
\`\`\`

## Що відбувається всередині?

Коли ви запускаєте server.jar, Java:

1. **Завантажує JVM**
2. **Ініціалізує Minecraft Core**
   - Завантажує класи та ресурси
   - Ініціалізує реєстри (блоки, предмети, entities)
3. **Створює світ**
   - Генерує чанки
   - Завантажує дані
4. **Запускає мережевий сервер**
   - Відкриває порт (25565)
   - Чекає підключень

### Життєвий цикл сервера

\`\`\`
[Запуск] → [Ініціалізація] → [Завантаження світу] → 
[Головний цикл] → [Зупинка] → [Збереження] → [Вихід]
\`\`\`

**Головний цикл (Game Loop):**
- Виконується 20 разів на секунду (20 TPS)
- Обробляє рух entities
- Оновлює redstone
- Обробляє команди гравців
- Генерує нові чанки
        `,
        codeExamples: [
          {
            id: 'code-2-1',
            title: 'Базовий запуск сервера',
            language: 'bash',
            code: 'java -Xmx1024M -Xms1024M -jar server.jar nogui',
            explanation: 'Запускає сервер з 1GB RAM без графічного інтерфейсу'
          },
          {
            id: 'code-2-2',
            title: 'Оптимізований запуск',
            language: 'bash',
            code: `java -Xmx2G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled \\
-XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions \\
-XX:+DisableExplicitGC -jar server.jar nogui`,
            explanation: 'Запуск з оптимізованими параметрами збирача сміття G1GC'
          }
        ]
      },
      {
        id: 'lesson-2-2',
        title: 'Перший запуск та EULA',
        duration: '15 хв',
        type: 'text',
        content: `
# Перший запуск та прийняття EULA

## Запуск сервера

1. Відкрийте командний рядок в папці сервера
2. Введіть команду:

\`\`\`bash
java -Xmx1G -Xms1G -jar server.jar nogui
\`\`\`

## Що станеться?

Сервер створить файли та зупиниться з повідомленням:

\`\`\`
You need to agree to the EULA in order to run the server.
\`\`\`

## Прийняття EULA

1. Відкрийте файл \`eula.txt\`
2. Знайдіть рядок: \`eula=false\`
3. Змініть на: \`eula=true\`
4. Збережіть файл

## Другий запуск

Запустіть команду знову. Тепер сервер:
- Згенерує світ
- Створить файли конфігурації
- Запуститься повністю

## Консоль сервера

Ви побачите:

\`\`\`
[Server thread/INFO]: Done (5.123s)! For help, type "help"
\`\`\`

Це означає що сервер готовий приймати гравців!

## Базові команди консолі

| Команда | Опис |
|---------|------|
| \`stop\` | Зупинити сервер |
| \`help\` | Список команд |
| \`list\` | Список гравців онлайн |
| \`op <nick>\` | Дати права адміністратора |
| \`say <text>\` | Повідомлення всім гравцям |

## Підключення до сервера

1. Запустіть Minecraft
2. Multiplayer → Add Server
3. Адреса: \`localhost\` (якщо грайте на тому ж ПК)
4. Або IP вашого комп'ютера для друзів

## Розуміння процесу запуску

### Що робить JVM при старті?

\`\`\`java
// Псевдокод того що відбувається
public class MinecraftServer {
    public static void main(String[] args) {
        // 1. Парсинг аргументів
        parseArguments(args);
        
        // 2. Ініціалізація логування
        initializeLogging();
        
        // 3. Завантаження конфігурації
        ServerProperties props = loadProperties();
        
        // 4. Створення світу
        World world = createOrLoadWorld(props.getLevelName());
        
        // 5. Запуск мережевого сервера
        NetworkManager network = new NetworkManager(props.getPort());
        network.start();
        
        // 6. Головний цикл
        while (running) {
            tick(); // Виконується 20 разів на секунду
        }
        
        // 7. Зупинка та збереження
        world.save();
        network.stop();
    }
    
    private void tick() {
        // Оновлення світу
        world.tick();
        
        // Обробка пакетів від гравців
        networkManager.processPackets();
        
        // Оновлення entities
        entityManager.tick();
        
        // Генерація чанків
        chunkGenerator.generatePending();
    }
}
\`\`\`

### TPS (Ticks Per Second)

Сервер працює в циклі 20 TPS:
- 1 tick = 50ms
- 20 ticks = 1 секунда
- Якщо tick довше 50ms → лаг
        `
      }
    ]
  }
];
