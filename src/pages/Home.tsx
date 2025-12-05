import { Link } from 'react-router-dom'
import { Sparkles, Target, Zap, Users, BookOpen, Clock, Award, Gift, Server, Code, Shield, Rocket, TrendingUp, Heart } from 'lucide-react'

export default function Home() {
  
  return (
    <div className="space-y-16 sm:space-y-20 md:space-y-24 py-6 sm:py-8 md:py-12">
      {/* Development Warning Banner */}
      <div className="container-custom">
        <div className="bg-gradient-to-r from-yellow-900/30 to-orange-900/30 border-2 border-yellow-700/50 rounded-xl p-4 md:p-6">
          <div className="flex items-start gap-3">
            <div className="text-yellow-500 mt-1">
              <Sparkles size={24} />
            </div>
            <div className="flex-1">
              <h3 className="text-yellow-200 font-bold text-lg mb-2">
                🚧 Сайт в активній розробці
              </h3>
              <p className="text-yellow-100/90 text-sm leading-relaxed">
                Ця платформа постійно оновлюється та покращується. Можливі тимчасові баги та глюки. 
                Всі курси, матеріали та функціонал регулярно доповнюються новим контентом. 
                Дякуємо за розуміння! 💚
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Hero Section */}
      <section className="relative overflow-hidden">
        {/* Background with overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-minecraft-grass/10 via-transparent to-transparent pointer-events-none" />
        <div className="absolute inset-0 bg-[url('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUpjSDKpgXhTAjEFxCMRlIsoaaiAjrUi83Pg&s')] bg-cover bg-center opacity-5 pointer-events-none" />
        
        <div className="container-custom relative z-10">
        <div className="text-center space-y-6 py-12 md:py-20">
          <div className="inline-block">
            <span className="bg-minecraft-emerald/10 border border-minecraft-emerald/30 text-minecraft-emerald px-5 py-2 rounded-full text-sm font-semibold flex items-center gap-2 mx-auto w-fit">
              <Sparkles size={16} />
              Професійні курси для Minecraft
            </span>
          </div>
          
          <h1 className="text-4xl md:text-6xl lg:text-7xl leading-tight font-bold">
            <span className="gradient-title">Створи Ідеальний<br />Minecraft-Сервер</span>
          </h1>
          
          <p className="text-gray-400 text-lg md:text-xl max-w-2xl mx-auto">
            Навчіться покроково будувати стабільний, оптимізований і автентичний сервер 
            з підходом <span className="text-minecraft-emerald font-semibold">"ванільний+"</span>
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
            <Link to="/courses" className="btn-primary">
              Переглянути курси
            </Link>
            <Link to="/about" className="btn-secondary">
              Дізнатися більше
            </Link>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 pt-6 sm:pt-8 max-w-4xl mx-auto px-4">
            {[
              { icon: <BookOpen className="w-5 h-5 sm:w-6 sm:h-6" />, value: '10+', label: 'Курсів' },
              { icon: <Clock className="w-5 h-5 sm:w-6 sm:h-6" />, value: '50+', label: 'Годин' },
              { icon: <Award className="w-5 h-5 sm:w-6 sm:h-6" />, value: '100%', label: 'Практика' },
              { icon: <Gift className="w-5 h-5 sm:w-6 sm:h-6" />, value: '6', label: 'Безкоштовно' },
            ].map((stat, index) => (
              <div key={index} className="bg-gradient-to-br from-gray-800/80 to-gray-900/80 rounded-lg sm:rounded-xl p-3 sm:p-4 border border-gray-700/50 hover:border-minecraft-emerald/50 transition-all hover:scale-105 backdrop-blur-sm">
                <div className="text-minecraft-emerald mb-1 sm:mb-2 flex justify-center">{stat.icon}</div>
                <div className="text-xl sm:text-2xl font-bold text-white">{stat.value}</div>
                <div className="text-gray-400 text-xs sm:text-sm mt-0.5 sm:mt-1">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
        </div>
      </section>

      {/* What You'll Learn */}
      <section className="container-custom">
        <div className="max-w-6xl mx-auto">
          <div className="text-center space-y-3 mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-white">
              Що ви <span className="text-minecraft-emerald">навчитесь</span>
            </h2>
            <p className="text-gray-400 max-w-2xl mx-auto">
              Від базових налаштувань до просунутих технік адміністрування
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              {
                icon: <Server className="w-7 h-7" />,
                title: 'Встановлення та Налаштування',
                description: 'Створіть сервер з нуля, налаштуйте хостинг та основні параметри',
                color: 'minecraft-grass'
              },
              {
                icon: <Code className="w-7 h-7" />,
                title: 'Плагіни та Моди',
                description: 'Встановлюйте, конфігуруйте та створюйте власні плагіни',
                color: 'minecraft-emerald'
              },
              {
                icon: <Shield className="w-7 h-7" />,
                title: 'Безпека Сервера',
                description: 'Захистіть сервер від DDoS, грифінгу та читерів',
                color: 'minecraft-diamond'
              },
              {
                icon: <Zap className="w-7 h-7" />,
                title: 'Оптимізація',
                description: 'Підвищте TPS, зменште лаги та покращте продуктивність',
                color: 'minecraft-gold'
              },
              {
                icon: <Users className="w-7 h-7" />,
                title: 'Спільнота та Маркетинг',
                description: 'Залучайте гравців та будуйте активну спільноту',
                color: 'minecraft-redstone'
              },
              {
                icon: <TrendingUp className="w-7 h-7" />,
                title: 'Монетизація',
                description: 'Заробляйте на сервері легально відповідно до Mojang EULA',
                color: 'minecraft-emerald'
              },
            ].map((item, index) => (
              <div
                key={index}
                className="bg-gradient-to-br from-gray-800/80 to-gray-900/80 rounded-xl p-6 border border-gray-700/50 hover:border-minecraft-emerald/50 transition-all hover:scale-105 space-y-3"
              >
                <div className={`inline-flex p-3 bg-${item.color}/10 rounded-lg text-${item.color}`}>
                  {item.icon}
                </div>
                <h3 className="text-xl font-bold text-white">{item.title}</h3>
                <p className="text-gray-400 text-sm leading-relaxed">{item.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="relative container-custom">
        <div className="absolute -top-20 -left-20 w-64 h-64 bg-minecraft-emerald/5 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-20 -right-20 w-64 h-64 bg-minecraft-diamond/5 rounded-full blur-3xl pointer-events-none" />
        
        <div className="text-center space-y-3 mb-10 relative z-10">
          <h2 className="text-3xl md:text-4xl font-bold text-white">
            Чому варто <span className="text-minecraft-emerald">обрати нас?</span>
          </h2>
          <p className="text-gray-400 max-w-2xl mx-auto">
            Найкращі курси для створення Minecraft-серверів українською мовою
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4 max-w-5xl mx-auto">
          {[
            {
              icon: <Sparkles className="w-6 h-6" />,
              title: 'Покрокові гайди',
              description: 'Детальні інструкції від встановлення до монетизації',
            },
            {
              icon: <Target className="w-6 h-6" />,
              title: 'Практичний підхід',
              description: 'Реальні приклади та готові конфігурації',
            },
            {
              icon: <Rocket className="w-6 h-6" />,
              title: 'Актуальність',
              description: 'Курси оновлюються під нові версії Minecraft',
            },
            {
              icon: <Users className="w-6 h-6" />,
              title: 'Спільнота',
              description: 'Доступ до Discord спільноти та підтримки',
            },
          ].map((feature, index) => (
            <div
              key={index}
              className="bg-gray-800/50 rounded-xl p-5 border border-gray-700/50 hover:border-minecraft-emerald/50 transition-all text-center space-y-3"
            >
              <div className="inline-flex p-3 bg-minecraft-emerald/10 rounded-lg text-minecraft-emerald">
                {feature.icon}
              </div>
              <h3 className="text-lg font-semibold text-white">{feature.title}</h3>
              <p className="text-gray-400 text-sm">{feature.description}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Course Categories */}
      <section className="container-custom">
        <div className="text-center space-y-3 mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-white">
            Категорії <span className="text-minecraft-gold">курсів</span>
          </h2>
          <p className="text-gray-400 max-w-2xl mx-auto">
            Обирайте курси за вашими інтересами та цілями
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6 max-w-4xl mx-auto">
          {/* Free Courses */}
          <Link 
            to="/courses" 
            className="group bg-gradient-to-br from-minecraft-emerald/20 to-minecraft-grass/20 rounded-2xl p-8 border-2 border-minecraft-emerald/30 hover:border-minecraft-emerald transition-all hover:scale-105"
          >
            <div className="flex items-start gap-4 mb-4">
              <div className="p-4 bg-minecraft-emerald/20 rounded-xl text-minecraft-emerald">
                <Gift size={32} />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <h3 className="text-2xl font-bold text-white">Безкоштовні курси</h3>
                  <span className="bg-minecraft-emerald/20 text-minecraft-emerald text-xs font-bold px-2 py-1 rounded">6 КУРСІВ</span>
                </div>
                <p className="text-gray-300 text-sm">
                  Почніть навчання безкоштовно з базових курсів
                </p>
              </div>
            </div>
            <ul className="space-y-2 text-sm text-gray-300">
              <li className="flex items-center gap-2">
                <span className="text-minecraft-emerald">→</span>
                Розробка ідеального сервера
              </li>
              <li className="flex items-center gap-2">
                <span className="text-minecraft-emerald">→</span>
                Плагіни - екосистема та основи
              </li>
              <li className="flex items-center gap-2">
                <span className="text-minecraft-emerald">→</span>
                Безпека сервера
              </li>
              <li className="flex items-center gap-2">
                <span className="text-minecraft-emerald">→</span>
                Економіка та монетизація
              </li>
            </ul>
            <div className="mt-6 text-minecraft-emerald group-hover:text-white transition-colors font-semibold flex items-center gap-2">
              Почати безкоштовно
              <Sparkles size={16} />
            </div>
          </Link>

          {/* Premium Courses */}
          <Link 
            to="/courses" 
            className="group bg-gradient-to-br from-minecraft-gold/20 to-yellow-900/20 rounded-2xl p-8 border-2 border-minecraft-gold/30 hover:border-minecraft-gold transition-all hover:scale-105"
          >
            <div className="flex items-start gap-4 mb-4">
              <div className="p-4 bg-minecraft-gold/20 rounded-xl text-minecraft-gold">
                <Award size={32} />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <h3 className="text-2xl font-bold text-white">Преміум курси</h3>
                  <span className="bg-minecraft-gold/20 text-minecraft-gold text-xs font-bold px-2 py-1 rounded">4 КУРСИ</span>
                </div>
                <p className="text-gray-300 text-sm">
                  Поглиблені знання для професіоналів
                </p>
              </div>
            </div>
            <ul className="space-y-2 text-sm text-gray-300">
              <li className="flex items-center gap-2">
                <span className="text-minecraft-gold">→</span>
                Оптимізація продуктивності
              </li>
              <li className="flex items-center gap-2">
                <span className="text-minecraft-gold">→</span>
                Створення міні-ігор
              </li>
              <li className="flex items-center gap-2">
                <span className="text-minecraft-gold">→</span>
                Розробка власних плагінів
              </li>
              <li className="flex items-center gap-2">
                <span className="text-minecraft-gold">→</span>
                DataPacks та Resource Packs
              </li>
            </ul>
            <div className="mt-6 text-minecraft-gold group-hover:text-white transition-colors font-semibold flex items-center gap-2">
              Переглянути преміум
              <Award size={16} />
            </div>
          </Link>
        </div>
      </section>

      {/* About Craftshade */}
      <section className="container-custom">
        <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl p-8 md:p-12 border border-gray-700 max-w-5xl mx-auto">
          <div className="grid md:grid-cols-2 gap-8 items-center">
            <div className="space-y-5">
              <div className="inline-flex p-3 bg-minecraft-diamond/10 rounded-lg text-minecraft-diamond">
                <Server size={32} />
              </div>
              <h2 className="text-3xl md:text-4xl font-bold text-white">
                Сервер <span className="text-minecraft-diamond">Craftshade</span>
              </h2>
              <p className="text-gray-400 leading-relaxed">
                Всі знання з наших курсів застосовуються на реальному сервері <strong className="text-white">Craftshade</strong> - 
                українському Minecraft проекті, де ми тестуємо кращі практики та нові механіки.
              </p>
              <div className="bg-minecraft-diamond/10 rounded-lg p-4 border border-minecraft-diamond/30">
                <p className="text-minecraft-diamond font-mono text-lg mb-1">
                  craftshade.net
                </p>
                <p className="text-sm text-gray-400">
                  Приєднуйся до нашої спільноти!
                </p>
              </div>
              <Link to="/about" className="inline-flex items-center gap-2 text-minecraft-diamond hover:text-white transition-colors font-semibold">
                Дізнатися більше про Craftshade
                <Sparkles size={16} />
              </Link>
            </div>
            <div className="space-y-4">
              {[
                { icon: <Users className="w-5 h-5" />, text: 'Активна спільнота гравців' },
                { icon: <Shield className="w-5 h-5" />, text: 'Надійний захист від грифінгу' },
                { icon: <Zap className="w-5 h-5" />, text: 'Оптимізована продуктивність' },
                { icon: <Heart className="w-5 h-5" />, text: 'Ванільний+ досвід' },
              ].map((item, index) => (
                <div key={index} className="flex items-center gap-3 bg-gray-800/50 rounded-lg p-4 border border-gray-700/50">
                  <div className="text-minecraft-diamond">{item.icon}</div>
                  <span className="text-gray-300">{item.text}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="container-custom">
        <div className="relative bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl p-8 md:p-10 border border-gray-700 text-center space-y-6 max-w-4xl mx-auto overflow-hidden">
          {/* Decorative background */}
          <div className="absolute inset-0 bg-[url('https://i.pinimg.com/736x/c5/23/aa/c523aa84752f820ba3642666887b37ba.jpg')] bg-cover bg-center opacity-5 pointer-events-none" />
          <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-br from-minecraft-emerald/10 via-transparent to-minecraft-diamond/10 pointer-events-none" />
          <div className="relative z-10">
          <h2 className="text-3xl md:text-4xl font-bold text-white">
            <span className="gradient-title">Готові почати?</span>
          </h2>
          <p className="text-gray-400 max-w-xl mx-auto">
            Приєднуйтесь до спільноти розробників серверів та створіть свій ідеальний Minecraft світ
          </p>
          
          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
            <Link to="/courses" className="btn-primary flex items-center gap-2">
              <Sparkles size={18} />
              Почати безкоштовно
            </Link>
            <Link to="/about" className="btn-secondary flex items-center gap-2">
              <Server size={18} />
              Про проект
            </Link>
          </div>
          
          <div className="grid md:grid-cols-3 gap-4 pt-4">
            {[
              { icon: <BookOpen className="w-5 h-5" />, text: '10 курсів', subtext: '6 безкоштовних' },
              { icon: <Users className="w-5 h-5" />, text: 'Спільнота', subtext: 'Discord сервер' },
              { icon: <Award className="w-5 h-5" />, text: 'Практика', subtext: 'Реальні приклади' },
            ].map((item, index) => (
              <div key={index} className="bg-gray-800/50 rounded-lg p-4 border border-gray-700/50">
                <div className="text-minecraft-emerald mb-2 flex justify-center">{item.icon}</div>
                <div className="text-white font-semibold text-sm">{item.text}</div>
                <div className="text-gray-500 text-xs">{item.subtext}</div>
              </div>
            ))}
          </div>
          </div>
        </div>
      </section>
    </div>
  )
}
