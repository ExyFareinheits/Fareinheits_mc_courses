-- =====================================================
-- ACCESS REQUESTS SYSTEM
-- Система запитів на доступ до курсів
-- =====================================================
-- ВАЖЛИВО: Таблиці admins, admin_logs, user_course_access створюються в admin_functions.sql
-- Цей файл залежить від admin_functions.sql - запускайте його ПІСЛЯ admin_functions.sql

-- Створюємо таблицю для логів адміністратора (якщо не існує)
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
DROP FUNCTION IF EXISTS create_access_request(text, text, text);
DROP FUNCTION IF EXISTS get_my_access_requests();
DROP FUNCTION IF EXISTS admin_get_access_requests(text);
DROP FUNCTION IF EXISTS admin_approve_request(uuid, text, timestamptz);
DROP FUNCTION IF EXISTS admin_reject_request(uuid, text);

-- Видаляємо старі policies якщо існують
DROP POLICY IF EXISTS "Users can view own requests" ON course_access_requests;
DROP POLICY IF EXISTS "Users can create requests" ON course_access_requests;
DROP POLICY IF EXISTS "Users can update own pending requests" ON course_access_requests;
DROP POLICY IF EXISTS "Admins can view all requests" ON course_access_requests;
DROP POLICY IF EXISTS "Admins can update requests" ON course_access_requests;
DROP POLICY IF EXISTS "Users can upload payment proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own payment proofs" ON storage.objects;
DROP POLICY IF EXISTS "Admins can view all payment proofs" ON storage.objects;

-- 1. Таблиця для запитів на доступ
CREATE TABLE IF NOT EXISTS course_access_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  course_id text NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  payment_proof_url text, -- URL скріншоту оплати в Supabase Storage
  user_message text, -- Повідомлення від користувача
  admin_response text, -- Відповідь адміністратора
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),
  reviewed_by uuid REFERENCES auth.users(id), -- Хто розглянув запит
  reviewed_at timestamptz
);

-- Індекси для швидкого пошуку
CREATE INDEX IF NOT EXISTS idx_access_requests_user ON course_access_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_access_requests_status ON course_access_requests(status);
CREATE INDEX IF NOT EXISTS idx_access_requests_course ON course_access_requests(course_id);
CREATE INDEX IF NOT EXISTS idx_access_requests_created ON course_access_requests(created_at DESC);

-- 2. RLS Policies для course_access_requests

-- Користувачі можуть бачити тільки свої запити
ALTER TABLE course_access_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own requests"
ON course_access_requests FOR SELECT
USING (auth.uid() = user_id);

-- Користувачі можуть створювати запити
CREATE POLICY "Users can create requests"
ON course_access_requests FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Користувачі можуть оновлювати тільки свої pending запити
CREATE POLICY "Users can update own pending requests"
ON course_access_requests FOR UPDATE
USING (auth.uid() = user_id AND status = 'pending')
WITH CHECK (auth.uid() = user_id AND status = 'pending');

-- Адміни можуть бачити всі запити
CREATE POLICY "Admins can view all requests"
ON course_access_requests FOR SELECT
USING (
  EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
);

-- Адміни можуть оновлювати запити
CREATE POLICY "Admins can update requests"
ON course_access_requests FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
);

-- 3. Функція для створення запиту на доступ
CREATE OR REPLACE FUNCTION create_access_request(
  p_course_id text,
  p_payment_proof_url text DEFAULT NULL,
  p_user_message text DEFAULT NULL
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_request_id uuid;
  v_user_email text;
BEGIN
  -- Перевіряємо чи користувач авторизований
  IF auth.uid() IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
  END IF;

  -- Перевіряємо чи вже є pending запит
  IF EXISTS (
    SELECT 1 FROM course_access_requests
    WHERE user_id = auth.uid()
    AND course_id = p_course_id
    AND status = 'pending'
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'You already have a pending request for this course');
  END IF;

  -- Перевіряємо чи вже є доступ
  IF EXISTS (
    SELECT 1 FROM user_course_access
    WHERE user_id = auth.uid()
    AND course_id = p_course_id
    AND is_active = true
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'You already have access to this course');
  END IF;

  -- Створюємо запит
  INSERT INTO course_access_requests (user_id, course_id, payment_proof_url, user_message)
  VALUES (auth.uid(), p_course_id, p_payment_proof_url, p_user_message)
  RETURNING id INTO v_request_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Access request created successfully',
    'request_id', v_request_id
  );
END;
$$;

-- 4. Функція для отримання всіх запитів (admin)
CREATE OR REPLACE FUNCTION admin_get_access_requests(
  p_status text DEFAULT NULL
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_result jsonb;
BEGIN
  -- Перевірка чи користувач є адміном
  IF NOT EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Access denied: Admin privileges required';
  END IF;

  -- Повертаємо запити у форматі JSON
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', car.id,
      'user_id', car.user_id,
      'user_email', (SELECT email FROM auth.users WHERE id = car.user_id),
      'course_id', car.course_id,
      'status', car.status,
      'payment_proof_url', car.payment_proof_url,
      'user_message', car.user_message,
      'admin_response', car.admin_response,
      'created_at', car.created_at,
      'updated_at', car.updated_at,
      'reviewed_by', car.reviewed_by,
      'reviewed_at', car.reviewed_at
    )
    ORDER BY 
      CASE car.status
        WHEN 'pending' THEN 1
        WHEN 'approved' THEN 2
        WHEN 'rejected' THEN 3
      END,
      car.created_at DESC
  ) INTO v_result
  FROM course_access_requests car
  WHERE p_status IS NULL OR car.status = p_status;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- 5. Функція для схвалення запиту
