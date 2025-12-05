import { useEffect, useState } from 'react';
import { useAuthStore } from '../store/authStore';
import { supabase } from '../lib/supabase';
import { useNavigate } from 'react-router-dom';
import { 
  Shield, 
  Users, 
  BookOpen, 
  CheckCircle, 
  XCircle, 
  Clock,
  Search,
  AlertCircle,
  Crown,
  Plus,
  Trash2,
  FileText
} from 'lucide-react';
import AdminRequestsTab from '../components/AdminRequestsTab';

interface User {
  id: string;
  email: string;
  created_at: string;
  last_sign_in_at: string | null;
}

interface CourseAccess {
  id: string;
  user_id: string;
  course_id: string;
  granted_at: string;
  expires_at: string | null;
  is_active: boolean;
}

interface AdminLog {
  id: string;
  action: string;
  target_user_id: string;
  target_user_email?: string;
  details: any;
  created_at: string;
}

const availableCourses = [
  { id: 'paid-1', name: 'Професійна Розробка Плагінів' },
  { id: 'paid-2', name: 'Розширений Курс 2' },
  { id: 'paid-3', name: 'Розширений Курс 3' },
  { id: 'paid-4', name: 'Розширений Курс 4' },
];

export default function Admin() {
  const { user } = useAuthStore();
  const navigate = useNavigate();
  
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'users' | 'access' | 'requests' | 'logs'>('requests');
  
  // Users tab
  const [users, setUsers] = useState<User[]>([]);
  const [searchEmail, setSearchEmail] = useState('');
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
  
  // Access tab
  const [selectedUser, setSelectedUser] = useState<string>('');
  const [selectedCourse, setSelectedCourse] = useState<string>('paid-1');
  const [expiresInDays, setExpiresInDays] = useState<number>(0);
  const [courseAccesses, setCourseAccesses] = useState<CourseAccess[]>([]);
  
  // Logs tab
  const [adminLogs, setAdminLogs] = useState<AdminLog[]>([]);
  
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Перевірка чи користувач адмін
  useEffect(() => {
    const checkAdmin = async () => {
      if (!user) {
        navigate('/');
        return;
      }

      try {
        const { data, error } = await supabase
          .from('admins')
          .select('*')
          .eq('user_id', user.id)
          .single();

        if (error || !data) {
          navigate('/');
          return;
        }

        setIsAdmin(true);
        loadAllData();
      } catch (err) {
        navigate('/');
      } finally {
        setLoading(false);
      }
    };

    checkAdmin();
  }, [user, navigate]);

  const loadAllData = async () => {
    await Promise.all([
      loadUsers(),
      loadCourseAccesses(),
      loadAdminLogs()
    ]);
  };

  const loadUsers = async () => {
    try {
      // Використовуємо service role key через Edge Function або RPC
      const { data, error } = await supabase.rpc('admin_get_all_users');
      
      if (error) throw error;
      
      const usersData = data as User[];
      setUsers(usersData);
      setFilteredUsers(usersData);
    } catch (err: any) {
      console.error('Error loading users:', err);
      setError('Не вдалося завантажити користувачів');
    }
  };

  const loadCourseAccesses = async () => {
    try {
      const { data, error } = await supabase
        .from('user_course_access')
        .select('*')
        .order('granted_at', { ascending: false });

      if (error) throw error;
      setCourseAccesses(data || []);
    } catch (err: any) {
      console.error('Error loading accesses:', err);
    }
  };

  const loadAdminLogs = async () => {
    try {
      const { data, error } = await supabase
        .from('admin_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(50);

      if (error) throw error;
      
      // Додати email користувачів до логів
      const logsWithEmails = await Promise.all(
        (data || []).map(async (log) => {
          if (log.target_user_id) {
            const user = users.find(u => u.id === log.target_user_id);
            return { ...log, target_user_email: user?.email };
          }
          return log;
        })
      );
      
      setAdminLogs(logsWithEmails);
    } catch (err: any) {
      console.error('Error loading logs:', err);
    }
  };

  // Фільтрація користувачів
  useEffect(() => {
    if (searchEmail.trim() === '') {
      setFilteredUsers(users);
    } else {
      setFilteredUsers(
        users.filter(u => 
          u.email.toLowerCase().includes(searchEmail.toLowerCase())
        )
      );
    }
  }, [searchEmail, users]);

  const grantCourseAccess = async () => {
    if (!selectedUser || !selectedCourse) {
      setError('Виберіть користувача та курс');
      return;
    }

    setError('');
    setSuccess('');

    try {
      const expiresAt = expiresInDays > 0 
        ? new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000).toISOString()
        : null;

      const { data, error } = await supabase.rpc('grant_course_access', {
        p_user_id: selectedUser,
        p_course_id: selectedCourse,
        p_expires_at: expiresAt
      });

      if (error) throw error;

      if (data.success) {
        setSuccess(`Доступ до курсу "${selectedCourse}" надано!`);
        await loadCourseAccesses();
        await loadAdminLogs();
        setSelectedUser('');
      } else {
        setError(data.message);
      }
    } catch (err: any) {
      setError(err.message || 'Помилка при наданні доступу');
    }
  };

  const revokeCourseAccess = async (accessId: string) => {
    if (!confirm('Ви впевнені що хочете відкликати доступ?')) return;

    try {
      const access = courseAccesses.find(a => a.id === accessId);
      if (!access) return;

      const { data, error } = await supabase.rpc('revoke_course_access', {
        p_user_id: access.user_id,
        p_course_id: access.course_id
      });

      if (error) throw error;

      if (data.success) {
        setSuccess('Доступ відкликано');
        await loadCourseAccesses();
        await loadAdminLogs();
      } else {
        setError(data.message);
      }
    } catch (err: any) {
      setError(err.message || 'Помилка при відкликанні доступу');
    }
  };

  const bulkGrantAccess = async () => {
    if (!selectedCourse) {
      setError('Виберіть курс');
      return;
    }

    if (!confirm(`Надати доступ до "${selectedCourse}" ВСІМ користувачам?`)) {
      return;
    }

    setError('');
    setSuccess('');

    try {
      const userIds = users.map(u => u.id);
      const expiresAt = expiresInDays > 0 
        ? new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000).toISOString()
        : null;

      const { data, error } = await supabase.rpc('admin_bulk_grant_access', {
        p_user_ids: userIds,
        p_course_id: selectedCourse,
        p_expires_at: expiresAt
      });

      if (error) throw error;

      if (data.success) {
        setSuccess(`Доступ надано ${data.granted_count} користувачам!`);
        await loadCourseAccesses();
        await loadAdminLogs();
      } else {
        setError(data.message);
      }
    } catch (err: any) {
      setError(err.message || 'Помилка при масовому наданні доступу');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black flex items-center justify-center">
        <div className="text-white text-xl">Завантаження...</div>
      </div>
    );
  }

  if (!isAdmin) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black py-12 px-4">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-4">
            <div className="bg-gradient-to-r from-minecraft-gold to-yellow-600 p-3 rounded-xl">
              <Crown className="w-8 h-8 text-white" />
            </div>
            <div>
              <h1 className="text-4xl font-bold text-white">Адмін Панель</h1>
              <p className="text-gray-400">Керування користувачами та доступом до курсів</p>
            </div>
          </div>
        </div>

        {/* Alerts */}
        {error && (
          <div className="mb-6 p-4 bg-red-500/10 border border-red-500/30 rounded-xl flex items-start gap-3">
            <AlertCircle className="w-6 h-6 text-red-400 flex-shrink-0 mt-0.5" />
            <div>
              <h3 className="text-red-400 font-semibold mb-1">Помилка</h3>
              <p className="text-red-300/80 text-sm">{error}</p>
            </div>
          </div>
        )}

        {success && (
          <div className="mb-6 p-4 bg-green-500/10 border border-green-500/30 rounded-xl flex items-start gap-3">
            <CheckCircle className="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" />
            <div>
              <h3 className="text-green-400 font-semibold mb-1">Успішно</h3>
              <p className="text-green-300/80 text-sm">{success}</p>
            </div>
          </div>
        )}

        {/* Tabs */}
        <div className="flex gap-4 mb-6 overflow-x-auto">
          <button
            onClick={() => setActiveTab('requests')}
            className={`flex items-center gap-2 px-6 py-3 rounded-xl font-semibold transition-all whitespace-nowrap ${
              activeTab === 'requests'
                ? 'bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond text-white'
                : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
            }`}
          >
            <FileText className="w-5 h-5" />
            Запити на доступ
          </button>
          <button
            onClick={() => setActiveTab('users')}
            className={`flex items-center gap-2 px-6 py-3 rounded-xl font-semibold transition-all whitespace-nowrap ${
              activeTab === 'users'
                ? 'bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond text-white'
                : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
            }`}
          >
            <Users className="w-5 h-5" />
            Користувачі ({users.length})
          </button>
          <button
            onClick={() => setActiveTab('access')}
            className={`flex items-center gap-2 px-6 py-3 rounded-xl font-semibold transition-all whitespace-nowrap ${
              activeTab === 'access'
                ? 'bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond text-white'
                : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
            }`}
          >
            <BookOpen className="w-5 h-5" />
            Доступ до курсів
          </button>
          <button
            onClick={() => setActiveTab('logs')}
            className={`flex items-center gap-2 px-6 py-3 rounded-xl font-semibold transition-all whitespace-nowrap ${
              activeTab === 'logs'
                ? 'bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond text-white'
                : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
            }`}
          >
            <Shield className="w-5 h-5" />
            Логи ({adminLogs.length})
          </button>
        </div>

        {/* Content */}
        <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl p-8 border border-gray-700">
          {/* Requests Tab */}
          {activeTab === 'requests' && (
            <AdminRequestsTab onUpdate={loadAllData} />
          )}

          {/* Users Tab */}
          {activeTab === 'users' && (
            <div>
              <div className="mb-6">
                <div className="relative">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="text"
                    value={searchEmail}
                    onChange={(e) => setSearchEmail(e.target.value)}
                    placeholder="Пошук за email..."
                    className="w-full pl-12 pr-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
                  />
                </div>
              </div>

              <div className="space-y-3">
                {filteredUsers.map((user) => {
                  const userAccesses = courseAccesses.filter(a => a.user_id === user.id && a.is_active);
                  
                  return (
                    <div
                      key={user.id}
                      className="bg-gray-700/30 rounded-xl p-4 border border-gray-600/50 hover:border-minecraft-emerald/50 transition-all"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-2">
                            <h3 className="text-white font-semibold">{user.email}</h3>
                            {user.email === 'fareinheitsgithub@gmail.com' && (
                              <span className="px-3 py-1 bg-gradient-to-r from-minecraft-gold to-yellow-600 text-white text-xs font-bold rounded-full">
                                АДМІН
                              </span>
                            )}
                          </div>
                          <div className="flex gap-4 text-sm text-gray-400">
                            <span>ID: {user.id.substring(0, 8)}...</span>
                            <span>Створено: {new Date(user.created_at).toLocaleDateString('uk-UA')}</span>
                            {user.last_sign_in_at && (
                              <span>Останній вхід: {new Date(user.last_sign_in_at).toLocaleDateString('uk-UA')}</span>
                            )}
                          </div>
                          {userAccesses.length > 0 && (
                            <div className="mt-2 flex flex-wrap gap-2">
                              {userAccesses.map((access) => (
                                <span
                                  key={access.id}
                                  className="px-3 py-1 bg-minecraft-emerald/20 border border-minecraft-emerald/30 text-minecraft-emerald text-xs font-semibold rounded-full"
                                >
                                  {access.course_id}
                                  {access.expires_at && (
                                    <span className="ml-1 opacity-70">
                                      до {new Date(access.expires_at).toLocaleDateString('uk-UA')}
                                    </span>
                                  )}
                                </span>
                              ))}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* Access Tab */}
          {activeTab === 'access' && (
            <div>
              <div className="mb-8 p-6 bg-blue-500/10 border border-blue-500/30 rounded-xl">
                <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
                  <Plus className="w-6 h-6" />
                  Надати доступ
                </h3>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-300 mb-2">
                      Користувач
                    </label>
                    <select
                      value={selectedUser}
                      onChange={(e) => setSelectedUser(e.target.value)}
                      className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
                    >
                      <option value="">Виберіть користувача</option>
                      {users.map((user) => (
                        <option key={user.id} value={user.id}>
                          {user.email}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-300 mb-2">
                      Курс
                    </label>
                    <select
                      value={selectedCourse}
                      onChange={(e) => setSelectedCourse(e.target.value)}
                      className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
                    >
                      {availableCourses.map((course) => (
                        <option key={course.id} value={course.id}>
                          {course.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-300 mb-2">
                      Термін дії (днів, 0 = безстроково)
                    </label>
                    <input
                      type="number"
                      min="0"
                      value={expiresInDays}
                      onChange={(e) => setExpiresInDays(parseInt(e.target.value) || 0)}
                      className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
                    />
                  </div>
                </div>

                <div className="flex gap-3">
                  <button
                    onClick={grantCourseAccess}
                    className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond text-white font-bold rounded-xl hover:shadow-lg hover:shadow-minecraft-emerald/20 transition-all"
                  >
                    <CheckCircle className="w-5 h-5" />
                    Надати доступ
                  </button>

                  <button
                    onClick={bulkGrantAccess}
                    className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-minecraft-gold to-yellow-600 text-white font-bold rounded-xl hover:shadow-lg transition-all"
                  >
                    <Users className="w-5 h-5" />
                    Надати ВСІМ
                  </button>
                </div>
              </div>

              {/* Current Accesses */}
              <h3 className="text-xl font-bold text-white mb-4">Активні доступи</h3>
              <div className="space-y-3">
                {courseAccesses
                  .filter(a => a.is_active)
                  .map((access) => {
                    const user = users.find(u => u.id === access.user_id);
                    const course = availableCourses.find(c => c.id === access.course_id);
                    const isExpired = access.expires_at && new Date(access.expires_at) < new Date();

                    return (
                      <div
                        key={access.id}
                        className={`bg-gray-700/30 rounded-xl p-4 border ${
                          isExpired ? 'border-red-500/50' : 'border-gray-600/50'
                        } hover:border-minecraft-emerald/50 transition-all`}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-3 mb-2">
                              <h4 className="text-white font-semibold">{user?.email || 'Невідомий'}</h4>
                              <span className="px-3 py-1 bg-minecraft-emerald/20 text-minecraft-emerald text-xs font-bold rounded-full">
                                {course?.name || access.course_id}
                              </span>
                              {isExpired && (
                                <span className="px-3 py-1 bg-red-500/20 text-red-400 text-xs font-bold rounded-full">
                                  ЗАКІНЧИВСЯ
                                </span>
                              )}
                            </div>
                            <div className="flex gap-4 text-sm text-gray-400">
                              <span className="flex items-center gap-1">
                                <Clock className="w-4 h-4" />
                                Надано: {new Date(access.granted_at).toLocaleDateString('uk-UA')}
                              </span>
                              {access.expires_at && (
                                <span className="flex items-center gap-1">
                                  <Clock className="w-4 h-4" />
                                  Діє до: {new Date(access.expires_at).toLocaleDateString('uk-UA')}
                                </span>
                              )}
                              {!access.expires_at && (
                                <span className="text-green-400">Безстроковий доступ</span>
                              )}
                            </div>
                          </div>
                          <button
                            onClick={() => revokeCourseAccess(access.id)}
                            className="p-2 bg-red-500/20 hover:bg-red-500/30 text-red-400 rounded-lg transition-all"
                            title="Відкликати доступ"
                          >
                            <Trash2 className="w-5 h-5" />
                          </button>
                        </div>
                      </div>
                    );
                  })}
              </div>
            </div>
          )}

          {/* Logs Tab */}
          {activeTab === 'logs' && (
            <div>
              <h3 className="text-xl font-bold text-white mb-4">Історія дій адміністратора</h3>
              <div className="space-y-3">
                {adminLogs.map((log) => {
                  const actionIcons: Record<string, JSX.Element> = {
                    grant_access: <CheckCircle className="w-5 h-5 text-green-400" />,
                    revoke_access: <XCircle className="w-5 h-5 text-red-400" />,
                    password_reset: <Shield className="w-5 h-5 text-blue-400" />,
                  };

                  return (
                    <div
                      key={log.id}
                      className="bg-gray-700/30 rounded-xl p-4 border border-gray-600/50"
                    >
                      <div className="flex items-start gap-3">
                        <div className="flex-shrink-0">
                          {actionIcons[log.action] || <AlertCircle className="w-5 h-5 text-gray-400" />}
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-1">
                            <span className="text-white font-semibold capitalize">
                              {log.action.replace('_', ' ')}
                            </span>
                            <span className="text-gray-400 text-sm">
                              {new Date(log.created_at).toLocaleString('uk-UA')}
                            </span>
                          </div>
                          {log.target_user_email && (
                            <p className="text-gray-400 text-sm">
                              Користувач: {log.target_user_email}
                            </p>
                          )}
                          {log.details && (
                            <pre className="mt-2 text-xs text-gray-500 bg-gray-800/50 rounded p-2 overflow-x-auto">
                              {JSON.stringify(log.details, null, 2)}
                            </pre>
                          )}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
