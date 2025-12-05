-- =====================================================
-- ADMIN RPC FUNCTIONS для адмін-панелі
-- =====================================================
-- Виконайте цей SQL в Supabase SQL Editor
-- ВАЖЛИВО: Запускайте цей файл ПЕРШИМ (перед access_requests_system.sql)

-- КРИТИЧНО: Видаляємо стару таблицю з неправильною структурою
DROP TABLE IF EXISTS admins CASCADE;

-- Створюємо таблицю адмінів з правильною структурою
CREATE TABLE admins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  created_at timestamptz DEFAULT NOW()
);

-- Індекс для швидкого пошуку
CREATE INDEX idx_admins_user_id ON admins(user_id);

-- RLS для admins
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all admins" ON admins;

CREATE POLICY "Admins can view all admins"
ON admins FOR SELECT
USING (true); -- Всі authenticated користувачі можуть переглядати список адмінів

-- Створюємо таблицю для логів адміністратора
CREATE TABLE IF NOT EXISTS admin_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  action text NOT NULL,
  target_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  details jsonb,
  created_at timestamptz DEFAULT NOW()
);

-- Індекси для швидкого пошуку
CREATE INDEX IF NOT EXISTS idx_admin_logs_user ON admin_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action ON admin_logs(action);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created ON admin_logs(created_at DESC);

-- RLS для admin_logs (спрощений - перевірка в функціях)
ALTER TABLE admin_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all logs" ON admin_logs;
DROP POLICY IF EXISTS "Admins can insert logs" ON admin_logs;

CREATE POLICY "Admins can view all logs"
ON admin_logs FOR SELECT
USING (true);

CREATE POLICY "Admins can insert logs"
ON admin_logs FOR INSERT
WITH CHECK (true);

-- Створюємо таблицю user_course_access якщо не існує
CREATE TABLE IF NOT EXISTS user_course_access (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  course_id text NOT NULL,
  granted_at timestamptz DEFAULT NOW(),
  expires_at timestamptz,
  is_active boolean DEFAULT true,
  UNIQUE(user_id, course_id)
);

-- Індекси для user_course_access
CREATE INDEX IF NOT EXISTS idx_user_course_access_user ON user_course_access(user_id);
CREATE INDEX IF NOT EXISTS idx_user_course_access_course ON user_course_access(course_id);
CREATE INDEX IF NOT EXISTS idx_user_course_access_active ON user_course_access(is_active);

-- Видаляємо старі функції якщо існують
DROP FUNCTION IF EXISTS admin_get_all_users();
DROP FUNCTION IF EXISTS admin_bulk_grant_access(uuid[], text, timestamptz);
DROP FUNCTION IF EXISTS grant_course_access(uuid, text, timestamptz);
DROP FUNCTION IF EXISTS revoke_course_access(uuid, text);

-- 1. Функція для отримання всіх користувачів (admin only)
CREATE OR REPLACE FUNCTION admin_get_all_users()
RETURNS TABLE (
  id uuid,
  email text,
  created_at timestamptz,
  last_sign_in_at timestamptz
) 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Перевірка чи користувач є адміном
  IF NOT EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Access denied: Admin privileges required';
  END IF;

  -- Повертаємо користувачів з auth.users (service role доступ)
  RETURN QUERY
  SELECT 
    au.id,
    au.email::text,
    au.created_at,
    au.last_sign_in_at
  FROM auth.users au
  ORDER BY au.created_at DESC;
END;
$$;

