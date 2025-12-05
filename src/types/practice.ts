export interface PracticeTask {
  id: string;
  title: string;
  description: string;
  taskType: 'file-edit' | 'command' | 'config' | 'quiz' | 'troubleshoot';
  difficulty: 'easy' | 'medium' | 'hard';
  estimatedTime: number; // в хвилинах
  hints: string[];
  solution?: string;
  validation?: {
    type: 'exact' | 'contains' | 'regex';
    expectedOutput: string;
  };
}

export interface FileEditTask extends PracticeTask {
  taskType: 'file-edit';
  file: {
    path: string;
    initialContent: string;
    targetContent: string;
  };
}

export interface CommandTask extends PracticeTask {
  taskType: 'command';
  expectedCommand: string;
  explanation: string;
}

export interface ConfigTask extends PracticeTask {
  taskType: 'config';
  configFile: string;
  parameters: {
    name: string;
    expectedValue: string;
    explanation: string;
  }[];
}

export interface TroubleshootTask extends PracticeTask {
  taskType: 'troubleshoot';
  problem: string;
  symptoms: string[];
  possibleCauses: string[];
  correctSolution: string;
}

export interface PracticeLesson extends Lesson {
  type: 'practice';
  tasks: PracticeTask[];
  requiredTasksToPass: number; // Скільки завдань потрібно виконати
}

export interface PracticeProgress {
  lessonId: string;
  completedTasks: string[];
  attemptsPerTask: Record<string, number>;
  hintsUsed: Record<string, number>;
  startedAt: Date;
  completedAt?: Date;
}

import { Lesson } from './lesson';
