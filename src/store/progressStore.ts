import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { CourseProgress } from '../types/lesson';
import { supabase } from '../lib/supabase';

interface ProgressState {
  progresses: { [courseId: string]: CourseProgress };
  loading: boolean;
  markLessonComplete: (courseId: string, lessonId: string, userId?: string) => Promise<void>;
  saveQuizScore: (courseId: string, lessonId: string, score: number, userId?: string) => Promise<void>;
  getCourseProgress: (courseId: string) => CourseProgress | undefined;
  resetProgress: (courseId: string) => void;
  completeCourse: (courseId: string, userId?: string) => Promise<void>;
  syncProgressFromDB: (userId: string) => Promise<void>;
}

export const useProgressStore = create<ProgressState>()(
  persist(
    (set, get) => ({
      progresses: {},
      loading: false,

      markLessonComplete: async (courseId: string, lessonId: string, userId?: string) => {
        set((state) => {
          const progress = state.progresses[courseId] || {
            courseId,
            userId: userId || 'guest',
            completedLessons: [],
            quizScores: {},
            progress: 0,
            startedAt: new Date(),
            lastAccessedAt: new Date(),
          };

          if (!progress.completedLessons.includes(lessonId)) {
            progress.completedLessons.push(lessonId);
          }
          progress.lastAccessedAt = new Date();

          return {
            progresses: {
              ...state.progresses,
              [courseId]: progress,
            },
          };
        });

        // Синхронізація з Supabase
        if (userId) {
          try {
            const progress = get().progresses[courseId];
            await supabase
              .from('course_progress')
              .upsert({
                user_id: userId,
                course_id: courseId,
                completed_lessons: progress.completedLessons,
                quiz_scores: progress.quizScores,
                progress: Math.round((progress.completedLessons.length / 10) * 100),
                last_accessed_at: new Date().toISOString(),
              });
          } catch (error) {
            console.warn('Failed to sync lesson completion:', error);
          }
        }
      },

      saveQuizScore: async (courseId: string, lessonId: string, score: number, userId?: string) => {
        set((state) => {
          const progress = state.progresses[courseId] || {
            courseId,
            userId: userId || 'guest',
            completedLessons: [],
            quizScores: {},
            progress: 0,
            startedAt: new Date(),
            lastAccessedAt: new Date(),
          };

          progress.quizScores[lessonId] = score;
          progress.lastAccessedAt = new Date();

          return {
            progresses: {
              ...state.progresses,
              [courseId]: progress,
            },
          };
        });

        // Синхронізація з Supabase
        if (userId) {
          try {
            const progress = get().progresses[courseId];
            await supabase
              .from('course_progress')
              .upsert({
                user_id: userId,
                course_id: courseId,
                completed_lessons: progress.completedLessons,
                quiz_scores: progress.quizScores,
                progress: Math.round((progress.completedLessons.length / 10) * 100),
                last_accessed_at: new Date().toISOString(),
              });
          } catch (error) {
            console.warn('Failed to sync quiz score:', error);
          }
        }
      },

      getCourseProgress: (courseId: string) => {
        return get().progresses[courseId];
      },

      resetProgress: (courseId: string) => {
        set((state) => {
          const newProgresses = { ...state.progresses };
          delete newProgresses[courseId];
          return { progresses: newProgresses };
        });
      },

      completeCourse: async (courseId: string, userId?: string) => {
        set((state) => {
          const progress = state.progresses[courseId];
          if (progress) {
            progress.completed = true;
            progress.completedAt = new Date();
            progress.progress = 100;
          }
          return {
            progresses: {
              ...state.progresses,
              [courseId]: progress,
            },
          };
        });

        // Синхронізація з Supabase і створення сертифіката
        if (userId) {
          try {
            const progress = get().progresses[courseId];
            await supabase
              .from('course_progress')
              .upsert({
                user_id: userId,
                course_id: courseId,
                completed_lessons: progress.completedLessons,
                quiz_scores: progress.quizScores,
                progress: 100,
                completed: true,
                completed_at: new Date().toISOString(),
                last_accessed_at: new Date().toISOString(),
              });

            // Створення сертифіката
            await supabase
              .from('certificates')
              .insert({
                user_id: userId,
                course_id: courseId,
                course_name: courseId,
              });
          } catch (error) {
            console.warn('Failed to complete course in Supabase:', error);
          }
        }
      },

      syncProgressFromDB: async (userId: string) => {
        set({ loading: true });
        try {
          const { data, error } = await supabase
            .from('course_progress')
            .select('*')
            .eq('user_id', userId);

          if (error) throw error;

          if (data) {
            const progresses: { [courseId: string]: CourseProgress } = {};
            data.forEach((item) => {
              progresses[item.course_id] = {
                courseId: item.course_id,
                userId: item.user_id,
                completedLessons: item.completed_lessons,
                quizScores: item.quiz_scores,
                progress: item.progress,
                startedAt: new Date(item.started_at),
                lastAccessedAt: new Date(item.last_accessed_at),
                completed: item.completed,
                completedAt: item.completed_at ? new Date(item.completed_at) : undefined,
              };
            });
            set({ progresses, loading: false });
          }
        } catch (error) {
          console.error('Error syncing progress:', error);
          set({ loading: false });
        }
      },
    }),
    {
      name: 'course-progress-storage',
    }
  )
);
