import { Link } from 'react-router-dom'
import { Menu, X, Hammer, LogOut, User, ChevronDown, Crown } from 'lucide-react'
import { useState, useEffect } from 'react'
import { useAuthStore } from '../store/authStore'
import { useProgressStore } from '../store/progressStore'
import { supabase } from '../lib/supabase'
import AuthModal from './AuthModal'

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false)
  const [isUserMenuOpen, setIsUserMenuOpen] = useState(false)
  const [isAdmin, setIsAdmin] = useState(false)
  const { user, signOut, initialize } = useAuthStore()
  const { syncProgressFromDB } = useProgressStore()

  useEffect(() => {
    initialize()
  }, [initialize])

  useEffect(() => {
    if (user) {
      syncProgressFromDB(user.id)
      checkAdminStatus()
    }
  }, [user, syncProgressFromDB])

  const checkAdminStatus = async () => {
    if (!user) {
      setIsAdmin(false)
      return
    }

    try {
      const { data, error } = await supabase
        .from('admins')
        .select('*')
        .eq('user_id', user.id)
        .single()

      setIsAdmin(!error && !!data)
    } catch (err) {
      setIsAdmin(false)
    }
  }

  return (
    <>
      <header className="bg-minecraft-obsidian/80 backdrop-blur-md sticky top-0 z-50 border-b border-minecraft-emerald/30 shadow-xl">
        <nav className="container-custom py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link to="/" className="flex items-center space-x-3 group">
              <div className="bg-gradient-to-br from-minecraft-grass to-minecraft-emerald p-2 rounded-lg transform group-hover:rotate-12 transition-all duration-300 group-hover:shadow-lg group-hover:shadow-minecraft-emerald/50">
                <Hammer className="w-6 h-6 text-white" />
              </div>
              <span className="text-xl font-bold bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond bg-clip-text text-transparent">
                MC Курси
              </span>
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center space-x-8">
              <Link
                to="/"
                className="text-gray-300 hover:text-minecraft-emerald transition-colors font-medium"
              >
                Головна
              </Link>
              <Link
                to="/courses"
                className="text-gray-300 hover:text-minecraft-emerald transition-colors font-medium"
              >
                Курси
              </Link>
              <a
                href="#about"
                className="text-gray-300 hover:text-minecraft-emerald transition-colors font-medium"
              >
                Про нас
              </a>
              
              {user ? (
                <div className="relative">
                  <button
                    onClick={() => setIsUserMenuOpen(!isUserMenuOpen)}
                    className="flex items-center gap-2 text-gray-300 hover:text-minecraft-emerald transition-colors"
                  >
                    <User className="w-5 h-5" />
                    <span className="text-sm">{user.email}</span>
                    <ChevronDown className={`w-4 h-4 transition-transform ${isUserMenuOpen ? 'rotate-180' : ''}`} />
                  </button>
                  
                  {isUserMenuOpen && (
                    <div className="absolute right-0 mt-2 w-48 bg-minecraft-obsidian border border-minecraft-emerald/30 rounded-lg shadow-xl py-2">
                      <Link
                        to="/profile"
                        onClick={() => setIsUserMenuOpen(false)}
                        className="block px-4 py-2 text-gray-300 hover:bg-minecraft-emerald/10 hover:text-minecraft-emerald transition-colors flex items-center gap-2"
                      >
                        <User className="w-4 h-4" />
                        Мій профіль
                      </Link>
                      {isAdmin && (
                        <Link
                          to="/admin"
                          onClick={() => setIsUserMenuOpen(false)}
                          className="block px-4 py-2 text-gray-300 hover:bg-minecraft-gold/10 hover:text-minecraft-gold transition-colors flex items-center gap-2"
                        >
                          <Crown className="w-4 h-4" />
                          Адмін панель
                        </Link>
                      )}
                      <button
                        onClick={() => {
                          signOut()
                          setIsUserMenuOpen(false)
                        }}
                        className="w-full text-left px-4 py-2 text-gray-300 hover:bg-minecraft-emerald/10 hover:text-minecraft-emerald transition-colors flex items-center gap-2"
                      >
                        <LogOut className="w-4 h-4" />
                        Вийти
                      </button>
                    </div>
                  )}
                </div>
              ) : (
                <button
                  onClick={() => setIsAuthModalOpen(true)}
                  className="btn-primary"
                >
                  Увійти
                </button>
              )}
            </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="md:hidden text-white p-2"
          >
            {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* Mobile Menu */}
        {isMenuOpen && (
          <div className="md:hidden mt-4 pb-4 space-y-4">
            <Link
              to="/"
              onClick={() => setIsMenuOpen(false)}
              className="block text-gray-300 hover:text-minecraft-emerald transition-colors font-medium"
            >
              Головна
            </Link>
            <Link
              to="/courses"
              onClick={() => setIsMenuOpen(false)}
              className="block text-gray-300 hover:text-minecraft-emerald transition-colors font-medium"
            >
              Курси
            </Link>
            <a
              href="#about"
              onClick={() => setIsMenuOpen(false)}
              className="block text-gray-300 hover:text-minecraft-emerald transition-colors font-medium"
            >
              Про нас
            </a>
            {user ? (
              <>
                <div className="flex items-center gap-2 text-gray-300 py-2">
                  <User className="w-5 h-5" />
                  <span className="text-sm">{user.email}</span>
                </div>
                <Link
                  to="/profile"
                  onClick={() => setIsMenuOpen(false)}
                  className="block text-gray-300 hover:text-minecraft-emerald transition-colors font-medium"
                >
                  Мій профіль
                </Link>
                {isAdmin && (
                  <Link
                    to="/admin"
                    onClick={() => setIsMenuOpen(false)}
                    className="block text-gray-300 hover:text-minecraft-gold transition-colors font-medium flex items-center gap-2"
                  >
                    <Crown className="w-4 h-4" />
                    Адмін панель
                  </Link>
                )}
                <button
                  onClick={() => {
                    signOut()
                    setIsMenuOpen(false)
                  }}
                  className="block btn-secondary text-center flex items-center justify-center gap-2"
                >
                  <LogOut className="w-4 h-4" />
                  Війти
                </button>
              </>
            ) : (
              <button
                onClick={() => {
                  setIsAuthModalOpen(true)
                  setIsMenuOpen(false)
                }}
                className="block btn-primary text-center"
              >
                Увійти
              </button>
            )}
          </div>
        )}
      </nav>
    </header>

    <AuthModal isOpen={isAuthModalOpen} onClose={() => setIsAuthModalOpen(false)} />
  </>
  )
}
