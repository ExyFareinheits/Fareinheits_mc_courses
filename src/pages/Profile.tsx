import { useEffect, useState } from 'react';
import { useAuthStore } from '../store/authStore';
import { useProgressStore } from '../store/progressStore';
import { Link } from 'react-router-dom';
import { courses } from '../data/courses';
import { 
  User, 
  Award, 
  BookOpen, 
  CheckCircle, 
  TrendingUp, 
  Calendar,
  Trophy,
  Target,
  Zap
} from 'lucide-react';
import PasswordChange from '../components/PasswordChange';

interface Badge {
  id: string;
  name: string;
  description: string;
  icon: JSX.Element;
  color: string;
  earned: boolean;
  earnedDate?: Date;
}

export default function Profile() {
  const { user } = useAuthStore();
  const { progresses } = useProgressStore();
  const [badges, setBadges] = useState<Badge[]>([]);

  useEffect(() => {
    if (user) {
      calculateBadges();
    }
  }, [user, progresses]);

  const calculateBadges = () => {
    const completedCourses = Object.values(progresses).filter(p => p.completed).length;
    const totalLessons = Object.values(progresses).reduce((acc, p) => acc + p.completedLessons.length, 0);
    const avgQuizScore = calculateAverageQuizScore();

    const allBadges: Badge[] = [
      {
        id: 'first-steps',
        name: 'Перші кроки',
        description: 'Завершіть свій перший урок',
        icon: <BookOpen className="w-8 h-8" />,
        color: 'from-blue-400 to-blue-600',
        earned: totalLessons >= 1,
        earnedDate: totalLessons >= 1 ? new Date() : undefined,
      },
      {
        id: 'beginner',
        name: 'Новачок',
        description: 'Завершіть 1 курс',
        icon: <Award className="w-8 h-8" />,
        color: 'from-green-400 to-green-600',
        earned: completedCourses >= 1,
      },
      {
        id: 'intermediate',
        name: 'Практик',
        description: 'Завершіть 3 курси',
        icon: <TrendingUp className="w-8 h-8" />,
        color: 'from-purple-400 to-purple-600',
        earned: completedCourses >= 3,
      },
      {
        id: 'expert',
        name: 'Експерт',
        description: 'Завершіть всі курси',
        icon: <Trophy className="w-8 h-8" />,
        color: 'from-yellow-400 to-orange-600',
        earned: completedCourses >= courses.length,
      },
      {
        id: 'quiz-master',
        name: 'Майстер квізів',
        description: 'Середній бал більше 90%',
        icon: <Target className="w-8 h-8" />,
        color: 'from-pink-400 to-red-600',
        earned: avgQuizScore >= 90,
      },
      {
        id: 'speedrunner',
        name: 'Швидкісний',
        description: 'Завершіть 10 уроків за день',
        icon: <Zap className="w-8 h-8" />,
        color: 'from-cyan-400 to-blue-600',
        earned: totalLessons >= 10,
      },
    ];

    setBadges(allBadges);
  };

  const calculateAverageQuizScore = () => {
    const allScores: number[] = [];
    Object.values(progresses).forEach(progress => {
      Object.values(progress.quizScores).forEach(score => {
        allScores.push(score);
      });
    });
    if (allScores.length === 0) return 0;
    return allScores.reduce((sum, score) => sum + score, 0) / allScores.length;
  };

  const completedCoursesCount = Object.values(progresses).filter(p => p.completed).length;
  const inProgressCount = Object.values(progresses).filter(p => !p.completed && p.completedLessons.length > 0).length;
  const totalLessonsCompleted = Object.values(progresses).reduce((acc, p) => acc + p.completedLessons.length, 0);
  const earnedBadges = badges.filter(b => b.earned);

  if (!user) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-950 via-gray-900 to-minecraft-obsidian flex items-center justify-center">
        <div className="text-center">
          <User className="w-24 h-24 text-gray-600 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-2">Увійдіть для перегляду профілю</h2>
          <p className="text-gray-400">Створіть акаунт або увійдіть, щоб відстежувати свій прогрес</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen relative">
      {/* Background decorations */}
      <div className="absolute top-0 left-0 w-96 h-96 bg-minecraft-emerald/5 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-0 right-0 w-96 h-96 bg-minecraft-gold/5 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHBhdHRlcm4gaWQ9ImdyaWQiIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCIgcGF0dGVyblVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHBhdGggZD0iTSAxMCAwIEwgMCAwIDAgMTAiIGZpbGw9Im5vbmUiIHN0cm9rZT0icmdiYSgyMzIsMjMyLDIzMiwwLjAyKSIgc3Ryb2tlLXdpZHRoPSIxIi8+PC9wYXR0ZXJuPjwvZGVmcz48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSJ1cmwoI2dyaWQpIi8+PC9zdmc+')] opacity-20 pointer-events-none" />
      
      <div className="container-custom py-8 relative z-10">
        {/* Profile Header */}
        <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-6 border border-gray-700/50 mb-6">
          <div className="flex items-start gap-5">
            <div className="w-20 h-20 bg-gradient-to-br from-minecraft-emerald to-minecraft-diamond rounded-xl flex items-center justify-center text-white text-3xl font-bold">
              {user.email?.[0].toUpperCase()}
            </div>
            <div className="flex-1">
              <h1 className="text-2xl font-bold text-white mb-1">
                {user.user_metadata?.full_name || 'Користувач'}
              </h1>
              <p className="text-gray-400 text-sm mb-3">{user.email}</p>
              <div className="flex items-center gap-2 text-sm">
                <div className="flex items-center gap-2 text-minecraft-emerald">
                  <Calendar className="w-4 h-4" />
                  <span>Приєднався {new Date(user.created_at!).toLocaleDateString('uk-UA')}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Statistics */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-gray-800/50 rounded-lg p-4 border border-blue-500/20">
            <div className="flex items-center gap-3">
              <BookOpen className="w-6 h-6 text-blue-400" />
              <div>
                <div className="text-2xl font-bold text-white">{completedCoursesCount}</div>
                <div className="text-xs text-gray-400">Завершено</div>
              </div>
            </div>
          </div>

          <div className="bg-gray-800/50 rounded-lg p-4 border border-purple-500/20">
            <div className="flex items-center gap-3">
              <TrendingUp className="w-6 h-6 text-purple-400" />
              <div>
                <div className="text-2xl font-bold text-white">{inProgressCount}</div>
                <div className="text-xs text-gray-400">В процесі</div>
              </div>
            </div>
          </div>

          <div className="bg-gray-800/50 rounded-lg p-4 border border-green-500/20">
            <div className="flex items-center gap-3">
              <CheckCircle className="w-6 h-6 text-green-400" />
              <div>
                <div className="text-2xl font-bold text-white">{totalLessonsCompleted}</div>
                <div className="text-xs text-gray-400">Уроків</div>
              </div>
            </div>
          </div>

          <div className="bg-gray-800/50 rounded-lg p-4 border border-yellow-500/20">
            <div className="flex items-center gap-3">
              <Trophy className="w-6 h-6 text-yellow-400" />
              <div>
                <div className="text-2xl font-bold text-white">{earnedBadges.length}</div>
                <div className="text-xs text-gray-400">Бейджів</div>
              </div>
            </div>
          </div>
        </div>

        {/* Badges Section */}
        <div className="relative bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-6 border border-gray-700/50 mb-6 overflow-hidden">
          <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDgiIGhlaWdodD0iNDgiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjQ4IiBoZWlnaHQ9IjQ4IiBmaWxsPSJub25lIiBzdHJva2U9InJnYmEoMjMyLDIzMiwyMzIsMC4wMikiIHN0cm9rZS13aWR0aD0iMSIvPjwvc3ZnPg==')] opacity-30 pointer-events-none" />
          <h2 className="text-xl font-bold text-white mb-5 flex items-center gap-2">
            <Award className="w-6 h-6 text-minecraft-gold" />
            Досягнення
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {badges.map(badge => (
              <div
                key={badge.id}
                className={`relative rounded-lg p-4 border transition-all ${
                  badge.earned
                    ? 'bg-gradient-to-br ' + badge.color + ' border-transparent'
                    : 'bg-gray-800/30 border-gray-700/50 grayscale opacity-60'
                }`}
              >
                {badge.earned && (
                  <div className="absolute top-2 right-2">
                    <CheckCircle className="w-5 h-5 text-white" />
                  </div>
                )}
                <div className="flex items-start gap-3">
                  <div className={`${badge.earned ? 'text-white' : 'text-gray-500'}`}>
                    {badge.icon}
                  </div>
                  <div className="flex-1">
                    <h3 className={`text-base font-semibold mb-1 ${badge.earned ? 'text-white' : 'text-gray-500'}`}>
                      {badge.name}
                    </h3>
                    <p className={`text-xs ${badge.earned ? 'text-white/90' : 'text-gray-600'}`}>
                      {badge.description}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Courses Progress */}
        <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-6 border border-gray-700/50">
          <h2 className="text-xl font-bold text-white mb-5 flex items-center gap-2">
            <BookOpen className="w-6 h-6 text-minecraft-diamond" />
            Мої курси
          </h2>
          <div className="space-y-3">
            {courses.map(course => {
              const progress = progresses[course.id];
              const progressPercent = progress
                ? Math.round((progress.completedLessons.length / 10) * 100)
                : 0;

              return (
                <Link
                  key={course.id}
                  to={progress ? `/learn/${course.slug}` : `/courses/${course.slug}`}
                  className="block bg-gray-800/50 rounded-lg p-4 border border-gray-700/50 hover:border-minecraft-emerald/50 transition-all"
                >
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="text-base font-semibold text-white">{course.title}</h3>
                    {progress?.completed && (
                      <div className="flex items-center gap-1.5 text-minecraft-emerald">
                        <CheckCircle className="w-4 h-4" />
                        <span className="text-xs font-medium">Завершено</span>
                      </div>
                    )}
                  </div>
                  {progress && (
                    <div>
                      <div className="flex justify-between text-xs text-gray-400 mb-1.5">
                        <span>Прогрес</span>
                        <span className="font-medium">{progressPercent}%</span>
                      </div>
                      <div className="w-full bg-gray-700 rounded-full h-1.5">
                        <div
                          className="bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond h-1.5 rounded-full transition-all"
                          style={{ width: `${progressPercent}%` }}
                        />
                      </div>
                    </div>
                  )}
                  {!progress && (
                    <p className="text-gray-400 text-xs">Ще не розпочато</p>
                  )}
                </Link>
              );
            })}
          </div>
        </div>

        {/* Зміна пароля */}
        <div className="mt-6">
          <PasswordChange />
        </div>
      </div>
    </div>
  );
}
