import { Link } from 'react-router-dom'
import { Course } from '../types/course'
import { Clock, TrendingUp, Package, CheckCircle, Play } from 'lucide-react'
import { useProgressStore } from '../store/progressStore'

interface CourseCardProps {
  course: Course
}

export default function CourseCard({ course }: CourseCardProps) {
  const { getCourseProgress } = useProgressStore()
  const progress = getCourseProgress(course.id)
  const progressPercent = progress?.progress || 0
  const hasStarted = progress && progress.completedLessons.length > 0
  const isCompleted = progress?.completed || false

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

  const isFree = course.price === 0

  return (
    <div className="card group relative overflow-hidden">
      {/* Badges */}
      <div className="absolute top-4 left-4 z-10 flex flex-col gap-2">
        {isFree && (
          <span className="bg-gradient-to-r from-purple-500 to-pink-500 text-white text-xs font-bold px-4 py-2 rounded-full shadow-lg">
            БЕЗКОШТОВНО
          </span>
        )}
        {isCompleted && (
          <span className="bg-gradient-to-r from-minecraft-emerald to-green-500 text-white text-xs font-bold px-4 py-2 rounded-full shadow-lg flex items-center gap-1">
            <CheckCircle size={14} />
            ЗАВЕРШЕНО
          </span>
        )}
        {hasStarted && !isCompleted && (
          <span className="bg-gradient-to-r from-minecraft-diamond to-blue-500 text-white text-xs font-bold px-4 py-2 rounded-full shadow-lg flex items-center gap-1">
            <Play size={14} />
            В ПРОЦЕСІ
          </span>
        )}
      </div>
      
      {/* Thumbnail */}
      <div className={`bg-gradient-to-br ${isFree ? 'from-purple-600 to-pink-600' : 'from-minecraft-grass to-minecraft-emerald'} p-12 flex items-center justify-center relative overflow-hidden`}>
        <div className="absolute inset-0 bg-black/20"></div>
        <div className="text-white transform group-hover:scale-110 transition-all duration-500 relative z-10 group-hover:rotate-6">
          <Package size={72} strokeWidth={1.5} />
        </div>
        <div className="absolute top-4 right-4">
          <span className={`${difficultyColors[course.difficulty]} text-white text-xs font-bold px-3 py-1 rounded-full shadow-lg`}>
            {difficultyLabels[course.difficulty]}
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="p-5 space-y-3">
        <h3 className="text-lg font-bold text-white group-hover:text-minecraft-emerald transition-colors line-clamp-2 leading-snug">
          {course.title}
        </h3>
        
        <p className="text-gray-400 text-sm line-clamp-3 leading-relaxed">
          {course.shortDescription}
        </p>

        {/* Meta Info */}
        <div className="flex items-center gap-3 text-sm">
          <div className="flex items-center gap-1.5 text-gray-300">
            <Clock size={16} className="text-minecraft-diamond flex-shrink-0" />
            <span className="font-medium">{course.duration}</span>
          </div>
          <div className="w-1 h-1 rounded-full bg-gray-600"></div>
          <div className="flex items-center gap-1.5 text-gray-300">
            <TrendingUp size={16} className="text-minecraft-gold flex-shrink-0" />
            <span className="font-medium">{difficultyLabels[course.difficulty]}</span>
          </div>
        </div>

        {/* Topics */}
        <div className="flex flex-wrap gap-1.5">
          {course.topics.slice(0, 3).map((topic, index) => (
            <span
              key={index}
              className="bg-gray-800/80 text-gray-300 text-xs px-2.5 py-1 rounded-md border border-gray-700/50 hover:border-minecraft-emerald/50 transition-colors"
            >
              {topic}
            </span>
          ))}
          {course.topics.length > 3 && (
            <span className="bg-gray-800/50 text-gray-400 text-xs px-2.5 py-1 rounded-md border border-gray-700/30">
              +{course.topics.length - 3}
            </span>
          )}
        </div>

        {/* Progress Bar */}
        {hasStarted && (
          <div className="pt-3 border-t border-gray-700/30">
            <div className="flex justify-between items-center text-xs mb-1.5">
              <span className="text-gray-400 font-medium">Прогрес</span>
              <span className="text-minecraft-emerald font-bold">{Math.round(progressPercent)}%</span>
            </div>
            <div className="w-full bg-gray-800 rounded-full h-1.5 overflow-hidden">
              <div
                className="bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond h-1.5 rounded-full transition-all duration-300"
                style={{ width: `${progressPercent}%` }}
              />
            </div>
          </div>
        )}

        {/* Price & CTA */}
        <div className="flex items-center justify-between pt-3 mt-3 border-t border-gray-700/30">
          <div>
            {isFree ? (
              <span className="text-xl font-bold text-minecraft-emerald">
                Безкоштовно
              </span>
            ) : (
              <div className="flex items-baseline gap-1">
                <span className="text-2xl font-bold text-minecraft-gold">${course.price}</span>
                <span className="text-xs text-gray-400 font-normal">USD</span>
              </div>
            )}
          </div>
          <Link
            to={hasStarted ? `/learn/${course.slug}` : `/courses/${course.slug}`}
            className={`${
              hasStarted 
                ? 'bg-minecraft-emerald hover:bg-green-600' 
                : isFree 
                ? 'bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700' 
                : 'bg-minecraft-diamond hover:bg-blue-600'
            } flex items-center gap-2 text-sm py-2 px-4 rounded-lg text-white font-semibold transition-all shadow-md hover:shadow-lg`}
          >
            {hasStarted ? (
              <>
                <Play size={16} />
                Продовжити
              </>
            ) : (
              <>
                {isFree ? 'Почати безкоштовно' : 'Детальніше'}
              </>
            )}
          </Link>
        </div>
      </div>
    </div>
  )
}
