import { createClient } from '@supabase/supabase-js';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from '../config/supabase';

// Використовуємо placeholder якщо змінні не встановлені
const supabaseUrl = SUPABASE_URL || 'https://placeholder.supabase.co';
const supabaseKey = SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsYWNlaG9sZGVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDUxOTI4MDAsImV4cCI6MTk2MDc2ODgwMH0.placeholder';

export const supabase = createClient(supabaseUrl, supabaseKey);

export interface Purchase {
  id: string;
  user_id: string;
  course_id: string;
  purchase_date: string;
  payment_provider?: string;
  transaction_id?: string;
  amount?: number;
  currency: string;
  status: 'completed' | 'refunded' | 'pending';
  created_at: string;
  updated_at: string;
}

export interface CourseLesson {
  id: string;
  course_id: string;
  module_id: string;
  lesson_id: string;
  title: string;
  duration: string;
  type: 'video' | 'text' | 'quiz' | 'practice';
  content: string;
  video_url?: string;
  quiz_data?: any;
  practice_data?: any;
  order_index: number;
  is_free_preview: boolean;
  created_at: string;
  updated_at: string;
}

export interface CourseModule {
  id: string;
  course_id: string;
  module_id: string;
  title: string;
  description?: string;
  order_index: number;
  created_at: string;
  updated_at: string;
}

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name: string | null;
          avatar_url: string | null;
          role?: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          full_name?: string | null;
          avatar_url?: string | null;
          role?: string;
        };
        Update: {
          full_name?: string | null;
          avatar_url?: string | null;
          role?: string;
        };
      };
      course_progress: {
        Row: {
          id: string;
          user_id: string;
          course_id: string;
          completed_lessons: string[];
          quiz_scores: Record<string, number>;
          progress: number;
          started_at: string;
          last_accessed_at: string;
          completed: boolean;
          completed_at: string | null;
        };
        Insert: {
          user_id: string;
          course_id: string;
          completed_lessons?: string[];
          quiz_scores?: Record<string, number>;
          progress?: number;
        };
        Update: {
          completed_lessons?: string[];
          quiz_scores?: Record<string, number>;
          progress?: number;
          last_accessed_at?: string;
          completed?: boolean;
          completed_at?: string | null;
        };
      };
      certificates: {
        Row: {
          id: string;
          user_id: string;
          course_id: string;
          course_name: string;
          issue_date: string;
          certificate_url: string | null;
        };
        Insert: {
          user_id: string;
          course_id: string;
          course_name: string;
        };
        Update: {
          certificate_url?: string | null;
        };
      };
      purchases: {
        Row: Purchase;
        Insert: Omit<Purchase, 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Omit<Purchase, 'id' | 'user_id' | 'course_id' | 'created_at' | 'updated_at'>>;
      };
      course_lessons: {
        Row: CourseLesson;
        Insert: Omit<CourseLesson, 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Omit<CourseLesson, 'id' | 'course_id' | 'lesson_id' | 'created_at' | 'updated_at'>>;
      };
      course_modules: {
        Row: CourseModule;
        Insert: Omit<CourseModule, 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Omit<CourseModule, 'id' | 'course_id' | 'module_id' | 'created_at' | 'updated_at'>>;
      };
    };
  };
}
