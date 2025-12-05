export interface Lesson {
  id: string;
  title: string;
  duration: string;
  type: 'video' | 'text' | 'quiz' | 'practice';
  content: string;
  videoUrl?: string;
  codeExamples?: CodeExample[];
  quiz?: Quiz;
  completed?: boolean;
}

export interface CodeExample {
  id: string;
  title: string;
  language: string;
  code: string;
  explanation: string;
}

export interface Quiz {
  id: string;
  questions: QuizQuestion[];
}

export interface QuizQuestion {
  id: string;
  question: string;
  options: string[];
  correctAnswer: number;
  explanation: string;
}

export interface CourseModule {
  id: string;
  title: string;
  description: string;
  lessons: Lesson[];
  order: number;
}

export interface CourseProgress {
  courseId: string;
  userId: string;
  completedLessons: string[];
  quizScores: { [lessonId: string]: number };
  progress: number;
  startedAt: Date;
  lastAccessedAt: Date;
  completed?: boolean;
  completedAt?: Date;
}

export interface Certificate {
  id: string;
  userId: string;
  courseId: string;
  courseName: string;
  userName: string;
  issueDate: Date;
  certificateUrl?: string;
}
