import { useState, useEffect } from 'react';
import { useAuthStore } from '../store/authStore';
import { supabase } from '../lib/supabase';
import { useSearchParams } from 'react-router-dom';
import { 
  Upload, 
  CheckCircle, 
  XCircle, 
  Clock,
  AlertCircle,
  FileText,
  Image as ImageIcon,
  Send
} from 'lucide-react';
import { courses } from '../data/courses';

interface AccessRequest {
  id: string;
  course_id: string;
  status: 'pending' | 'approved' | 'rejected';
  payment_proof_url: string | null;
  user_message: string | null;
  admin_response: string | null;
  created_at: string;
  updated_at: string;
  reviewed_at: string | null;
}

export default function RequestAccess() {
  const { user } = useAuthStore();
  const [searchParams] = useSearchParams();
  const [selectedCourse, setSelectedCourse] = useState('');
  const [message, setMessage] = useState('');
  const [paymentProof, setPaymentProof] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [myRequests, setMyRequests] = useState<AccessRequest[]>([]);

  const paidCourses = courses.filter(c => c.price > 0);

  useEffect(() => {
    // Автоматично вибрати курс з URL параметра
    const courseParam = searchParams.get('course');
    if (courseParam && paidCourses.some(c => c.id === courseParam)) {
      setSelectedCourse(courseParam);
    }
  }, [searchParams, paidCourses]);

  useEffect(() => {
    if (user) {
      loadMyRequests();
    }
  }, [user]);

  const loadMyRequests = async () => {
    try {
      const { data, error } = await supabase.rpc('get_my_access_requests');
      if (error) throw error;
      setMyRequests(data || []);
    } catch (err: any) {
      console.error('Error loading requests:', err);
    }
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Перевірка типу файлу
    if (!file.type.startsWith('image/')) {
      setError('Будь ласка, завантажте зображення (JPG, PNG)');
      return;
    }

    // Перевірка розміру (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      setError('Файл занадто великий. Максимум 5MB');
      return;
    }

    setPaymentProof(file);
    setError('');
  };

  const uploadPaymentProof = async (): Promise<string | null> => {
    if (!paymentProof || !user) return null;

    setUploading(true);
    try {
      const fileExt = paymentProof.name.split('.').pop();
      const fileName = `${user.id}/${Date.now()}.${fileExt}`;

      const { error: uploadError } = await supabase.storage
        .from('payment-proofs')
        .upload(fileName, paymentProof);

      if (uploadError) throw uploadError;

      const { data } = supabase.storage
        .from('payment-proofs')
        .getPublicUrl(fileName);

      return data.publicUrl;
    } catch (err: any) {
      setError('Помилка завантаження файлу: ' + err.message);
      return null;
    } finally {
      setUploading(false);
    }
  };

  const submitRequest = async () => {
    if (!selectedCourse) {
      setError('Виберіть курс');
      return;
    }

    if (!paymentProof) {
      setError('Завантажте скріншот оплати');
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      // Завантажуємо скріншот
      const proofUrl = await uploadPaymentProof();
      if (!proofUrl) {
        setLoading(false);
        return;
      }

      // Створюємо запит
      const { data, error } = await supabase.rpc('create_access_request', {
        p_course_id: selectedCourse,
        p_payment_proof_url: proofUrl,
        p_user_message: message || null
      });

      if (error) throw error;

      const result = data as { success: boolean; message: string };
      
      if (result.success) {
        setSuccess('Запит надіслано! Очікуйте підтвердження від адміністратора');
        setSelectedCourse('');
        setMessage('');
        setPaymentProof(null);
        await loadMyRequests();
      } else {
        setError(result.message);
      }
    } catch (err: any) {
      setError(err.message || 'Помилка при створенні запиту');
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return (
          <span className="flex items-center gap-2 px-4 py-2 bg-yellow-500/20 border border-yellow-500/30 text-yellow-400 rounded-full">
            <Clock className="w-4 h-4" />
            Очікує розгляду
          </span>
        );
      case 'approved':
        return (
          <span className="flex items-center gap-2 px-4 py-2 bg-green-500/20 border border-green-500/30 text-green-400 rounded-full">
            <CheckCircle className="w-4 h-4" />
            Схвалено
          </span>
        );
      case 'rejected':
        return (
          <span className="flex items-center gap-2 px-4 py-2 bg-red-500/20 border border-red-500/30 text-red-400 rounded-full">
            <XCircle className="w-4 h-4" />
            Відхилено
          </span>
        );
    }
  };

  if (!user) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black flex items-center justify-center">
        <div className="text-white text-xl">Увійдіть для подачі запиту</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black py-12 px-4">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-white mb-2">Запит на доступ до курсу</h1>
        <p className="text-gray-400 mb-8">
          Оберіть курс, завантажте скріншот оплати та надішліть запит. 
          Адміністратор розгляне його протягом 24 годин.
        </p>

        {/* Alerts */}
        {error && (
          <div className="mb-6 p-4 bg-red-500/10 border border-red-500/30 rounded-xl flex items-start gap-3">
            <AlertCircle className="w-6 h-6 text-red-400 flex-shrink-0 mt-0.5" />
            <p className="text-red-300">{error}</p>
          </div>
        )}

        {success && (
          <div className="mb-6 p-4 bg-green-500/10 border border-green-500/30 rounded-xl flex items-start gap-3">
            <CheckCircle className="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" />
            <p className="text-green-300">{success}</p>
          </div>
        )}

        {/* Form */}
        <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl p-8 border border-gray-700 mb-8">
          <h2 className="text-2xl font-bold text-white mb-6">Новий запит</h2>

          {/* Course Selection */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Оберіть курс *
            </label>
            <select
              value={selectedCourse}
              onChange={(e) => setSelectedCourse(e.target.value)}
              className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
            >
              <option value="">Виберіть курс...</option>
              {paidCourses.map((course) => (
                <option key={course.id} value={course.id}>
                  {course.title} - ${course.price}
                </option>
              ))}
            </select>
          </div>

          {/* Payment Proof Upload */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Скріншот оплати *
            </label>
            <div className="border-2 border-dashed border-gray-600 rounded-xl p-6 text-center hover:border-minecraft-emerald/50 transition-all">
              <input
                type="file"
                accept="image/*"
                onChange={handleFileSelect}
                className="hidden"
                id="payment-proof"
              />
              <label htmlFor="payment-proof" className="cursor-pointer">
                {paymentProof ? (
                  <div className="flex items-center justify-center gap-3">
                    <ImageIcon className="w-8 h-8 text-minecraft-emerald" />
                    <div className="text-left">
                      <p className="text-white font-semibold">{paymentProof.name}</p>
                      <p className="text-gray-400 text-sm">
                        {(paymentProof.size / 1024 / 1024).toFixed(2)} MB
                      </p>
                    </div>
                  </div>
                ) : (
                  <div>
                    <Upload className="w-12 h-12 text-gray-400 mx-auto mb-3" />
                    <p className="text-white font-semibold mb-1">Завантажити скріншот</p>
                    <p className="text-gray-400 text-sm">JPG, PNG (макс. 5MB)</p>
                  </div>
                )}
              </label>
            </div>
            <p className="text-gray-400 text-sm mt-2">
              Завантажте скріншот підтвердження оплати (переказ, чек, тощо)
            </p>
          </div>

          {/* Message */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Повідомлення (опціонально)
            </label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Додаткова інформація про оплату..."
              rows={3}
              className="w-full px-4 py-3 bg-gray-700/50 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
            />
          </div>

          {/* Submit Button */}
          <button
            onClick={submitRequest}
            disabled={loading || uploading || !selectedCourse || !paymentProof}
            className="w-full flex items-center justify-center gap-2 px-6 py-4 bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond text-white font-bold rounded-xl hover:shadow-lg hover:shadow-minecraft-emerald/20 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading || uploading ? (
              <>
                <Clock className="w-5 h-5 animate-spin" />
                {uploading ? 'Завантаження...' : 'Надсилання...'}
              </>
            ) : (
              <>
                <Send className="w-5 h-5" />
                Надіслати запит
              </>
            )}
          </button>
        </div>

        {/* My Requests */}
        <div>
          <h2 className="text-2xl font-bold text-white mb-4">Мої запити</h2>
          <div className="space-y-4">
            {myRequests.length === 0 ? (
              <div className="bg-gray-800/50 rounded-xl p-8 text-center border border-gray-700">
                <FileText className="w-12 h-12 text-gray-500 mx-auto mb-3" />
                <p className="text-gray-400">У вас ще немає запитів</p>
              </div>
            ) : (
              myRequests.map((request) => {
                const course = courses.find(c => c.id === request.course_id);
                
                return (
                  <div
                    key={request.id}
                    className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-6 border border-gray-700"
                  >
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h3 className="text-xl font-bold text-white mb-2">
                          {course?.title || request.course_id}
                        </h3>
                        <p className="text-gray-400 text-sm">
                          Надіслано: {new Date(request.created_at).toLocaleString('uk-UA')}
                        </p>
                      </div>
                      {getStatusBadge(request.status)}
                    </div>

                    {request.user_message && (
                      <div className="mb-4">
                        <p className="text-gray-400 text-sm mb-1">Ваше повідомлення:</p>
                        <p className="text-white">{request.user_message}</p>
                      </div>
                    )}

                    {request.payment_proof_url && (
                      <div className="mb-4">
                        <a
                          href={request.payment_proof_url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex items-center gap-2 text-minecraft-emerald hover:text-minecraft-diamond transition-colors"
                        >
                          <ImageIcon className="w-4 h-4" />
                          Переглянути скріншот оплати
                        </a>
                      </div>
                    )}

                    {request.admin_response && (
                      <div className="mt-4 p-4 bg-gray-700/30 rounded-lg border border-gray-600">
                        <p className="text-gray-400 text-sm mb-1">Відповідь адміністратора:</p>
                        <p className="text-white">{request.admin_response}</p>
                        {request.reviewed_at && (
                          <p className="text-gray-500 text-xs mt-2">
                            {new Date(request.reviewed_at).toLocaleString('uk-UA')}
                          </p>
                        )}
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
