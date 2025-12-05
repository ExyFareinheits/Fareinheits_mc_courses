-- =====================================================
-- RLS POLICIES для course_modules та course_lessons
-- Дозволити публічний READ доступ для ВСІХ користувачів
-- =====================================================

-- Увімкнути RLS (якщо ще не увімкнено)
ALTER TABLE IF EXISTS course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS course_lessons ENABLE ROW LEVEL SECURITY;

-- Видалити старі політики (якщо існують)
DROP POLICY IF EXISTS "Public read access to course_modules" ON course_modules;
DROP POLICY IF EXISTS "Public read access to course_lessons" ON course_lessons;
DROP POLICY IF EXISTS "Allow public read course_modules" ON course_modules;
DROP POLICY IF EXISTS "Allow public read course_lessons" ON course_lessons;

-- ============================================
-- ПОЛІТИКА 1: Публічний доступ до course_modules
-- ============================================
CREATE POLICY "Public read access to course_modules"
ON course_modules
FOR SELECT
TO public
USING (true);

-- ============================================
-- ПОЛІТИКА 2: Публічний доступ до course_lessons
-- ============================================
CREATE POLICY "Public read access to course_lessons"
ON course_lessons
FOR SELECT
TO public
USING (true);

-- ============================================
-- ПЕРЕВІРКА: Подивитись створені політики
-- ============================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename IN ('course_modules', 'course_lessons')
ORDER BY tablename, policyname;

-- ============================================
-- ТЕСТ: Спробувати вибрати дані
-- ============================================
SELECT 'course_modules count:' as info, COUNT(*) as count FROM course_modules;
SELECT 'course_lessons count:' as info, COUNT(*) as count FROM course_lessons;

-- Перевірка free-1 курсу
SELECT 
  'free-1 modules:' as info,
  m.id,
  m.course_id,
  m.module_id,
  m.title,
  m.order_index
FROM course_modules m
WHERE m.course_id = 'free-1'
ORDER BY m.order_index;

SELECT 
  'free-1 lessons:' as info,
  l.id,
  l.course_id,
  l.module_id,
  l.lesson_id,
  l.title,
  l.order_index
FROM course_lessons l
WHERE l.course_id = 'free-1'
ORDER BY l.order_index;
