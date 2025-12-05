import { courses } from '../data/courses'
import CourseCard from '../components/CourseCard'
import { Filter, Search, BookOpen, Gift, Award, AlertCircle } from 'lucide-react'
import { useState } from 'react'

export default function Courses() {
  const [filter, setFilter] = useState<'all' | 'free' | 'paid'>('all')
  const [difficulty, setDifficulty] = useState<'all' | 'beginner' | 'intermediate' | 'advanced'>('all')

  let filteredCourses = courses

  if (filter === 'free') {
    filteredCourses = filteredCourses.filter(course => course.price === 0)
  } else if (filter === 'paid') {
    filteredCourses = filteredCourses.filter(course => course.price > 0)
  }

  if (difficulty !== 'all') {
    filteredCourses = filteredCourses.filter(course => course.difficulty === difficulty)
  }

  const freeCourses = courses.filter(c => c.price === 0)
  const paidCourses = courses.filter(c => c.price > 0)

  return (
    <div className="relative container-custom py-8 space-y-10">
      {/* Background decorations */}
      <div className="absolute -top-20 left-1/4 w-96 h-96 bg-minecraft-emerald/5 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute top-1/2 -right-20 w-72 h-72 bg-minecraft-diamond/5 rounded-full blur-3xl pointer-events-none" />
      
      {/* Development Warning */}
      <div className="bg-gradient-to-r from-blue-900/30 to-purple-900/30 border-2 border-blue-700/50 rounded-xl p-4 relative z-10">
        <div className="flex items-start gap-3">
          <div className="text-blue-400 mt-1">
            <AlertCircle size={20} />
          </div>
          <p className="text-blue-100/90 text-sm">
            📚 Курси постійно оновлюються! Додаються нові уроки, покращуються існуючі матеріали та виправляються помилки.
          </p>
        </div>
      </div>

      {/* Header */}
      <div className="text-center space-y-4 relative z-10">
        <h1 className="text-4xl md:text-5xl font-bold">
          <span className="gradient-title">Всі Курси</span>
        </h1>
        <p className="text-gray-400 max-w-2xl mx-auto">
          {courses.length} професійних курсів для створення ідеального Minecraft-сервера
        </p>
        
        {/* Stats */}
        <div className="flex items-center justify-center gap-6 pt-4">
          <div className="flex items-center gap-2 text-minecraft-emerald">
            <Gift size={20} />
            <span className="font-semibold">{freeCourses.length} безкоштовних</span>
          </div>
          <div className="w-px h-6 bg-gray-700" />
          <div className="flex items-center gap-2 text-minecraft-gold">
            <Award size={20} />
            <span className="font-semibold">{paidCourses.length} преміум</span>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="space-y-4">
        {/* Type Filter */}
        <div className="flex flex-wrap items-center justify-center gap-3">
          <div className="flex items-center gap-2 text-gray-400">
            <Filter size={18} />
            <span className="font-medium">Тип:</span>
          </div>
          
          {[
            { value: 'all', label: 'Всі курси' },
            { value: 'free', label: 'Безкоштовні' },
            { value: 'paid', label: 'Преміум' },
          ].map((option) => (
            <button
              key={option.value}
              onClick={() => setFilter(option.value as any)}
              className={`px-5 py-2 rounded-lg font-medium transition-all ${
                filter === option.value
                  ? 'bg-minecraft-emerald text-white'
                  : 'bg-gray-800/50 text-gray-400 hover:text-white border border-gray-700/50 hover:border-gray-600'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>

        {/* Difficulty Filter */}
        <div className="flex flex-wrap items-center justify-center gap-3">
          <div className="flex items-center gap-2 text-gray-400">
            <BookOpen size={18} />
            <span className="font-medium">Рівень:</span>
          </div>
          
          {[
            { value: 'all', label: 'Всі рівні' },
            { value: 'beginner', label: 'Новачок' },
            { value: 'intermediate', label: 'Середній' },
            { value: 'advanced', label: 'Просунутий' },
          ].map((option) => (
            <button
              key={option.value}
              onClick={() => setDifficulty(option.value as any)}
              className={`px-5 py-2 rounded-lg font-medium transition-all ${
                difficulty === option.value
                  ? 'bg-minecraft-diamond text-white'
                  : 'bg-gray-800/50 text-gray-400 hover:text-white border border-gray-700/50 hover:border-gray-600'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      {/* Courses Grid */}
      <div className="relative grid md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHBhdHRlcm4gaWQ9ImdyaWQiIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCIgcGF0dGVyblVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHBhdGggZD0iTSAxMCAwIEwgMCAwIDAgMTAiIGZpbGw9Im5vbmUiIHN0cm9rZT0icmdiYSgyMzIsMjMyLDIzMiwwLjAyKSIgc3Ryb2tlLXdpZHRoPSIxIi8+PC9wYXR0ZXJuPjwvZGVmcz48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSJ1cmwoI2dyaWQpIi8+PC9zdmc+')] opacity-40 pointer-events-none -z-10" />
        {filteredCourses.map((course) => (
          <CourseCard key={course.id} course={course} />
        ))}
      </div>

      {/* Results Count */}
      {filteredCourses.length > 0 && (
        <div className="text-center text-gray-400">
          Знайдено курсів: <span className="text-white font-semibold">{filteredCourses.length}</span>
        </div>
      )}

      {/* No results */}
      {filteredCourses.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-600 mb-4"><Search size={48} className="mx-auto" /></div>
          <h3 className="text-xl font-bold text-white mb-2">
            Курси не знайдено
          </h3>
          <p className="text-gray-400">
            Спробуйте змінити фільтри
          </p>
        </div>
      )}
    </div>
  )
}
