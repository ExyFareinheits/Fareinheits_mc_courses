import { Link } from 'react-router-dom'
import { Github, Twitter, Youtube, Heart } from 'lucide-react'

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-minecraft-obsidian border-t-4 border-minecraft-emerald">
      <div className="container-custom py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* About */}
          <div className="space-y-4">
            <h3 className="text-minecraft-emerald font-bold text-lg">MC Курси</h3>
            <p className="text-gray-400 text-sm">
              Професійні курси по створенню та управлінню Minecraft-серверами. 
              Від новачка до експерта.
            </p>
          </div>

          {/* Quick Links */}
          <div className="space-y-4">
            <h3 className="text-minecraft-emerald font-bold text-lg">Швидкі посилання</h3>
            <ul className="space-y-2">
              <li>
                <Link to="/" className="text-gray-400 hover:text-minecraft-emerald transition-colors text-sm">
                  Головна
                </Link>
              </li>
              <li>
                <Link to="/courses" className="text-gray-400 hover:text-minecraft-emerald transition-colors text-sm">
                  Всі курси
                </Link>
              </li>
              <li>
                <Link to="/about" className="text-gray-400 hover:text-minecraft-emerald transition-colors text-sm">
                  Про нас
                </Link>
              </li>
            </ul>
          </div>

          {/* Support */}
          <div className="space-y-4">
            <h3 className="text-minecraft-emerald font-bold text-lg">Підтримка</h3>
            <ul className="space-y-2">
              <li>
                <a href="https://patreon.com" className="text-gray-400 hover:text-minecraft-emerald transition-colors text-sm">
                  Patreon
                </a>
              </li>
              <li>
                <a href="https://ko-fi.com" className="text-gray-400 hover:text-minecraft-emerald transition-colors text-sm">
                  Ko-fi
                </a>
              </li>
              <li>
                <a href="https://gumroad.com" className="text-gray-400 hover:text-minecraft-emerald transition-colors text-sm">
                  Gumroad
                </a>
              </li>
            </ul>
          </div>

          {/* Social */}
          <div className="space-y-4">
            <h3 className="text-minecraft-emerald font-bold text-lg">Соціальні мережі</h3>
            <div className="flex space-x-4">
              <a
                href="https://github.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-minecraft-emerald transition-colors"
              >
                <Github size={24} />
              </a>
              <a
                href="https://twitter.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-minecraft-emerald transition-colors"
              >
                <Twitter size={24} />
              </a>
              <a
                href="https://youtube.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-minecraft-emerald transition-colors"
              >
                <Youtube size={24} />
              </a>
            </div>
          </div>
        </div>

        {/* Bottom */}
        <div className="mt-8 pt-8 border-t border-gray-700">
          <div className="flex flex-col md:flex-row items-center justify-between">
            <p className="text-gray-400 text-sm">
              © {currentYear} MC Курси. Всі права захищені.
            </p>
            <p className="text-gray-400 text-sm flex items-center gap-1 mt-2 md:mt-0">
              Зроблено з <Heart size={16} className="text-red-500" /> для Minecraft спільноти
            </p>
          </div>
        </div>
      </div>
    </footer>
  )
}