CREATE OR REPLACE FUNCTION admin_approve_request(
  p_request_id uuid,
  p_admin_response text DEFAULT NULL,
  p_expires_at timestamptz DEFAULT NULL
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_request record;
BEGIN
  -- Перевірка чи користувач є адміном
  IF NOT EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'Access denied');
  END IF;

  -- Отримуємо запит
  SELECT * INTO v_request
  FROM course_access_requests
  WHERE id = p_request_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Request not found');
  END IF;

  IF v_request.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Request already processed');
  END IF;

  -- Оновлюємо статус запиту
  UPDATE course_access_requests
  SET 
    status = 'approved',
    admin_response = p_admin_response,
    reviewed_by = auth.uid(),
    reviewed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_request_id;

  -- Надаємо доступ до курсу
  INSERT INTO user_course_access (user_id, course_id, granted_at, expires_at, is_active)
  VALUES (v_request.user_id, v_request.course_id, NOW(), p_expires_at, true)
  ON CONFLICT (user_id, course_id) 
  DO UPDATE SET 
    is_active = true,
    expires_at = COALESCE(p_expires_at, user_course_access.expires_at);

  -- Логуємо дію
  INSERT INTO admin_logs (user_id, action, target_user_id, details)
  VALUES (
    auth.uid(),
    'approve_access_request',
    v_request.user_id,
    jsonb_build_object(
      'request_id', p_request_id,
      'course_id', v_request.course_id,
      'expires_at', p_expires_at
    )
  );

  RETURN jsonb_build_object('success', true, 'message', 'Request approved and access granted');
END;
$$;

-- 6. Функція для відхилення запиту
CREATE OR REPLACE FUNCTION admin_reject_request(
  p_request_id uuid,
  p_admin_response text
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_request record;
BEGIN
  -- Перевірка чи користувач є адміном
  IF NOT EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'Access denied');
  END IF;

  -- Отримуємо запит
  SELECT * INTO v_request
  FROM course_access_requests
  WHERE id = p_request_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Request not found');
  END IF;

  IF v_request.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Request already processed');
  END IF;

  -- Оновлюємо статус запиту
  UPDATE course_access_requests
  SET 
    status = 'rejected',
    admin_response = p_admin_response,
    reviewed_by = auth.uid(),
    reviewed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_request_id;

  -- Логуємо дію
  INSERT INTO admin_logs (user_id, action, target_user_id, details)
  VALUES (
    auth.uid(),
    'reject_access_request',
    v_request.user_id,
    jsonb_build_object(
      'request_id', p_request_id,
      'course_id', v_request.course_id,
      'reason', p_admin_response
    )
  );

  RETURN jsonb_build_object('success', true, 'message', 'Request rejected');
END;
$$;

-- 7. Функція для отримання своїх запитів (user)
CREATE OR REPLACE FUNCTION get_my_access_requests()
RETURNS TABLE (
  id uuid,
  course_id text,
  status text,
  payment_proof_url text,
  user_message text,
  admin_response text,
  created_at timestamptz,
  updated_at timestamptz,
  reviewed_at timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  RETURN QUERY
  SELECT 
    car.id,
    car.course_id,
    car.status,
    car.payment_proof_url,
    car.user_message,
    car.admin_response,
    car.created_at,
    car.updated_at,
    car.reviewed_at
  FROM course_access_requests car
  WHERE car.user_id = auth.uid()
  ORDER BY car.created_at DESC;
END;
$$;

-- =====================================================
-- STORAGE BUCKET для payment proofs
-- =====================================================

-- Створення bucket для скріншотів оплати
INSERT INTO storage.buckets (id, name, public)
VALUES ('payment-proofs', 'payment-proofs', false)
ON CONFLICT (id) DO NOTHING;

-- RLS для storage bucket
CREATE POLICY "Users can upload payment proofs"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'payment-proofs' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view own payment proofs"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'payment-proofs'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Admins can view all payment proofs"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'payment-proofs'
  AND EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
);

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

GRANT EXECUTE ON FUNCTION create_access_request(text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION get_my_access_requests() TO authenticated;
GRANT EXECUTE ON FUNCTION admin_get_access_requests(text) TO authenticated;
GRANT EXECUTE ON FUNCTION admin_approve_request(uuid, text, timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION admin_reject_request(uuid, text) TO authenticated;

-- Додаткові permissions для auth.users доступу
GRANT USAGE ON SCHEMA auth TO postgres, authenticated;
GRANT SELECT ON auth.users TO postgres, authenticated;

-- =====================================================
-- ІНСТРУКЦІЇ
-- =====================================================

/*
ВИКОРИСТАННЯ:

1. Користувач створює запит:
   SELECT create_access_request(
     'paid-1',
     'https://supabase.co/storage/payment-proofs/user-id/receipt.jpg',
     'Оплатив через Monobank'
   );

2. Користувач перевіряє свої запити:
   SELECT * FROM get_my_access_requests();

3. Адмін отримує всі pending запити:
   SELECT * FROM admin_get_access_requests('pending');

4. Адмін схвалює запит:
   SELECT admin_approve_request(
     'request-uuid',
     'Оплата підтверджена',
     NOW() + INTERVAL '1 year'  -- доступ на 1 рік
   );

5. Адмін відхиляє запит:
   SELECT admin_reject_request(
     'request-uuid',
     'Скріншот нечіткий, надішліть повторно'
   );
*/
