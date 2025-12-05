import { supabase, CourseModule, CourseLesson } from './supabase';
import { CourseModule as LocalCourseModule, Lesson } from '../types/lesson';

/**
 * Завантажує модулі курсу з Supabase
 */
export async function loadCourseModules(courseId: string): Promise<LocalCourseModule[]> {
  const { data: modules, error: modulesError } = await supabase
    .from('course_modules')
    .select('*')
    .eq('course_id', courseId)
    .order('order_index', { ascending: true });

  if (modulesError) {
    console.error('Помилка завантаження модулів:', modulesError);
    return [];
  }

  if (!modules || modules.length === 0) {
    return [];
  }

  // Завантажити уроки для кожного модуля
  const { data: lessons, error: lessonsError } = await supabase
    .from('course_lessons')
    .select('*')
    .eq('course_id', courseId)
    .order('order_index', { ascending: true });

  if (lessonsError) {
    console.error('Помилка завантаження уроків:', lessonsError);
    return [];
  }

  // Групувати уроки по модулях
  const result: LocalCourseModule[] = modules.map((module: CourseModule) => {
    const moduleLessons = (lessons || [])
      .filter((lesson: CourseLesson) => lesson.module_id === module.id)
      .map((lesson: CourseLesson) => convertToLocalLesson(lesson));

    return {
      id: module.module_id,
      title: module.title,
      description: module.description || '',
      lessons: moduleLessons,
      order: module.order_index || 0,
    };
  });

  return result;
}

/**
 * Завантажує конкретний урок
 */
export async function loadLesson(courseId: string, lessonId: string): Promise<Lesson | null> {
  const { data, error } = await supabase
    .from('course_lessons')
    .select('*')
    .eq('course_id', courseId)
    .eq('lesson_id', lessonId)
    .single();

  if (error) {
    console.error('Помилка завантаження уроку:', error);
    return null;
  }

  return convertToLocalLesson(data);
}

/**
 * Перевіряє чи є урок безкоштовним preview
 */
export async function isLessonFreePreview(courseId: string, lessonId: string): Promise<boolean> {
  const { data, error } = await supabase
    .from('course_lessons')
    .select('is_free_preview')
    .eq('course_id', courseId)
    .eq('lesson_id', lessonId)
    .single();

  if (error) {
    return false;
  }

  return data?.is_free_preview || false;
}

/**
 * Конвертує Supabase CourseLesson в локальний Lesson тип
 */
function convertToLocalLesson(dbLesson: CourseLesson): Lesson {
  const lesson: Lesson = {
    id: dbLesson.lesson_id,
    title: dbLesson.title,
    duration: dbLesson.duration,
    type: dbLesson.type,
    content: dbLesson.content,
  };

  if (dbLesson.video_url) {
    lesson.videoUrl = dbLesson.video_url;
  }

  if (dbLesson.quiz_data) {
    lesson.quiz = dbLesson.quiz_data;
  }

  return lesson;
}

/**
 * Завантажує тільки метадані уроків (без контенту) для відображення в sidebar
 */
export async function loadCourseLessonsMeta(courseId: string): Promise<LocalCourseModule[]> {
  const { data: modules, error: modulesError } = await supabase
    .from('course_modules')
    .select('*')
    .eq('course_id', courseId)
    .order('order_index', { ascending: true });

  if (modulesError) {
    console.error('Помилка завантаження модулів:', modulesError);
    return [];
  }

  if (!modules || modules.length === 0) {
    console.log(`[loadCourseLessonsMeta] Модулі не знайдені для курсу ${courseId}`);
    return [];
  }

  console.log(`[loadCourseLessonsMeta] Знайдено ${modules.length} модулів для курсу ${courseId}:`, modules);

  // Завантажити тільки метадані уроків (без content)
  const { data: lessons, error: lessonsError } = await supabase
    .from('course_lessons')
    .select('lesson_id, module_id, title, duration, type, order_index, is_free_preview')
    .eq('course_id', courseId)
    .order('order_index', { ascending: true });

  if (lessonsError) {
    console.error('Помилка завантаження уроків:', lessonsError);
    return [];
  }

  console.log(`[loadCourseLessonsMeta] Знайдено ${lessons?.length || 0} уроків для курсу ${courseId}:`, lessons);

  // Групувати уроки по модулях
  const result: LocalCourseModule[] = modules.map((module: CourseModule) => {
    const moduleLessons = (lessons || [])
      .filter((lesson: any) => {
        const match = String(lesson.module_id) === String(module.id);
        console.log(`[Filter] lesson.module_id="${lesson.module_id}" === module.id="${module.id}" => ${match}`);
        return match;
      })
      .map((lesson: any) => ({
        id: lesson.lesson_id,
        title: lesson.title,
        duration: lesson.duration,
        type: lesson.type,
        content: '', // Контент завантажується окремо
      }));

    console.log(`[Module] "${module.title}" має ${moduleLessons.length} уроків`);

    return {
      id: module.module_id,
      title: module.title,
      description: module.description || '',
      lessons: moduleLessons,
      order: module.order_index || 0,
    };
  });

  console.log(`[loadCourseLessonsMeta] Результат:`, result);

  return result;
}

/**
 * Завантажує уроки курсу як плоский список (без групування по модулях)
 * Для відображення "Уроки" замість "Модулі"
 */
export async function loadCourseLessonsFlat(courseId: string): Promise<Lesson[]> {
  const { data: lessons, error: lessonsError } = await supabase
    .from('course_lessons')
    .select('lesson_id, title, duration, type, order_index, is_free_preview')
    .eq('course_id', courseId)
    .order('order_index', { ascending: true });

  if (lessonsError) {
    console.error('Помилка завантаження уроків:', lessonsError);
    return [];
  }

  return (lessons || []).map((lesson: any) => ({
    id: lesson.lesson_id,
    title: lesson.title,
    duration: lesson.duration,
    type: lesson.type,
    content: '', // Контент завантажується окремо
  }));
}
