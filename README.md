# Fareinheit's MC Courses 🎮

Навчальна платформа для адміністраторів Minecraft серверів українською мовою.

## 🚀 Deployment на Vercel

### Крок 1: Push на GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Крок 2: Підключення до Vercel

1. Зайдіть на [vercel.com](https://vercel.com) та увійдіть через GitHub
2. Натисніть "Add New Project"
3. Виберіть ваш репозиторій
4. Vercel автоматично визначить Vite проект

### Крок 3: Налаштування Environment Variables

В Vercel додайте такі змінні середовища:

```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

⚠️ **ВАЖЛИВО:** Ці дані беріть з вашого Supabase проекту (Settings → API)

### Крок 4: Deploy

Натисніть "Deploy" і чекайте ~2-3 хвилини.

## 📦 Build Settings (автоматично)

Vercel автоматично використає:
- **Build Command:** `npm run build`
- **Output Directory:** `dist`
- **Install Command:** `npm install`

## 🔒 Безпека

✅ **Захищено:**
- Паролі хешуються через bcrypt
- SQL ін'єкції неможливі (Supabase SDK)
- RLS (Row Level Security) активований
- .env файли не потрапляють в Git

✅ **Supabase Keys:**
- `ANON_KEY` - безпечно використовувати на клієнті
- `SERVICE_ROLE_KEY` - **НІКОЛИ** не додавайте в frontend код!

## 🛠️ Локальна розробка

```bash
# Встановлення залежностей
npm install

# Запуск dev сервера
npm run dev

# Build для production
npm run build

# Preview production build
npm run preview
```

## 📁 Структура проекту

```
src/
├── components/        # React компоненти
├── pages/            # Сторінки додатку
├── data/             # Дані курсів (TypeScript constants)
│   ├── courses.ts    # Метадані курсів
│   ├── free-2-course-data.ts
│   ├── free-3-course-data.ts
│   └── free-4-course-data.ts
├── lib/              # Supabase клієнт
└── types/            # TypeScript типи
```

## 🎓 Курси

**Безкоштовні (6 курсів):**
- free-1: Розробка Ідеального Minecraft-Сервера (Supabase)
- free-2: Плагіни - екосистема та основи (TypeScript constants)
- free-3: Безпека сервера (TypeScript constants)
- free-4: Економіка та монетизація (TypeScript constants)
- free-5: Створення міні-ігор (Supabase)
- free-6: Маркетинг та спільнота (Supabase)

**Преміум (4 курси):**
- paid-1 до paid-4 (всі через Supabase)

## 🔄 Автоматичні оновлення

Після push на GitHub:
1. Vercel автоматично запускає новий build
2. Проходить CI/CD pipeline
3. Deploy на production (~2 хвилини)

## 📝 Environment Variables для локальної розробки

Створіть `.env` файл:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

⚠️ Файл `.env` вже в `.gitignore` - він не потрапить в Git!

## 🐛 Known Issues

- Сайт в активній розробці
- Курси регулярно оновлюються
- Можливі тимчасові баги

## 📧 Контакти

- Discord: discord.gg/craftshade
- Email: support@craftshade.net
- Minecraft Server: craftshade.net

---

Made with 💚 for Ukrainian Minecraft community