-- 2. Функція для bulk grant access
CREATE OR REPLACE FUNCTION admin_bulk_grant_access(
  p_user_ids uuid[],
  p_course_id text,
  p_expires_at timestamptz DEFAULT NULL
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_user_id uuid;
  v_granted_count int := 0;
BEGIN
  -- Перевірка чи користувач є адміном
  IF NOT EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'Access denied');
  END IF;

  -- Надаємо доступ кожному користувачу
  FOREACH v_user_id IN ARRAY p_user_ids
  LOOP
    -- Перевіряємо чи вже є активний доступ
    IF NOT EXISTS (
      SELECT 1 FROM user_course_access 
      WHERE user_id = v_user_id 
      AND course_id = p_course_id 
      AND is_active = true
    ) THEN
      -- Надаємо доступ
      INSERT INTO user_course_access (user_id, course_id, granted_at, expires_at, is_active)
      VALUES (v_user_id, p_course_id, NOW(), p_expires_at, true);
      
      v_granted_count := v_granted_count + 1;
      
      -- Логуємо дію
      INSERT INTO admin_logs (user_id, action, target_user_id, details)
      VALUES (
        auth.uid(),
        'grant_access',
        v_user_id,
        jsonb_build_object('course_id', p_course_id, 'expires_at', p_expires_at)
      );
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true, 
    'granted_count', v_granted_count,
    'message', format('Access granted to %s users', v_granted_count)
  );
END;
$$;

-- 3. Надати доступ одному користувачу
CREATE OR REPLACE FUNCTION grant_course_access(
  p_user_id uuid,
  p_course_id text,
  p_expires_at timestamptz DEFAULT NULL
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Перевірка чи користувач є адміном
  IF NOT EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'Access denied');
  END IF;

  -- Перевіряємо чи вже є активний доступ
  IF EXISTS (
    SELECT 1 FROM user_course_access 
    WHERE user_id = p_user_id 
    AND course_id = p_course_id 
    AND is_active = true
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'User already has active access to this course');
  END IF;

  -- Надаємо доступ
  INSERT INTO user_course_access (user_id, course_id, granted_at, expires_at, is_active)
  VALUES (p_user_id, p_course_id, NOW(), p_expires_at, true);

  -- Логуємо дію
  INSERT INTO admin_logs (user_id, action, target_user_id, details)
  VALUES (
    auth.uid(),
    'grant_access',
    p_user_id,
    jsonb_build_object('course_id', p_course_id, 'expires_at', p_expires_at)
  );

  RETURN jsonb_build_object('success', true, 'message', 'Access granted successfully');
END;
$$;

-- 4. Відкликати доступ
CREATE OR REPLACE FUNCTION revoke_course_access(
  p_user_id uuid,
  p_course_id text
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Перевірка чи користувач є адміном
  IF NOT EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'Access denied');
  END IF;

  -- Деактивуємо доступ
  UPDATE user_course_access
  SET is_active = false
  WHERE user_id = p_user_id 
  AND course_id = p_course_id 
  AND is_active = true;

  -- Логуємо дію
  INSERT INTO admin_logs (user_id, action, target_user_id, details)
  VALUES (
    auth.uid(),
    'revoke_access',
    p_user_id,
    jsonb_build_object('course_id', p_course_id)
  );

  RETURN jsonb_build_object('success', true, 'message', 'Access revoked successfully');
END;
$$;

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

-- Дозволяємо викликати функції authenticated користувачам
GRANT EXECUTE ON FUNCTION admin_get_all_users() TO authenticated;
GRANT EXECUTE ON FUNCTION admin_bulk_grant_access(uuid[], text, timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION grant_course_access(uuid, text, timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION revoke_course_access(uuid, text) TO authenticated;

-- =====================================================
-- ІНСТРУКЦІЇ
-- =====================================================

-- 1. Відкрийте Supabase Dashboard → SQL Editor
-- 2. Створіть New Query
-- 3. Скопіюйте весь цей файл
-- 4. Натисніть RUN
-- 5. Перевірте що всі 4 функції створені без помилок

-- 6. ДОДАЙТЕ СЕБЕ ЯК АДМІНА (виконайте ОКРЕМИМ запитом ПІСЛЯ успішного виконання файлу):
-- INSERT INTO admins (user_id) VALUES ('36dd6f91-a8dc-46c4-b07a-6f909fad4284');

-- Перевірка:
-- SELECT * FROM admins;
-- SELECT * FROM admin_get_all_users();
