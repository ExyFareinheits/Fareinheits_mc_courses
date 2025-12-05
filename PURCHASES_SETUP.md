# Налаштування системи покупок - ГОТОВО ✅

## Що було зроблено:

✅ **Створено `courseAccess.ts`** - функції для перевірки доступу  
✅ **Оновлено `CourseLearning.tsx`** - перевірка доступу перед завантаженням  
✅ **Оновлено `CourseDetail.tsx`** - відображення статусу покупки  
✅ **Оновлено типи в `supabase.ts`** - додано Purchase інтерфейс  
✅ **Створено SQL файл** - `supabase_purchases_setup.sql`

---

## 1. Створення таблиці purchases у Supabase

**Виконайте SQL з файлу `supabase_purchases_setup.sql`** у Supabase SQL Editor або скопіюйте звідси:

```sql
-- Таблиця покупок курсів
CREATE TABLE IF NOT EXISTS purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id TEXT NOT NULL,
  purchase_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  payment_provider TEXT, -- 'gumroad', 'stripe', 'manual', etc
  transaction_id TEXT,
  amount DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  status TEXT DEFAULT 'completed', -- 'completed', 'refunded', 'pending'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- Індекси для швидкого пошуку
CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_course_id ON purchases(course_id);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON purchases(status);

-- Row Level Security (RLS)
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- Користувачі можуть бачити тільки свої покупки
CREATE POLICY "Користувачі можуть переглядати свої покупки"
  ON purchases FOR SELECT
  USING (auth.uid() = user_id);

-- Адміністратори можуть створювати записи про покупки (manual grants)
CREATE POLICY "Адміністратори можуть додавати покупки"
  ON purchases FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Функція для автоматичного оновлення updated_at
CREATE OR REPLACE FUNCTION update_purchases_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_purchases_updated_at_trigger
  BEFORE UPDATE ON purchases
  FOR EACH ROW
  EXECUTE FUNCTION update_purchases_updated_at();

-- Додати роль в profiles (якщо ще немає)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';
```

## 2. Типи TypeScript

Додайте в `src/lib/supabase.ts`:

```typescript
export interface Purchase {
  id: string;
  user_id: string;
  course_id: string;
  purchase_date: string;
  payment_provider?: string;
  transaction_id?: string;
  amount?: number;
  currency: string;
  status: 'completed' | 'refunded' | 'pending';
  created_at: string;
  updated_at: string;
}

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name?: string;
          avatar_url?: string;
          role?: string;
          created_at: string;
          updated_at: string;
        };
      };
      course_progress: {
        // ... existing
      };
      certificates: {
        // ... existing
      };
      purchases: {
        Row: Purchase;
        Insert: Omit<Purchase, 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Omit<Purchase, 'id' | 'created_at' | 'updated_at'>>;
      };
    };
  };
}
```

## 3. Функція перевірки доступу

Створіть `src/lib/courseAccess.ts`:

```typescript
import { supabase } from './supabase';

export async function checkCourseAccess(userId: string, courseId: string): Promise<boolean> {
  // Безкоштовні курси (free-*)
  if (courseId.startsWith('free-')) {
    return true;
  }

  // Перевірка покупки для платних курсів
  const { data: purchase } = await supabase
    .from('purchases')
    .select('*')
    .eq('user_id', userId)
    .eq('course_id', courseId)
    .eq('status', 'completed')
    .single();

  return !!purchase;
}

export async function getUserPurchases(userId: string) {
  const { data, error } = await supabase
    .from('purchases')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'completed')
    .order('purchase_date', { ascending: false });

  if (error) {
    console.error('Error fetching purchases:', error);
    return [];
  }

  return data || [];
}
```

## 4. Захист в CourseLearning.tsx

```typescript
import { checkCourseAccess } from '../lib/courseAccess';

// В компоненті CourseLearning
useEffect(() => {
  const verifyAccess = async () => {
    if (!user || !course) return;

    const hasAccess = await checkCourseAccess(user.id, course.id);
    
    if (!hasAccess) {
      // Перенаправлення на сторінку курсу для покупки
      navigate(`/courses/${course.slug}`);
      return;
    }

    // Завантаження контенту тільки якщо є доступ
    loadCourseContent();
  };

  verifyAccess();
}, [user, course]);
```

## 5. Ручне надання доступу (для тестування)

SQL запит для надання доступу користувачу:

```sql
-- Замініть на реальні UUID та course_id
INSERT INTO purchases (user_id, course_id, payment_provider, amount, status)
VALUES (
  'USER_UUID_HERE',
  'paid-1',
  'manual',
  7.99,
  'completed'
);
```

Або через Supabase Dashboard:
1. Table Editor → purchases → Insert row
2. Заповніть: user_id, course_id, amount, status='completed'

## 6. Інтеграція з платіжними системами (майбутнє)

### Gumroad Webhook:
```typescript
// pages/api/webhooks/gumroad.ts
export async function POST(req: Request) {
  const data = await req.json();
  
  if (data.sale_id && data.email) {
    // Знайти користувача по email
    const { data: profile } = await supabase
      .from('profiles')
      .select('id')
      .eq('email', data.email)
      .single();
    
    if (profile) {
      await supabase.from('purchases').insert({
        user_id: profile.id,
        course_id: data.product_permalink,
        transaction_id: data.sale_id,
        payment_provider: 'gumroad',
        amount: data.price / 100
      });
    }
  }
  
  return new Response('OK');
}
```

## 7. Відображення статусу покупки

В `CourseDetail.tsx`:

```typescript
const [hasPurchased, setHasPurchased] = useState(false);

useEffect(() => {
  const checkPurchase = async () => {
    if (user && course?.price > 0) {
      const hasAccess = await checkCourseAccess(user.id, course.id);
      setHasPurchased(hasAccess);
    }
  };
  checkPurchase();
}, [user, course]);

// В JSX
{course.price > 0 ? (
  hasPurchased ? (
    <Link to={`/learn/${course.slug}`} className="btn-primary">
      Продовжити навчання
    </Link>
  ) : (
    <a href={course.purchaseLinks.gumroad} className="btn-primary">
      Купити за ${course.price}
    </a>
  )
) : (
  <Link to={`/learn/${course.slug}`} className="btn-primary">
    Почати безкоштовно
  </Link>
)}
```

## Поточний статус

✅ Ціни знижено (від $3.99 до $8.99)
✅ SQL для purchases таблиці готовий
✅ TypeScript типи описані
⏳ Потрібно виконати SQL в Supabase
⏳ Потрібно додати функції перевірки доступу
⏳ Потрібно додати захист в CourseLearning

**Наступні кроки:**
1. Виконати SQL в Supabase Dashboard
2. Додати courseAccess.ts
3. Оновити CourseLearning.tsx з перевіркою
4. Додати відображення статусу покупки
5. Створити контент для платних курсів (разом)
