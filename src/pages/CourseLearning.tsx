import { useParams, Link, useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { getCourseBySlug } from '../data/courses';
import { checkCourseAccess } from '../lib/courseAccess';
import { loadCourseLessonsMeta, loadLesson, loadCourseLessonsFlat } from '../lib/paidContent';

import { minigamesCreationModules } from '../data/courseContent/minigamesCreation';
import { hostingPerformanceModules } from '../data/courseContent/hostingPerformance';
import { getFreeCourseContent, hasFreeCourseContent } from '../data/free-courses-content';
import { CourseModule, Lesson } from '../types/lesson';
import { useProgressStore } from '../store/progressStore';
import { useAuthStore } from '../store/authStore';
import {
  ArrowLeft,
  BookOpen,
  CheckCircle,
  Play,
  FileText,
  Award,
  Clock,
  ChevronRight,
  ChevronDown,
  Code,
  HelpCircle
} from 'lucide-react';
import LessonView from '../components/LessonView';
import QuizView from '../components/QuizView';

export default function CourseLearning() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const course = getCourseBySlug(slug || '');
  const [modules, setModules] = useState<CourseModule[]>([]);
  const [flatLessons, setFlatLessons] = useState<Lesson[]>([]); // Плоский список уроків
  const [currentLesson, setCurrentLesson] = useState<Lesson | null>(null);
  const [expandedModules, setExpandedModules] = useState<string[]>([]);
  const [hasAccess, setHasAccess] = useState<boolean>(false);
  const [isCheckingAccess, setIsCheckingAccess] = useState<boolean>(true);
  const [sidebarCollapsed, setSidebarCollapsed] = useState<boolean>(true); // Початково закрито
  
  const { user } = useAuthStore();
  const { getCourseProgress, markLessonComplete } = useProgressStore();
  const progress = course ? getCourseProgress(course.id) : undefined;

  // Перевірка доступу до курсу
  useEffect(() => {
    const verifyAccess = async () => {
      if (!user || !course) {
        setIsCheckingAccess(false);
        return;
      }

      setIsCheckingAccess(true);
      const access = await checkCourseAccess(user.id, course.id);
      setHasAccess(access);
      setIsCheckingAccess(false);

      // Якщо немає доступу до платного курсу - перенаправляємо на сторінку курсу
      if (!access && !course.id.startsWith('free-')) {
        setTimeout(() => {
          navigate(`/courses/${course.slug}`);
        }, 2000);
      }
    };

    verifyAccess();
  }, [user, course, navigate]);

  useEffect(() => {
    const loadContent = async () => {
      // Завантажуємо контент курсу тільки якщо є доступ
      if (!hasAccess && course && !course.id.startsWith('free-')) {
        return;
      }

      let courseModules: CourseModule[] = [];
      
      // Для безкоштовних курсів - локальний контент АБО Supabase
      if (course?.id.startsWith('free-')) {
        // Спочатку перевіряємо чи є локальний контент (для free-2, free-3, free-4)
        if (hasFreeCourseContent(course.id)) {
          const freeContent = getFreeCourseContent(course.id);
          courseModules = freeContent.modules.map(module => ({
            id: module.id.toString(),
            title: module.title,
            description: module.description,
            order: module.id,
            lessons: module.lessons.map((lesson, index) => ({
              id: lesson.id,
              title: lesson.title,
              type: 'text' as const,
              content: lesson.content,
              duration: `${lesson.duration} хвилин`,
              order: index + 1,
              isFree: lesson.isFreePreview,
            }))
          }));
        } else {
          // Інакше завантажуємо з Supabase або локальних файлів
          switch (course.id) {
            case 'free-1':
              courseModules = await loadCourseLessonsMeta(course.id);
              break;
            case 'free-5':
              courseModules = minigamesCreationModules;
              break;
            case 'free-6':
              courseModules = hostingPerformanceModules;
              break;
            default:
              courseModules = [];
          }
        }
      } else if (course?.id.startsWith('paid-')) {
        // Для платних курсів - завантажуємо з Supabase
        if (course.id === 'paid-2') {
          // Для paid-2 завантажуємо плоский список уроків (без модулів)
          const lessons = await loadCourseLessonsFlat(course.id);
          setFlatLessons(lessons);
        } else {
          // Для інших платних курсів - з модулями
          courseModules = await loadCourseLessonsMeta(course.id);
        }
      }
      
      // Встановлюємо модулі якщо вони завантажені
      if (courseModules.length > 0) {
        setModules(courseModules);
        // Розгортаємо лише перший модуль замість усіх
        setExpandedModules(courseModules.length > 0 ? [courseModules[0].id] : []);
      }
    };

    loadContent();
  }, [course, hasAccess]);

  if (!course) {
    return (
      <div className="container-custom py-20 text-center">
        <h1 className="text-4xl font-bold text-white mb-4">Курс не знайдено</h1>
        <Link to="/courses" className="btn-primary">
          Повернутися до курсів
        </Link>
      </div>
    );
  }

  // Показуємо повідомлення про перевірку доступу
  if (isCheckingAccess) {
    return (
      <div className="container-custom py-20 text-center">
        <div className="animate-pulse">
          <BookOpen size={64} className="text-minecraft-emerald mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-2">Перевірка доступу...</h2>
          <p className="text-gray-400">Зачекайте, будь ласка</p>
        </div>
      </div>
    );
  }

  // Показуємо повідомлення про відсутність доступу
  if (!hasAccess && !course.id.startsWith('free-')) {
    return (
      <div className="container-custom py-20 text-center">
        <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-12 border border-gray-700 max-w-2xl mx-auto">
          <div className="text-minecraft-gold mb-6">
            <Award size={64} className="mx-auto" />
          </div>
          <h1 className="text-3xl font-bold text-white mb-4">Потрібна покупка курсу</h1>
          <p className="text-gray-400 mb-6">
            Цей курс платний. Щоб отримати доступ до всіх уроків, будь ласка, придбайте курс.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to={`/courses/${course.slug}`} className="btn-primary">
              Переглянути деталі курсу
            </Link>
            <Link to="/courses" className="btn-secondary">
              Всі курси
            </Link>
          </div>
          <p className="text-gray-500 text-sm mt-6">
            Перенаправлення через 2 секунди...
          </p>
        </div>
      </div>
    );
  }

  const totalLessons = flatLessons.length > 0 
    ? flatLessons.length 
    : modules.reduce((acc, module) => acc + module.lessons.length, 0);
  const completedLessons = progress?.completedLessons.length || 0;
  const progressPercent = totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

  const toggleModule = (moduleId: string) => {
    setExpandedModules(prev =>
      prev.includes(moduleId)
        ? prev.filter(id => id !== moduleId)
        : [...prev, moduleId]
    );
  };

  const selectLesson = async (lesson: Lesson) => {
    // Для платних курсів та free-1 завантажуємо повний контент з Supabase
    if (course?.id.startsWith('paid-') || course?.id === 'free-1') {
      const fullLesson = await loadLesson(course.id, lesson.id);
      if (fullLesson) {
        setCurrentLesson(fullLesson);
        
        // Автоматично розгортаємо модуль з поточним уроком
        const moduleWithLesson = modules.find(m => 
          m.lessons.some(l => l.id === lesson.id)
        );
        if (moduleWithLesson && !expandedModules.includes(moduleWithLesson.id)) {
          setExpandedModules(prev => [...prev, moduleWithLesson.id]);
        }
      }
    } else {
      setCurrentLesson(lesson);
      
      // Автоматично розгортаємо модуль з поточним уроком
      const moduleWithLesson = modules.find(m => 
        m.lessons.some(l => l.id === lesson.id)
      );
      if (moduleWithLesson && !expandedModules.includes(moduleWithLesson.id)) {
        setExpandedModules(prev => [...prev, moduleWithLesson.id]);
      }
    }
  };

  const completeLesson = async () => {
    if (currentLesson && course) {
      await markLessonComplete(course.id, currentLesson.id, user?.id);
      
      // Автоматично перейти до наступного уроку
      const allLessons = flatLessons.length > 0 ? flatLessons : modules.flatMap(m => m.lessons);
      const currentIndex = allLessons.findIndex(l => l.id === currentLesson.id);
      if (currentIndex !== -1 && currentIndex < allLessons.length - 1) {
        const nextLesson = allLessons[currentIndex + 1];
        // Прокручуємо вгору та переходимо до наступного уроку
        window.scrollTo({ top: 0, behavior: 'smooth' });
        setTimeout(() => {
          selectLesson(nextLesson);
        }, 800);
      }
    }
  };

  const isLessonCompleted = (lessonId: string) => {
    return progress?.completedLessons.includes(lessonId) || false;
  };

  const getLessonIcon = (type: string, completed: boolean) => {
    if (completed) return <CheckCircle className="text-minecraft-emerald" size={20} />;
    
    switch (type) {
      case 'video': return <Play className="text-minecraft-diamond" size={20} />;
      case 'text': return <FileText className="text-gray-400" size={20} />;
      case 'quiz': return <HelpCircle className="text-minecraft-gold" size={20} />;
      case 'practice': return <Code className="text-purple-400" size={20} />;
      default: return <BookOpen className="text-gray-400" size={20} />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-950 via-gray-900 to-minecraft-obsidian">
      {/* Header */}
      <div className="bg-minecraft-obsidian/80 backdrop-blur-md border-b border-gray-700/50">
        <div className="container-custom py-6">
          <Link
            to={`/courses/${course.slug}`}
            className="inline-flex items-center gap-2 text-gray-400 hover:text-minecraft-emerald transition-colors mb-4"
          >
            <ArrowLeft size={20} />
            Назад до опису курсу
          </Link>

          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-3xl font-bold text-white mb-2">{course.title}</h1>
              <p className="text-gray-400">{course.shortDescription}</p>
            </div>

            <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-4 border border-gray-700 min-w-[200px]">
              <div className="flex items-center gap-2 mb-2">
                <Award className="text-minecraft-gold" size={20} />
                <span className="text-white font-semibold">Прогрес</span>
              </div>
              <div className="text-3xl font-bold text-minecraft-emerald mb-2">
                {Math.round(progressPercent)}%
              </div>
              <div className="w-full bg-gray-700 rounded-full h-2">
                <div
                  className="bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond h-2 rounded-full transition-all duration-500"
                  style={{ width: `${progressPercent}%` }}
                ></div>
              </div>
              <div className="text-gray-400 text-sm mt-2">
                {completedLessons} / {totalLessons} уроків
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="py-8">
        {/* Floating Quick Navigation - Mobile Only */}
        {(flatLessons.length > 5 || modules.length > 2) && (
          <div className="mb-6 lg:hidden container-custom">
            <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-4 border border-gray-700">
              <label className="text-sm text-gray-400 mb-2 block">Швидкий перехід:</label>
              <select
                className="w-full bg-gray-900 text-white border border-gray-700 rounded-lg px-4 py-2 focus:outline-none focus:border-minecraft-emerald"
                value={currentLesson?.id || ''}
                onChange={(e) => {
                  const lesson = flatLessons.find(l => l.id === e.target.value) || 
                                modules.flatMap(m => m.lessons).find(l => l.id === e.target.value);
                  if (lesson) selectLesson(lesson);
                }}
              >
                {flatLessons.length > 0 ? (
                  flatLessons.map((lesson, idx) => (
                    <option key={lesson.id} value={lesson.id}>
                      Урок {idx + 1}: {lesson.title}
                    </option>
                  ))
                ) : (
                  modules.map((module) =>
                    module.lessons.map((lesson) => (
                      <option key={lesson.id} value={lesson.id}>
                        {module.title} - {lesson.title}
                      </option>
                    ))
                  )
                )}
              </select>
            </div>
          </div>
        )}

        {/* Desktop: Sidebar Fixed Left + Content Centered */}
        <div className="relative">
          {/* Backdrop Overlay */}
          {!sidebarCollapsed && (
            <div 
              className="hidden lg:block fixed inset-0 bg-black/60 backdrop-blur-sm z-10 transition-opacity duration-300"
              onClick={() => setSidebarCollapsed(true)}
            />
          )}

          {/* Sidebar - Fixed on Desktop */}
          <div className={`hidden lg:block fixed left-1/2 -translate-x-1/2 top-24 z-20 transition-all duration-300 ${
            sidebarCollapsed ? 'opacity-0 pointer-events-none scale-95' : 'opacity-100 scale-100'
          }`}>
            <div className="w-[360px] max-h-[calc(100vh-8rem)] bg-gradient-to-br from-gray-800 to-gray-900 border border-gray-700 rounded-xl shadow-2xl overflow-hidden">
              <div className="h-full overflow-y-auto p-4 custom-scrollbar">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-lg font-bold text-white flex items-center gap-2">
                    <BookOpen size={20} className="text-minecraft-emerald" />
                    {flatLessons.length > 0 ? 'Уроки' : 'Зміст'}
                  </h2>
                    {modules.length > 1 && flatLessons.length === 0 && (
                      <button
                        onClick={() => {
                          if (expandedModules.length === modules.length) {
                            setExpandedModules([]);
                          } else {
                            setExpandedModules(modules.map(m => m.id));
                          }
                        }}
                        className="text-xs text-gray-400 hover:text-minecraft-emerald transition-colors px-2 py-1 rounded border border-gray-700 hover:border-minecraft-emerald"
                      >
                        {expandedModules.length === modules.length ? 'Згорнути' : 'Розгорнути'}
                      </button>
                    )}
                  </div>

                  <div className="space-y-1.5">
                {flatLessons.length > 0 ? (
                  // Плоский список уроків (без модулів)
                  flatLessons.map((lesson, idx) => {
                    const completed = isLessonCompleted(lesson.id);
                    const isActive = currentLesson?.id === lesson.id;

                    return (
                      <button
                        key={lesson.id}
                        onClick={() => selectLesson(lesson)}
                        className={`w-full p-3 flex items-center gap-3 hover:bg-gray-800/50 transition-all rounded-lg group ${
                          isActive
                            ? 'bg-minecraft-emerald/10 border border-minecraft-emerald/30'
                            : completed
                            ? 'bg-gray-800/30'
                            : 'bg-transparent'
                        }`}
                      >
                        {/* Lesson Number Circle */}
                        <div className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs transition-all ${
                          isActive 
                            ? 'bg-minecraft-emerald text-white' 
                            : completed 
                            ? 'bg-minecraft-emerald/30 text-minecraft-emerald'
                            : 'bg-gray-700 text-gray-400 group-hover:bg-gray-600'
                        }`}>
                          {completed ? <CheckCircle size={16} /> : idx + 1}
                        </div>
                        
                        <div className="flex-1 text-left min-w-0">
                          <div className={`text-sm font-medium ${
                            isActive 
                              ? 'text-minecraft-emerald' 
                              : completed 
                              ? 'text-gray-200' 
                              : 'text-gray-300'
                          } truncate`}>
                            {lesson.title}
                          </div>
                          <div className="flex items-center gap-2 mt-1">
                            <div className="text-[11px] text-gray-500 flex items-center gap-1">
                              <Clock size={11} />
                              {lesson.duration}
                            </div>
                            {lesson.type === 'video' && (
                              <span className="text-[10px] bg-red-500/20 text-red-400 px-1.5 py-0.5 rounded">VIDEO</span>
                            )}
                            {lesson.type === 'quiz' && (
                              <span className="text-[10px] bg-minecraft-gold/20 text-minecraft-gold px-1.5 py-0.5 rounded">QUIZ</span>
                            )}
                          </div>
                        </div>
                      </button>
                    );
                  })
                ) : (
                  // Список з модулями (старий варіант)
                  modules.map((module) => {
                    const moduleCompletedCount = module.lessons.filter(l => isLessonCompleted(l.id)).length;
                    const moduleProgress = (moduleCompletedCount / module.lessons.length) * 100;
                    
                    return (
                  <div key={module.id} className="border border-gray-700 rounded-lg overflow-hidden mb-2">
                    <button
                      onClick={() => toggleModule(module.id)}
                      className="w-full p-3 flex items-center justify-between bg-gray-800/50 hover:bg-gray-800 transition-colors"
                    >
                      <div className="flex items-center gap-3 text-left flex-1">
                        <div className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${
                          moduleCompletedCount === module.lessons.length 
                            ? 'bg-minecraft-emerald/30' 
                            : 'bg-minecraft-emerald/10'
                        }`}>
                          {moduleCompletedCount === module.lessons.length ? (
                            <CheckCircle size={16} className="text-minecraft-emerald" />
                          ) : (
                            <BookOpen size={16} className="text-minecraft-emerald" />
                          )}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="text-white font-semibold text-sm truncate">
                            {module.title}
                          </div>
                          <div className="flex items-center gap-2 mt-1">
                            <div className="text-gray-400 text-xs">
                              {moduleCompletedCount}/{module.lessons.length} уроків
                            </div>
                            <div className="flex-1 bg-gray-700 rounded-full h-1.5 max-w-[80px]">
                              <div
                                className="bg-minecraft-emerald h-1.5 rounded-full transition-all"
                                style={{ width: `${moduleProgress}%` }}
                              />
                            </div>
                          </div>
                        </div>
                      </div>
                      {expandedModules.includes(module.id) ? (
                        <ChevronDown size={16} className="text-gray-400" />
                      ) : (
                        <ChevronRight size={16} className="text-gray-400" />
                      )}
                    </button>

                    {expandedModules.includes(module.id) && (
                      <div className="bg-gray-900/50 p-2 space-y-1">
                        {module.lessons.map((lesson, idx) => {
                          const completed = isLessonCompleted(lesson.id);
                          const isActive = currentLesson?.id === lesson.id;

                          return (
                            <button
                              key={lesson.id}
                              onClick={() => selectLesson(lesson)}
                              className={`w-full p-2.5 flex items-center gap-2.5 hover:bg-gray-800/50 transition-all rounded-lg group ${
                                isActive
                                  ? 'bg-minecraft-emerald/10 border border-minecraft-emerald/30'
                                  : completed
                                  ? 'bg-gray-800/30'
                                  : 'bg-transparent'
                              }`}
                            >
                              {/* Lesson Number */}
                              <div className={`flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center font-bold text-[10px] ${
                                isActive 
                                  ? 'bg-minecraft-emerald text-white' 
                                  : completed 
                                  ? 'bg-minecraft-emerald/30 text-minecraft-emerald'
                                  : 'bg-gray-700 text-gray-400 group-hover:bg-gray-600'
                              }`}>
                                {completed ? <CheckCircle size={12} /> : idx + 1}
                              </div>
                              
                              <div className="flex-1 text-left min-w-0">
                                <div className={`text-xs font-medium ${isActive ? 'text-minecraft-emerald' : completed ? 'text-gray-200' : 'text-gray-300'} truncate`}>
                                  {lesson.title}
                                </div>
                                <div className="text-[10px] text-gray-500 flex items-center gap-1 mt-0.5">
                                  <Clock size={10} />
                                  {lesson.duration}
                                </div>
                              </div>
                            </button>
                          );
                        })}
                      </div>
                    )}
                  </div>
                );
              })
            )}
              </div>
            </div>
          </div>
          </div>

          {/* Toggle Button - Top Left Corner */}
          <button
            onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
            className="hidden lg:flex fixed top-28 left-6 z-30 w-10 h-10 items-center justify-center bg-gradient-to-br from-gray-800 to-gray-900 border border-gray-700 hover:border-minecraft-emerald hover:bg-minecraft-emerald/10 transition-all duration-300 group shadow-lg rounded-xl"
            title={sidebarCollapsed ? 'Відкрити меню' : 'Закрити меню'}
          >
            <div className="relative">
              {sidebarCollapsed ? (
                <BookOpen size={20} className="text-minecraft-emerald group-hover:scale-110 transition-transform" />
              ) : (
                <ChevronDown size={20} className="text-minecraft-emerald group-hover:scale-110 transition-transform" />
              )}
            </div>
          </button>

          {/* Mobile Sidebar */}
          <div className="lg:hidden container-custom mb-6">
            <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-4 border border-gray-700">
              <div className="flex items-center justify-between mb-3">
                <h2 className="text-lg font-bold text-white flex items-center gap-2">
                  <BookOpen size={20} className="text-minecraft-emerald" />
                  {flatLessons.length > 0 ? 'Уроки' : 'Зміст'}
                </h2>
              </div>
              <div className="space-y-1.5 max-h-[400px] overflow-y-auto custom-scrollbar">
                {flatLessons.length > 0 ? (
                  flatLessons.map((lesson, idx) => {
                    const completed = isLessonCompleted(lesson.id);
                    const isActive = currentLesson?.id === lesson.id;
                    return (
                      <button
                        key={lesson.id}
                        onClick={() => selectLesson(lesson)}
                        className={`w-full p-2.5 flex items-center gap-2 hover:bg-gray-800/50 transition-colors border-l-2 rounded-r ${
                          isActive ? 'border-minecraft-emerald bg-gray-800/50' : completed ? 'border-minecraft-emerald/30' : 'border-transparent'
                        }`}
                      >
                        <div className="flex-shrink-0">{getLessonIcon(lesson.type, completed)}</div>
                        <div className="flex-1 text-left min-w-0">
                          <div className={`text-xs ${isActive ? 'text-minecraft-emerald font-semibold' : completed ? 'text-gray-300' : 'text-gray-400'} truncate`}>
                            {idx + 1}. {lesson.title}
                          </div>
                        </div>
                      </button>
                    );
                  })
                ) : (
                  modules.map((module) => (
                    <div key={module.id} className="border border-gray-700 rounded-lg overflow-hidden">
                      <button onClick={() => toggleModule(module.id)} className="w-full p-2.5 flex items-center justify-between bg-gray-800/50 hover:bg-gray-800 transition-colors">
                        <div className="flex items-center gap-2 text-left flex-1">
                          <BookOpen size={16} className="text-minecraft-emerald" />
                          <span className="text-white font-semibold text-xs truncate">{module.title}</span>
                        </div>
                        {expandedModules.includes(module.id) ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
                      </button>
                      {expandedModules.includes(module.id) && (
                        <div className="bg-gray-900/50">
                          {module.lessons.map((lesson, idx) => {
                            const completed = isLessonCompleted(lesson.id);
                            const isActive = currentLesson?.id === lesson.id;
                            return (
                              <button key={lesson.id} onClick={() => selectLesson(lesson)} className={`w-full p-2 flex items-center gap-2 hover:bg-gray-800/50 transition-colors border-l-2 ${isActive ? 'border-minecraft-emerald bg-gray-800/50' : completed ? 'border-minecraft-emerald/30' : 'border-transparent'}`}>
                                <div className="flex-shrink-0">{getLessonIcon(lesson.type, completed)}</div>
                                <div className="flex-1 text-left min-w-0">
                                  <div className={`text-xs ${isActive ? 'text-minecraft-emerald font-semibold' : completed ? 'text-gray-300' : 'text-gray-400'} truncate`}>
                                    {idx + 1}. {lesson.title}
                                  </div>
                                </div>
                              </button>
                            );
                          })}
                        </div>
                      )}
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>

          {/* Main Content Area - Centered */}
          <div className="w-full">
            <div className="max-w-[900px] mx-auto px-4 sm:px-6 lg:px-8">
              {currentLesson ? (
                currentLesson.type === 'quiz' && currentLesson.quiz ? (
                  <QuizView
                    lesson={currentLesson}
                    quiz={currentLesson.quiz}
                    courseId={course.id}
                    onComplete={completeLesson}
                  />
                ) : (
                  <LessonView
                    lesson={currentLesson}
                    onComplete={completeLesson}
                    isCompleted={isLessonCompleted(currentLesson.id)}
                  />
                )
              ) : (
                <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-12 border border-gray-700 text-center">
                  <BookOpen size={64} className="text-minecraft-emerald mx-auto mb-4" />
                  <h3 className="text-2xl font-bold text-white mb-2">
                    Оберіть урок зі списку
                  </h3>
                  <p className="text-gray-400">
                    Почніть навчання з першого уроку або продовжіть там, де зупинились
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
