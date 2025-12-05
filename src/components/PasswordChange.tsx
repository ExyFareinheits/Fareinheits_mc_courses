import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { Lock, Eye, EyeOff, CheckCircle, AlertCircle } from 'lucide-react';

interface PasswordChangeProps {
  onSuccess?: () => void;
}

export default function PasswordChange({ onSuccess }: PasswordChangeProps) {
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  // Валідація пароля
  const validatePassword = (password: string) => {
    const errors: string[] = [];
    
    if (password.length < 8) {
      errors.push('Мінімум 8 символів');
    }
    if (!/[A-Z]/.test(password)) {
      errors.push('Мінімум 1 велика літера');
    }
    if (!/[a-z]/.test(password)) {
      errors.push('Мінімум 1 мала літера');
    }
    if (!/[0-9]/.test(password)) {
      errors.push('Мінімум 1 цифра');
    }
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
      errors.push('Мінімум 1 спецсимвол (!@#$%^&*...)');
    }
    
    return errors;
  };

  const passwordStrength = (password: string): { strength: string; color: string; percent: number } => {
    let strength = 0;
    
    if (password.length >= 8) strength += 20;
    if (password.length >= 12) strength += 20;
    if (/[a-z]/.test(password)) strength += 15;
    if (/[A-Z]/.test(password)) strength += 15;
    if (/[0-9]/.test(password)) strength += 15;
    if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) strength += 15;
    
    if (strength < 40) return { strength: 'Слабкий', color: 'bg-red-500', percent: strength };
    if (strength < 70) return { strength: 'Середній', color: 'bg-yellow-500', percent: strength };
    return { strength: 'Сильний', color: 'bg-green-500', percent: strength };
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess(false);

    // Валідація
    if (!currentPassword || !newPassword || !confirmPassword) {
      setError('Заповніть всі поля');
      return;
    }

    if (newPassword !== confirmPassword) {
      setError('Новий пароль та підтвердження не співпадають');
      return;
    }

    if (newPassword === currentPassword) {
      setError('Новий пароль не може бути таким самим як старий');
      return;
    }

    const passwordErrors = validatePassword(newPassword);
    if (passwordErrors.length > 0) {
      setError(`Пароль не відповідає вимогам: ${passwordErrors.join(', ')}`);
      return;
    }

    setLoading(true);

    try {
      // 1. Перевірити старий пароль через спробу входу
      const { data: { user } } = await supabase.auth.getUser();
      
      if (!user?.email) {
        throw new Error('Користувач не авторизований');
      }

      // Спробувати увійти зі старим паролем для перевірки
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: user.email,
        password: currentPassword,
      });

      if (signInError) {
        setError('Неправильний поточний пароль');
        setLoading(false);
        return;
      }

      // 2. Оновити пароль (Supabase автоматично хешує bcrypt)
      const { error: updateError } = await supabase.auth.updateUser({
        password: newPassword,
      });

      if (updateError) {
        throw updateError;
      }

      // 3. Залогувати зміну в БД (опціонально)
      try {
        await supabase.rpc('change_password_with_verification', {
          old_password: currentPassword,
          new_password: newPassword,
        });
      } catch (rpcError) {
        // Ігноруємо помилку логування, головне що пароль змінено
        console.log('Logging failed, but password changed:', rpcError);
      }

      // Успіх!
      setSuccess(true);
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      
      if (onSuccess) {
        setTimeout(() => onSuccess(), 2000);
      }
    } catch (err: any) {
      setError(err.message || 'Помилка при зміні пароля');
    } finally {
      setLoading(false);
    }
  };

  const newPasswordErrors = newPassword ? validatePassword(newPassword) : [];
  const strength = newPassword ? passwordStrength(newPassword) : null;

  return (
    <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl p-8 border border-gray-700">
      <h2 className="text-2xl font-bold text-white mb-6 flex items-center gap-3">
        <Lock className="w-8 h-8 text-minecraft-emerald" />
        Зміна пароля
      </h2>

      {success && (
        <div className="mb-6 p-4 bg-green-500/10 border border-green-500/30 rounded-xl flex items-start gap-3">
          <CheckCircle className="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" />
          <div>
            <h3 className="text-green-400 font-semibold mb-1">Пароль успішно змінено!</h3>
            <p className="text-green-300/80 text-sm">
              Ваш новий пароль захищений за допомогою bcrypt хешування
            </p>
          </div>
        </div>
      )}

      {error && (
        <div className="mb-6 p-4 bg-red-500/10 border border-red-500/30 rounded-xl flex items-start gap-3">
          <AlertCircle className="w-6 h-6 text-red-400 flex-shrink-0 mt-0.5" />
          <div>
            <h3 className="text-red-400 font-semibold mb-1">Помилка</h3>
            <p className="text-red-300/80 text-sm">{error}</p>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Поточний пароль */}
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Поточний пароль
          </label>
          <div className="relative">
            <input
              type={showCurrentPassword ? 'text' : 'password'}
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50 pr-12"
              placeholder="Введіть поточний пароль"
              autoComplete="current-password"
            />
            <button
              type="button"
              onClick={() => setShowCurrentPassword(!showCurrentPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors"
            >
              {showCurrentPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {/* Новий пароль */}
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Новий пароль
          </label>
          <div className="relative">
            <input
              type={showNewPassword ? 'text' : 'password'}
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50 pr-12"
              placeholder="Введіть новий пароль"
              autoComplete="new-password"
            />
            <button
              type="button"
              onClick={() => setShowNewPassword(!showNewPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors"
            >
              {showNewPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>

          {/* Індикатор складності пароля */}
          {newPassword && strength && (
            <div className="mt-3">
              <div className="flex justify-between text-sm mb-2">
                <span className="text-gray-400">Складність пароля:</span>
                <span className={`font-semibold ${
                  strength.strength === 'Слабкий' ? 'text-red-400' :
                  strength.strength === 'Середній' ? 'text-yellow-400' :
                  'text-green-400'
                }`}>
                  {strength.strength}
                </span>
              </div>
              <div className="w-full bg-gray-700 rounded-full h-2">
                <div
                  className={`${strength.color} h-2 rounded-full transition-all duration-300`}
                  style={{ width: `${strength.percent}%` }}
                />
              </div>
            </div>
          )}

          {/* Вимоги до пароля */}
          {newPassword && newPasswordErrors.length > 0 && (
            <div className="mt-3 space-y-1">
              {newPasswordErrors.map((err, idx) => (
                <div key={idx} className="flex items-center gap-2 text-sm text-red-400">
                  <AlertCircle className="w-4 h-4 flex-shrink-0" />
                  <span>{err}</span>
                </div>
              ))}
            </div>
          )}

          {newPassword && newPasswordErrors.length === 0 && (
            <div className="mt-3 flex items-center gap-2 text-sm text-green-400">
              <CheckCircle className="w-4 h-4" />
              <span>Пароль відповідає всім вимогам</span>
            </div>
          )}
        </div>

        {/* Підтвердження пароля */}
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Підтвердіть новий пароль
          </label>
          <div className="relative">
            <input
              type={showConfirmPassword ? 'text' : 'password'}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50 pr-12"
              placeholder="Повторіть новий пароль"
              autoComplete="new-password"
            />
            <button
              type="button"
              onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors"
            >
              {showConfirmPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>

          {confirmPassword && confirmPassword !== newPassword && (
            <div className="mt-2 flex items-center gap-2 text-sm text-red-400">
              <AlertCircle className="w-4 h-4" />
              <span>Паролі не співпадають</span>
            </div>
          )}

          {confirmPassword && confirmPassword === newPassword && (
            <div className="mt-2 flex items-center gap-2 text-sm text-green-400">
              <CheckCircle className="w-4 h-4" />
              <span>Паролі співпадають</span>
            </div>
          )}
        </div>

        {/* Інфо про безпеку */}
        <div className="p-4 bg-blue-500/10 border border-blue-500/30 rounded-xl">
          <div className="flex items-start gap-3">
            <Lock className="w-5 h-5 text-blue-400 flex-shrink-0 mt-0.5" />
            <div className="text-sm text-blue-300/80">
              <p className="font-semibold mb-1 text-blue-400">Захист вашого пароля:</p>
              <ul className="space-y-1 list-disc list-inside">
                <li>Пароль хешується за допомогою bcrypt</li>
                <li>Ніколи не зберігається в відкритому вигляді</li>
                <li>Захищений від SQL-ін'єкцій</li>
                <li>Передається через безпечне HTTPS з'єднання</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Кнопка */}
        <button
          type="submit"
          disabled={loading || newPasswordErrors.length > 0 || newPassword !== confirmPassword}
          className="w-full py-4 bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond text-white font-bold rounded-xl hover:shadow-lg hover:shadow-minecraft-emerald/20 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Зміна пароля...' : 'Змінити пароль'}
        </button>
      </form>
    </div>
  );
}
