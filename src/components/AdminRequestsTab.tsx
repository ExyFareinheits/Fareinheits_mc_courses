import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import {
  CheckCircle,
  XCircle,
  Clock,
  Image as ImageIcon,
  FileText,
  AlertCircle
} from 'lucide-react';
import { courses } from '../data/courses';

interface AccessRequest {
  id: string;
  user_id: string;
  user_email: string;
  course_id: string;
  status: 'pending' | 'approved' | 'rejected';
  payment_proof_url: string | null;
  user_message: string | null;
  admin_response: string | null;
  created_at: string;
  updated_at: string;
  reviewed_by: string | null;
  reviewed_at: string | null;
}

interface Props {
  onUpdate?: () => void;
}

export default function AdminRequestsTab({ onUpdate }: Props) {
  const [requests, setRequests] = useState<AccessRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('pending');
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [adminResponse, setAdminResponse] = useState<Record<string, string>>({});
  const [expiresInDays, setExpiresInDays] = useState<Record<string, number>>({});
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    loadRequests();
  }, [filter]);

  const loadRequests = async () => {
    setLoading(true);
    try {
      const statusFilter = filter === 'all' ? null : filter;
      const { data, error } = await supabase.rpc('admin_get_access_requests', {
        p_status: statusFilter
      });

      if (error) throw error;
      
      // data is JSONB array, parse it
      const requestsData = Array.isArray(data) ? data : (data ? JSON.parse(data as string) : []);
      setRequests(requestsData);
    } catch (err: any) {
      console.error('Error loading requests:', err);
      setError('Помилка завантаження запитів');
    } finally {
      setLoading(false);
    }
  };

  const approveRequest = async (requestId: string) => {
    if (!confirm('Схвалити запит та надати доступ до курсу?')) return;

    setProcessingId(requestId);
    setError('');
    setSuccess('');

    try {
      const response = adminResponse[requestId] || 'Оплата підтверджена. Доступ надано.';
      const days = expiresInDays[requestId] || 0;
      const expiresAt = days > 0
        ? new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString()
        : null;

      const { data, error } = await supabase.rpc('admin_approve_request', {
        p_request_id: requestId,
        p_admin_response: response,
        p_expires_at: expiresAt
      });

      if (error) throw error;

      const result = data as { success: boolean; message: string };
      if (result.success) {
        setSuccess('Запит схвалено та доступ надано!');
        await loadRequests();
        onUpdate?.();
      } else {
        setError(result.message);
      }
    } catch (err: any) {
      setError(err.message || 'Помилка при схваленні запиту');
    } finally {
      setProcessingId(null);
    }
  };

  const rejectRequest = async (requestId: string) => {
    const response = adminResponse[requestId];
    if (!response) {
      setError('Введіть причину відхилення');
      return;
    }

    if (!confirm('Відхилити запит?')) return;

    setProcessingId(requestId);
    setError('');
    setSuccess('');

    try {
      const { data, error } = await supabase.rpc('admin_reject_request', {
        p_request_id: requestId,
        p_admin_response: response
      });

      if (error) throw error;

      const result = data as { success: boolean; message: string };
      if (result.success) {
        setSuccess('Запит відхилено');
        await loadRequests();
        onUpdate?.();
      } else {
        setError(result.message);
      }
    } catch (err: any) {
      setError(err.message || 'Помилка при відхиленні запиту');
    } finally {
      setProcessingId(null);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return (
          <span className="flex items-center gap-2 px-3 py-1 bg-yellow-500/20 border border-yellow-500/30 text-yellow-400 rounded-full text-sm">
            <Clock className="w-4 h-4" />
            Очікує
          </span>
        );
      case 'approved':
        return (
          <span className="flex items-center gap-2 px-3 py-1 bg-green-500/20 border border-green-500/30 text-green-400 rounded-full text-sm">
            <CheckCircle className="w-4 h-4" />
            Схвалено
          </span>
        );
      case 'rejected':
        return (
          <span className="flex items-center gap-2 px-3 py-1 bg-red-500/20 border border-red-500/30 text-red-400 rounded-full text-sm">
            <XCircle className="w-4 h-4" />
            Відхилено
          </span>
        );
    }
  };

  const pendingCount = requests.filter(r => r.status === 'pending').length;

  return (
    <div>
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

      {/* Filter Tabs */}
      <div className="flex gap-3 mb-6">
        <button
          onClick={() => setFilter('pending')}
          className={`px-4 py-2 rounded-lg font-medium transition-all ${
            filter === 'pending'
              ? 'bg-yellow-500/20 text-yellow-400 border border-yellow-500/30'
              : 'bg-gray-700/30 text-gray-400 hover:bg-gray-700/50'
          }`}
        >
          Очікують ({pendingCount})
        </button>
        <button
          onClick={() => setFilter('approved')}
          className={`px-4 py-2 rounded-lg font-medium transition-all ${
            filter === 'approved'
              ? 'bg-green-500/20 text-green-400 border border-green-500/30'
              : 'bg-gray-700/30 text-gray-400 hover:bg-gray-700/50'
          }`}
        >
          Схвалені
        </button>
        <button
          onClick={() => setFilter('rejected')}
          className={`px-4 py-2 rounded-lg font-medium transition-all ${
            filter === 'rejected'
              ? 'bg-red-500/20 text-red-400 border border-red-500/30'
              : 'bg-gray-700/30 text-gray-400 hover:bg-gray-700/50'
          }`}
        >
          Відхилені
        </button>
        <button
          onClick={() => setFilter('all')}
          className={`px-4 py-2 rounded-lg font-medium transition-all ${
            filter === 'all'
              ? 'bg-blue-500/20 text-blue-400 border border-blue-500/30'
              : 'bg-gray-700/30 text-gray-400 hover:bg-gray-700/50'
          }`}
        >
          Всі
        </button>
      </div>

      {/* Requests List */}
      {loading ? (
        <div className="text-center py-12">
          <Clock className="w-12 h-12 text-gray-400 mx-auto mb-4 animate-spin" />
          <p className="text-gray-400">Завантаження...</p>
        </div>
      ) : requests.length === 0 ? (
        <div className="bg-gray-700/30 rounded-xl p-12 text-center border border-gray-600/50">
          <FileText className="w-16 h-16 text-gray-500 mx-auto mb-4" />
          <p className="text-gray-400 text-lg">Немає запитів</p>
        </div>
      ) : (
        <div className="space-y-6">
          {requests.map((request) => {
            const course = courses.find(c => c.id === request.course_id);
            const isPending = request.status === 'pending';

            return (
              <div
                key={request.id}
                className="bg-gray-700/30 rounded-xl p-6 border border-gray-600/50 hover:border-minecraft-emerald/50 transition-all"
              >
                {/* Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-xl font-bold text-white">
                        {course?.title || request.course_id}
                      </h3>
                      {getStatusBadge(request.status)}
                    </div>
                    <div className="flex gap-4 text-sm text-gray-400">
                      <span>👤 {request.user_email}</span>
                      <span>📅 {new Date(request.created_at).toLocaleString('uk-UA')}</span>
                      {course && <span>💰 ${course.price}</span>}
                    </div>
                  </div>
                </div>

                {/* User Message */}
                {request.user_message && (
                  <div className="mb-4 p-3 bg-gray-800/50 rounded-lg">
                    <p className="text-gray-400 text-sm mb-1">Повідомлення користувача:</p>
                    <p className="text-white">{request.user_message}</p>
                  </div>
                )}

                {/* Payment Proof */}
                {request.payment_proof_url && (
                  <div className="mb-4">
                    <a
                      href={request.payment_proof_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 px-4 py-2 bg-minecraft-emerald/20 hover:bg-minecraft-emerald/30 border border-minecraft-emerald/30 text-minecraft-emerald rounded-lg transition-all"
                    >
                      <ImageIcon className="w-5 h-5" />
                      Переглянути скріншот оплати
                    </a>
                  </div>
                )}

                {/* Admin Response (if reviewed) */}
                {request.admin_response && (
                  <div className="mb-4 p-4 bg-blue-500/10 border border-blue-500/30 rounded-lg">
                    <p className="text-blue-400 text-sm mb-1">Відповідь адміністратора:</p>
                    <p className="text-white">{request.admin_response}</p>
                    {request.reviewed_at && (
                      <p className="text-gray-500 text-xs mt-2">
                        {new Date(request.reviewed_at).toLocaleString('uk-UA')}
                      </p>
                    )}
                  </div>
                )}

                {/* Action Panel (only for pending) */}
                {isPending && (
                  <div className="pt-4 border-t border-gray-600">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-300 mb-2">
                          Відповідь адміністратора
                        </label>
                        <textarea
                          value={adminResponse[request.id] || ''}
                          onChange={(e) => setAdminResponse({
                            ...adminResponse,
                            [request.id]: e.target.value
                          })}
                          placeholder="Оплата підтверджена. Доступ надано."
                          rows={2}
                          className="w-full px-3 py-2 bg-gray-700/50 border border-gray-600 rounded-lg text-white text-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
                        />
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-300 mb-2">
                          Термін дії (днів, 0 = безстроково)
                        </label>
                        <input
                          type="number"
                          min="0"
                          value={expiresInDays[request.id] || 0}
                          onChange={(e) => setExpiresInDays({
                            ...expiresInDays,
                            [request.id]: parseInt(e.target.value) || 0
                          })}
                          className="w-full px-3 py-2 bg-gray-700/50 border border-gray-600 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-minecraft-emerald/50"
                        />
                      </div>
                    </div>

                    <div className="flex gap-3">
                      <button
                        onClick={() => approveRequest(request.id)}
                        disabled={processingId === request.id}
                        className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-green-500 to-green-600 text-white font-bold rounded-xl hover:shadow-lg transition-all disabled:opacity-50"
                      >
                        <CheckCircle className="w-5 h-5" />
                        Схвалити
                      </button>

                      <button
                        onClick={() => rejectRequest(request.id)}
                        disabled={processingId === request.id}
                        className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-red-500 to-red-600 text-white font-bold rounded-xl hover:shadow-lg transition-all disabled:opacity-50"
                      >
                        <XCircle className="w-5 h-5" />
                        Відхилити
                      </button>
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
