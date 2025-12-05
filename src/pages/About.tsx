import { Server, Code, Users, Zap, AlertCircle } from 'lucide-react';

export default function About() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <div className="relative bg-gradient-to-br from-minecraft-grass to-minecraft-emerald py-20 overflow-hidden">
        <div className="absolute inset-0 opacity-10">
          <div className="absolute inset-0" style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
          }} />
        </div>
        <div className="container-custom relative z-10">
          <div className="text-center max-w-3xl mx-auto">
            <h1 className="text-5xl md:text-6xl font-bold text-white mb-6">
              Про нас
            </h1>
            <p className="text-xl text-white/90">
              Навчальна платформа для адміністраторів Minecraft серверів
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container-custom py-20">
        <div className="max-w-4xl mx-auto space-y-12">
          
          {/* About Platform */}
          <section className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-8 border border-gray-700">
            <div className="flex items-start gap-4 mb-6">
              <div className="p-3 bg-minecraft-emerald/20 rounded-lg">
                <Code size={32} className="text-minecraft-emerald" />
              </div>
              <div>
                <h2 className="text-3xl font-bold text-white mb-2">
                  Fareinheit's MC Courses
                </h2>
                <p className="text-gray-400">
                  Навчальна платформа українською мовою
                </p>
              </div>
            </div>
            <div className="space-y-4 text-gray-300">
              <p>
                <strong className="text-white">Fareinheit's MC Courses</strong> — це освітній проект, створений для тих, хто хоче навчитися адмініструвати Minecraft сервери на професійному рівні.
              </p>
              <p>
                Ми пропонуємо структуровані курси українською мовою, які покривають весь спектр знань — від базового встановлення сервера до просунутих тем як оптимізація, безпека, монетизація та створення міні-ігор.
              </p>
              <p>
                Наша мета — зробити якісну освіту доступною для українських адміністраторів та допомогти створити успішні Minecraft проекти.
              </p>
            </div>
          </section>

          {/* About Craftshade */}
          <section className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-8 border border-gray-700">
            <div className="flex items-start gap-4 mb-6">
              <div className="p-3 bg-minecraft-diamond/20 rounded-lg">
                <Server size={32} className="text-minecraft-diamond" />
              </div>
              <div>
                <h2 className="text-3xl font-bold text-white mb-2">
                  Minecraft сервер Craftshade
                </h2>
                <p className="text-gray-400">
                  Наш флагманський проект
                </p>
              </div>
            </div>
            <div className="space-y-4 text-gray-300">
              <p>
                <strong className="text-white">Craftshade</strong> — це український Minecraft сервер, на якому ми застосовуємо всі знання з наших курсів на практиці.
              </p>
              <p>
                Сервер служить живою лабораторією, де ми тестуємо нові механіки, плагіни та підходи до адміністрування. Весь досвід, отриманий на Craftshade, ми перетворюємо на навчальні матеріали для вас.
              </p>
              <div className="bg-minecraft-diamond/10 rounded-lg p-4 border border-minecraft-diamond/30">
                <p className="text-minecraft-diamond font-medium">
                  IP сервера: <span className="font-mono">craftshade.net</span>
                </p>
                <p className="text-sm text-gray-400 mt-2">
                  Приєднуйтесь до нашої спільноти!
                </p>
              </div>
            </div>
          </section>

          {/* Development Status */}
          <section className="bg-gradient-to-br from-yellow-900/20 to-orange-900/20 rounded-xl p-8 border border-yellow-700/50">
            <div className="flex items-start gap-4 mb-6">
              <div className="p-3 bg-yellow-500/20 rounded-lg">
                <AlertCircle size={32} className="text-yellow-500" />
              </div>
              <div>
                <h2 className="text-3xl font-bold text-white mb-2">
                  Статус розробки
                </h2>
                <p className="text-yellow-200/80">
                  Важлива інформація для користувачів
                </p>
              </div>
            </div>
            <div className="space-y-4 text-yellow-100/90">
              <p>
                <strong className="text-yellow-200">Сайт знаходиться в активній розробці.</strong> Ми постійно працюємо над покращенням платформи, додаванням нових функцій та оновленням контенту курсів.
              </p>
              <div className="bg-yellow-500/10 rounded-lg p-4 border border-yellow-500/30">
                <h3 className="text-lg font-bold text-yellow-200 mb-2">Що це означає?</h3>
                <ul className="space-y-2 text-sm">
                  <li className="flex items-start gap-2">
                    <span className="text-yellow-400">•</span>
                    <span>Можливі тимчасові баги та глюки в роботі сайту</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-yellow-400">•</span>
                    <span>Деякі функції можуть працювати не ідеально</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-yellow-400">•</span>
                    <span>Дизайн та інтерфейс можуть змінюватись</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-yellow-400">•</span>
                    <span>Ми швидко виправляємо всі знайдені проблеми</span>
                  </li>
                </ul>
              </div>
            </div>
          </section>

          {/* Ongoing Updates */}
          <section className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-8 border border-gray-700">
            <div className="flex items-start gap-4 mb-6">
              <div className="p-3 bg-minecraft-emerald/20 rounded-lg">
                <Zap size={32} className="text-minecraft-emerald" />
              </div>
              <div>
                <h2 className="text-3xl font-bold text-white mb-2">
                  Постійні оновлення
                </h2>
                <p className="text-gray-400">
                  Ми не стоїмо на місці
                </p>
              </div>
            </div>
            <div className="space-y-4 text-gray-300">
              <p>
                Наша команда регулярно оновлює контент курсів, додає нові уроки та покращує існуючі матеріали.
              </p>
              <div className="grid md:grid-cols-2 gap-4">
                <div className="bg-minecraft-grass/10 rounded-lg p-4 border border-minecraft-grass/30">
                  <h3 className="text-lg font-bold text-minecraft-grass mb-2">Що оновлюється</h3>
                  <ul className="space-y-1 text-sm">
                    <li>→ Нові уроки та модулі</li>
                    <li>→ Оновлення під нові версії Minecraft</li>
                    <li>→ Актуалізація інформації про плагіни</li>
                    <li>→ Додаткові практичні приклади</li>
                  </ul>
                </div>
                <div className="bg-minecraft-diamond/10 rounded-lg p-4 border border-minecraft-diamond/30">
                  <h3 className="text-lg font-bold text-minecraft-diamond mb-2">Що планується</h3>
                  <ul className="space-y-1 text-sm">
                    <li>→ Відео-уроки до курсів</li>
                    <li>→ Інтерактивні квізи</li>
                    <li>→ Практичні завдання</li>
                    <li>→ Форум спільноти</li>
                  </ul>
                </div>
              </div>
            </div>
          </section>

          {/* Community */}
          <section className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-8 border border-gray-700">
            <div className="flex items-start gap-4 mb-6">
              <div className="p-3 bg-minecraft-gold/20 rounded-lg">
                <Users size={32} className="text-minecraft-gold" />
              </div>
              <div>
                <h2 className="text-3xl font-bold text-white mb-2">
                  Приєднуйтесь до спільноти
                </h2>
                <p className="text-gray-400">
                  Разом ми сильніші
                </p>
              </div>
            </div>
            <div className="space-y-4 text-gray-300">
              <p>
                Маєте питання, знайшли баг або хочете запропонувати покращення? Ми завжди раді зворотному зв'язку!
              </p>
              <div className="bg-gray-700/50 rounded-lg p-6 border border-gray-600">
                <h3 className="text-lg font-bold text-white mb-4">Контакти</h3>
                <div className="space-y-3">
                  <div>
                    <p className="text-sm text-gray-400">Discord сервер</p>
                    <p className="text-minecraft-diamond font-medium">discord.gg/craftshade</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-400">Email</p>
                    <p className="text-minecraft-diamond font-medium">support@craftshade.net</p>
                  </div>
                </div>
              </div>
            </div>
          </section>

        </div>
      </div>
    </div>
  );
}
