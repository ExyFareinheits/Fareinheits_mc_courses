import { useParams, Link } from 'react-router-dom'
import { useState, useEffect } from 'react'
import { getCourseBySlug } from '../data/courses'
import { useProgressStore } from '../store/progressStore'
import { useAuthStore } from '../store/authStore'
import { checkCourseAccess } from '../lib/courseAccess'
import { 
  Clock, 
  TrendingUp, 
  CheckCircle, 
  Package, 
  Gift, 
  ExternalLink,
  ArrowLeft,
  BookOpen,
  Play,
  RotateCcw
} from 'lucide-react'

export default function CourseDetail() {
  const { slug } = useParams<{ slug: string }>()
  const course = getCourseBySlug(slug || '')
  const { user } = useAuthStore()
  const { getCourseProgress } = useProgressStore()
  const progress = course ? getCourseProgress(course.id) : undefined
  const [hasPurchased, setHasPurchased] = useState<boolean>(false)

  useEffect(() => {
    const checkPurchase = async () => {
      if (!user || !course) {
        return
      }

      // Для безкоштовних курсів доступ є завжди
      if (course.price === 0) {
        setHasPurchased(true)
        return
      }

      // Перевіряємо покупку для платних курсів
      const hasAccess = await checkCourseAccess(user.id, course.id)
      setHasPurchased(hasAccess)
    }

    checkPurchase()
  }, [user, course])

  if (!course) {
    return (
      <div className="container-custom py-20 text-center">
        <div className="text-minecraft-diamond mb-4"><Package size={80} className="mx-auto" /></div>
        <h1 className="text-4xl font-bold text-white mb-4">
          Курс не знайдено
        </h1>
        <p className="text-gray-400 mb-8">
          На жаль, такого курсу не існує
        </p>
        <Link to="/courses" className="btn-primary">
          Повернутися до курсів
        </Link>
      </div>
    )
  }

  const difficultyColors = {
    beginner: 'bg-green-500',
    intermediate: 'bg-yellow-500',
    advanced: 'bg-red-500',
  }

  const difficultyLabels = {
    beginner: 'Новачок',
    intermediate: 'Середній',
    advanced: 'Просунутий',
  }

  return (
    <div className="min-h-screen">
      {/* Hero */}
      <div className="relative bg-gradient-to-br from-minecraft-grass to-minecraft-emerald py-12 overflow-hidden">
        {/* Background image with overlay */}
        <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1614680376593-902f74cf0d41?w=1200')] bg-cover bg-center opacity-10 pointer-events-none" />
        <div className="absolute inset-0 bg-gradient-to-br from-minecraft-grass/50 to-minecraft-emerald/50 pointer-events-none" />
        
        <div className="container-custom relative z-10">
          <Link 
            to="/courses" 
            className="inline-flex items-center gap-2 text-white/90 hover:text-white mb-6 transition-colors text-sm"
          >
            <ArrowLeft size={18} />
            Назад до курсів
          </Link>

          <div className="flex flex-col lg:flex-row items-start gap-8">
            {/* Left - Course Info */}
            <div className="flex-1 space-y-4">
              <div className="flex items-center gap-3">
                <span className={`${difficultyColors[course.difficulty]} text-white text-xs font-semibold px-3 py-1.5 rounded-full`}>
                  {difficultyLabels[course.difficulty]}
                </span>
                <div className="flex items-center gap-2 text-white/90 text-sm">
                  <Clock size={16} />
                  <span>{course.duration}</span>
                </div>
              </div>

              <h1 className="text-3xl md:text-4xl font-bold text-white leading-tight">
                {course.title}
              </h1>

              <p className="text-base text-white/90">
                {course.description}
              </p>

              <div className="flex flex-wrap gap-2">
                {course.format.map((format, index) => (
                  <span
                    key={index}
                    className="bg-white/20 backdrop-blur-sm text-white px-3 py-1.5 rounded-lg text-xs font-medium"
                  >
                    {format}
                  </span>
                ))}
              </div>
            </div>

            {/* Right - Purchase Card */}
            <div className="lg:w-80 w-full">
              <div className="bg-white rounded-xl shadow-xl p-6 space-y-5 sticky top-24">
                <div className="text-center">
                  <div className="text-minecraft-emerald mb-3 flex justify-center">
                    <BookOpen size={48} strokeWidth={1.5} />
                  </div>
                  {course.price === 0 ? (
                    <>
                      <div className="text-4xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent mb-2">
                        Безкоштовно
                      </div>
                      <p className="text-gray-600 text-sm">Почніть навчання зараз</p>
                    </>
                  ) : (
                    <>
                      <div className="text-4xl font-bold text-minecraft-emerald mb-2">
                        ${course.price}
                      </div>
                      <p className="text-gray-600 text-sm">Одноразовий платіж</p>
                    </>
                  )}
                </div>

                {/* Progress Bar */}
                {progress && progress.completedLessons.length > 0 && (
                  <div className="mb-3">
                    <div className="flex items-center justify-between mb-1.5">
                      <span className="text-xs font-medium text-gray-700">Прогрес</span>
                      <span className="text-xs font-semibold text-minecraft-emerald">{Math.round(progress.progress || 0)}%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-1.5">
                      <div
                        className="bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond h-1.5 rounded-full transition-all"
                        style={{ width: `${progress.progress || 0}%` }}
                      ></div>
                    </div>
                  </div>
                )}

                <div className="space-y-2.5">
                  {/* Start Learning Button або Purchase Button */}
                  {course.price === 0 || hasPurchased ? (
                    <Link
                      to={`/learn/${course.slug}`}
                      className="w-full bg-gradient-to-r from-minecraft-emerald to-green-500 hover:from-minecraft-emerald hover:to-minecraft-emerald text-white font-semibold py-3 px-5 rounded-lg transition-all flex items-center justify-center gap-2"
                    >
                      {progress && progress.completedLessons.length > 0 ? (
                        <>
                          <RotateCcw size={18} />
                          Продовжити навчання
                        </>
                      ) : (
                        <>
                          <Play size={18} />
                          Почати навчання
                        </>
                      )}
                    </Link>
                  ) : (
                    <div className="space-y-2.5">
                      <div className="bg-minecraft-gold/10 border border-minecraft-gold/30 rounded-lg p-3 text-center">
                        <p className="text-minecraft-gold font-semibold text-sm mb-1">Платний курс</p>
                        <p className="text-gray-500 text-xs">Придбайте курс для отримання доступу</p>
                      </div>
                    </div>
                  )}

                  {/* Request Access Link (for paid courses without purchase) */}
                  {course.price > 0 && !hasPurchased && (
                    <Link
                      to={`/request-access?course=${course.id}`}
                      className="w-full btn-secondary flex items-center justify-center gap-2 text-sm"
                    >
                      <ExternalLink size={16} />
                      Запит на доступ
                    </Link>
                  )}
                </div>

                <div className="pt-3 border-t border-gray-200">
                  <div className="space-y-1.5 text-xs text-gray-600">
                    <div className="flex items-center justify-center gap-2">
                      <CheckCircle size={14} className="text-minecraft-emerald" />
                      <span>Безкоштовні оновлення назавжди</span>
                    </div>
                    <div className="flex items-center justify-center gap-2">
                      <CheckCircle size={14} className="text-minecraft-emerald" />
                      <span>Безпечний платіж</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="relative container-custom py-10 space-y-10">
        {/* Background decorations */}
        <div className="absolute top-20 -left-20 w-80 h-80 bg-minecraft-emerald/5 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute bottom-20 -right-20 w-80 h-80 bg-minecraft-diamond/5 rounded-full blur-3xl pointer-events-none" />
        
        {/* What You'll Learn */}
        <section className="relative z-10">
          <div className="flex items-center gap-2 mb-5">
            <CheckCircle className="text-minecraft-emerald" size={24} />
            <h2 className="text-2xl font-bold text-white">
              Що ви навчитесь
            </h2>
          </div>
          <div className="grid md:grid-cols-2 gap-3 max-w-4xl">
            {course.whatYouLearn.map((item, index) => (
              <div
                key={index}
                className="flex items-start gap-2.5 bg-gray-800/50 p-3.5 rounded-lg border border-gray-700/50"
              >
                <CheckCircle className="text-minecraft-emerald flex-shrink-0 mt-0.5" size={16} />
                <span className="text-gray-300 text-sm">{item}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Topics */}
        <section>
          <div className="flex items-center gap-2 mb-5">
            <Package className="text-minecraft-diamond" size={24} />
            <h2 className="text-2xl font-bold text-white">
              Теми курсу
            </h2>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3 max-w-5xl">
            {course.topics.map((topic, index) => (
              <div
                key={index}
                className="bg-gradient-to-br from-minecraft-grass/20 to-minecraft-emerald/20 p-4 rounded-lg border border-minecraft-emerald/30"
              >
                <div className="text-minecraft-emerald font-semibold text-xs mb-1.5">
                  Модуль {index + 1}
                </div>
                <div className="text-white font-medium text-sm">{topic}</div>
              </div>
            ))}
          </div>
        </section>

        {/* Requirements */}
        <section>
          <div className="flex items-center gap-2 mb-5">
            <TrendingUp className="text-minecraft-gold" size={24} />
            <h2 className="text-2xl font-bold text-white">
              Вимоги
            </h2>
          </div>
          <div className="space-y-2.5 max-w-3xl">
            {course.requirements.map((req, index) => (
              <div
                key={index}
                className="flex items-center gap-2.5 bg-gray-800/50 p-3.5 rounded-lg border border-gray-700/50"
              >
                <div className="text-minecraft-gold text-sm">✓</div>
                <span className="text-gray-300 text-sm">{req}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Bonus */}
        {course.bonus && (
          <section>
            <div className="flex items-center gap-2 mb-5">
              <Gift className="text-minecraft-gold" size={24} />
              <h2 className="text-2xl font-bold text-white">
                Бонуси
              </h2>
            </div>
            <div className="bg-gradient-to-br from-minecraft-gold/10 to-minecraft-emerald/10 rounded-lg p-6 border border-minecraft-gold/30 max-w-4xl">
              <div className="grid md:grid-cols-2 gap-3">
                {course.bonus.map((bonus, index) => (
                  <div
                    key={index}
                    className="flex items-center gap-2"
                  >
                    <Gift className="text-minecraft-gold" size={16} />
                    <span className="text-gray-300 text-sm font-medium">{bonus}</span>
                  </div>
                ))}
              </div>
            </div>
          </section>
        )}

        {/* Final CTA */}
        <section className="text-center">
          <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-8 md:p-10 border border-gray-700 space-y-5 max-w-3xl mx-auto">
            <h2 className="text-3xl font-bold text-white">
              <span className="gradient-title">Готові розпочати навчання?</span>
            </h2>
            <p className="text-gray-400 max-w-xl mx-auto">
              Приєднуйтесь зараз і отримайте миттєвий доступ до всіх матеріалів
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
              {course.price === 0 || hasPurchased ? (
                <Link
                  to={`/learn/${course.slug}`}
                  className="bg-white hover:bg-gray-100 text-minecraft-emerald font-semibold py-3 px-6 rounded-lg transition-all flex items-center gap-2"
                >
                  <Play size={18} />
                  {hasPurchased ? 'Почати навчання' : 'Почати безкоштовно'}
                </Link>
              ) : (
                <Link
                  to={`/request-access?course=${course.id}`}
                  className="bg-white hover:bg-gray-100 text-minecraft-emerald font-semibold py-3 px-6 rounded-lg transition-all flex items-center gap-2"
                >
                  <ExternalLink size={18} />
                  Запит на доступ до курсу
                </Link>
              )}
            </div>
          </div>
        </section>
      </div>
    </div>
  )
}
