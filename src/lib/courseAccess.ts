import { supabase } from './supabase';

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

/**
 * Перевіряє чи має користувач доступ до курсу
 * @param userId - ID користувача
 * @param courseId - ID курсу (наприклад, 'free-1', 'paid-1')
 * @returns true якщо є доступ, false якщо немає
 */
export async function checkCourseAccess(userId: string, courseId: string): Promise<boolean> {
  console.log('🔍 Перевірка доступу:', { userId, courseId });

  // Безкоштовні курси доступні всім
  if (courseId.startsWith('free-')) {
    console.log('✅ Безкоштовний курс - доступ надано');
    return true;
  }

  // Перевірити чи користувач адмін
  const { data: adminData, error: adminError } = await supabase
    .from('admins')
    .select('*')
    .eq('user_id', userId)
    .single();

  console.log('👑 Перевірка адміна:', { adminData, adminError });

  if (adminData) {
    console.log('✅ Користувач є адміном - доступ надано');
    return true; // Адміни мають доступ до всіх курсів
  }

  // Перевірити доступ через user_course_access (надано адміном)
  const { data: accessData, error: accessError } = await supabase
    .from('user_course_access')
    .select('*')
    .eq('user_id', userId)
    .eq('course_id', courseId)
    .eq('is_active', true)
    .single();

  console.log('🎫 Перевірка user_course_access:', { accessData, accessError });

  if (accessData) {
    // Перевірити чи не закінчився термін дії
    if (!accessData.expires_at || new Date(accessData.expires_at) > new Date()) {
      console.log('✅ Доступ надано через user_course_access');
      return true;
    } else {
      console.log('❌ Доступ закінчився:', accessData.expires_at);
    }
  }

  // Для платних курсів перевіряємо наявність покупки через Gumroad
  try {
    const { data: purchase, error: purchaseError } = await supabase
      .from('purchases')
      .select('*')
      .eq('user_id', userId)
      .eq('course_id', courseId)
      .eq('status', 'completed')
      .single();

    console.log('💳 Перевірка purchases:', { purchase, purchaseError });

    if (purchase) {
      console.log('✅ Доступ через покупку');
      return true;
    }
  } catch (err) {
    console.warn('⚠️ Таблиця purchases не існує або помилка запиту, але це нормально');
  }

  console.log('❌ Немає доступу до курсу');
  return false;
}

/**
 * Отримує всі покупки користувача
 * @param userId - ID користувача
 * @returns Масив покупок
 */
export async function getUserPurchases(userId: string): Promise<Purchase[]> {
  const { data, error } = await supabase
    .from('purchases')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'completed')
    .order('purchase_date', { ascending: false });

  if (error) {
    console.error('Помилка завантаження покупок:', error);
    return [];
  }

  return data || [];
}

/**
 * Перевіряє чи купив користувач конкретний курс
 * @param userId - ID користувача
 * @param courseId - ID курсу
 * @returns Purchase або null
 */
export async function getUserPurchase(userId: string, courseId: string): Promise<Purchase | null> {
  const { data, error } = await supabase
    .from('purchases')
    .select('*')
    .eq('user_id', userId)
    .eq('course_id', courseId)
    .eq('status', 'completed')
    .single();

  if (error) {
    return null;
  }

  return data;
}

/**
 * Отримує список ID курсів, які купив користувач
 * @param userId - ID користувача
 * @returns Масив ID курсів
 */
export async function getUserPurchasedCourseIds(userId: string): Promise<string[]> {
  const purchases = await getUserPurchases(userId);
  return purchases.map(p => p.course_id);
}
