import { useState } from 'react';
import { PracticeTask, FileEditTask, CommandTask, ConfigTask, TroubleshootTask } from '../types/practice';
import { 
  CheckCircle, 
  XCircle, 
  Lightbulb, 
  Code, 
  Terminal, 
  FileText, 
  AlertCircle,
  ChevronRight,
  ChevronDown
} from 'lucide-react';

interface PracticeViewProps {
  tasks: PracticeTask[];
  lessonId: string;
  courseId: string;
  onComplete: () => void;
}

export default function PracticeView({ tasks, onComplete }: PracticeViewProps) {
  const [currentTaskIndex, setCurrentTaskIndex] = useState(0);
  const [completedTasks, setCompletedTasks] = useState<Set<string>>(new Set());
  const [userAnswer, setUserAnswer] = useState('');
  const [showHint, setShowHint] = useState(false);
  const [hintIndex, setHintIndex] = useState(0);
  const [showSolution, setShowSolution] = useState(false);
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const currentTask = tasks[currentTaskIndex];
  const progress = (completedTasks.size / tasks.length) * 100;

  const getTaskIcon = (taskType: string) => {
    switch (taskType) {
      case 'file-edit': return <FileText className="text-purple-400" />;
      case 'command': return <Terminal className="text-blue-400" />;
      case 'config': return <Code className="text-emerald-400" />;
      case 'troubleshoot': return <AlertCircle className="text-orange-400" />;
      default: return <Code className="text-gray-400" />;
    }
  };

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'easy': return 'text-minecraft-emerald';
      case 'medium': return 'text-minecraft-gold';
      case 'hard': return 'text-red-400';
      default: return 'text-gray-400';
    }
  };

  const validateAnswer = () => {
    if (!userAnswer.trim()) {
      setFeedback({ type: 'error', message: 'Введіть вашу відповідь' });
      return;
    }

    let isCorrect = false;

    if (currentTask.validation) {
      const { type, expectedOutput } = currentTask.validation;
      
      switch (type) {
        case 'exact':
          isCorrect = userAnswer.trim() === expectedOutput.trim();
          break;
        case 'contains':
          isCorrect = userAnswer.toLowerCase().includes(expectedOutput.toLowerCase());
          break;
        case 'regex':
          isCorrect = new RegExp(expectedOutput).test(userAnswer);
          break;
      }
    }

    if (isCorrect) {
      setFeedback({ type: 'success', message: 'Правильно! Завдання виконано!' });
      setCompletedTasks(new Set([...completedTasks, currentTask.id]));
      
      // Автоматично перейти до наступного завдання через 2 секунди
      setTimeout(() => {
        if (currentTaskIndex < tasks.length - 1) {
          handleNextTask();
        } else {
          onComplete();
        }
      }, 2000);
    } else {
      setFeedback({ 
        type: 'error', 
        message: 'Неправильно. Спробуйте ще раз або скористайтеся підказкою.' 
      });
    }
  };

  const handleNextTask = () => {
    if (currentTaskIndex < tasks.length - 1) {
      setCurrentTaskIndex(currentTaskIndex + 1);
      setUserAnswer('');
      setFeedback(null);
      setShowHint(false);
      setShowSolution(false);
      setHintIndex(0);
    }
  };

  const handlePreviousTask = () => {
    if (currentTaskIndex > 0) {
      setCurrentTaskIndex(currentTaskIndex - 1);
      setUserAnswer('');
      setFeedback(null);
      setShowHint(false);
      setShowSolution(false);
      setHintIndex(0);
    }
  };

  const showNextHint = () => {
    if (hintIndex < currentTask.hints.length - 1) {
      setHintIndex(hintIndex + 1);
    }
    setShowHint(true);
  };

  const renderTaskContent = () => {
    switch (currentTask.taskType) {
      case 'file-edit':
        const fileTask = currentTask as FileEditTask;
        return (
          <div className="space-y-4">
            <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
              <div className="flex items-center gap-2 mb-2">
                <FileText className="w-5 h-5 text-purple-400" />
                <span className="font-mono text-sm text-gray-300">{fileTask.file.path}</span>
              </div>
              <pre className="bg-gray-900 p-3 rounded text-sm overflow-x-auto">
                <code className="text-gray-300">{fileTask.file.initialContent}</code>
              </pre>
            </div>
            <p className="text-gray-400">
              Відредагуйте файл згідно з описом завдання і введіть оновлений вміст нижче:
            </p>
          </div>
        );

      case 'command':
        const cmdTask = currentTask as CommandTask;
        return (
          <div className="space-y-4">
            <div className="bg-gradient-to-br from-blue-500/10 to-blue-600/10 rounded-lg p-4 border border-blue-500/30">
              <div className="flex items-center gap-2 mb-2">
                <Terminal className="w-5 h-5 text-blue-400" />
                <span className="font-semibold text-blue-400">Командний рядок</span>
              </div>
              <p className="text-gray-300">{cmdTask.explanation}</p>
            </div>
            <p className="text-gray-400">
              Введіть команду, яку потрібно виконати для вирішення завдання:
            </p>
          </div>
        );

      case 'config':
        const configTask = currentTask as ConfigTask;
        return (
          <div className="space-y-4">
            <div className="bg-gradient-to-br from-emerald-500/10 to-emerald-600/10 rounded-lg p-4 border border-emerald-500/30">
              <div className="flex items-center gap-2 mb-2">
                <Code className="w-5 h-5 text-emerald-400" />
                <span className="font-mono text-sm text-emerald-400">{configTask.configFile}</span>
              </div>
              <div className="space-y-3 mt-3">
                {configTask.parameters.map((param, index) => (
                  <div key={index} className="bg-gray-800 rounded p-3">
                    <div className="font-mono text-minecraft-diamond mb-1">{param.name}</div>
                    <div className="text-sm text-gray-400">{param.explanation}</div>
                  </div>
                ))}
              </div>
            </div>
            <p className="text-gray-400">
              Напишіть правильну конфігурацію з усіма необхідними параметрами:
            </p>
          </div>
        );

      case 'troubleshoot':
        const troubleTask = currentTask as TroubleshootTask;
        return (
          <div className="space-y-4">
            <div className="bg-gradient-to-br from-orange-500/10 to-red-600/10 rounded-lg p-4 border border-orange-500/30">
              <div className="flex items-center gap-2 mb-3">
                <AlertCircle className="w-5 h-5 text-orange-400" />
                <span className="font-semibold text-orange-400">Проблема</span>
              </div>
              <p className="text-white mb-4">{troubleTask.problem}</p>
              
              <div className="mb-4">
                <h4 className="text-sm font-semibold text-gray-300 mb-2">Симптоми:</h4>
                <ul className="list-disc list-inside space-y-1">
                  {troubleTask.symptoms.map((symptom, index) => (
                    <li key={index} className="text-gray-400 text-sm">{symptom}</li>
                  ))}
                </ul>
              </div>

              <div>
                <h4 className="text-sm font-semibold text-gray-300 mb-2">Можливі причини:</h4>
                <ul className="list-disc list-inside space-y-1">
                  {troubleTask.possibleCauses.map((cause, index) => (
                    <li key={index} className="text-gray-400 text-sm">{cause}</li>
                  ))}
                </ul>
              </div>
            </div>
            <p className="text-gray-400">
              Опишіть, як ви вирішите цю проблему, крок за кроком:
            </p>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="space-y-6">
      {/* Progress Bar */}
      <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
        <div className="flex items-center justify-between mb-2">
          <span className="text-white font-semibold">Прогрес практики</span>
          <span className="text-minecraft-emerald font-bold">{Math.round(progress)}%</span>
        </div>
        <div className="w-full bg-gray-700 rounded-full h-3">
          <div
            className="bg-gradient-to-r from-minecraft-emerald to-minecraft-diamond h-3 rounded-full transition-all duration-500"
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className="text-sm text-gray-400 mt-2">
          {completedTasks.size} з {tasks.length} завдань виконано
        </div>
      </div>

      {/* Current Task */}
      <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl p-6 border border-gray-700">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-center gap-3">
            {getTaskIcon(currentTask.taskType)}
            <div>
              <h3 className="text-xl font-bold text-white mb-1">{currentTask.title}</h3>
              <div className="flex items-center gap-3 text-sm">
                <span className={`font-semibold ${getDifficultyColor(currentTask.difficulty)}`}>
                  {currentTask.difficulty === 'easy' && 'Легке'}
                  {currentTask.difficulty === 'medium' && 'Середнє'}
                  {currentTask.difficulty === 'hard' && 'Складне'}
                </span>
                <span className="text-gray-400">•</span>
                <span className="text-gray-400">~{currentTask.estimatedTime} хв</span>
              </div>
            </div>
          </div>
          
          {completedTasks.has(currentTask.id) && (
            <CheckCircle className="w-6 h-6 text-minecraft-emerald" />
          )}
        </div>

        <p className="text-gray-300 mb-6">{currentTask.description}</p>

        {renderTaskContent()}

        {/* Answer Input */}
        <div className="mt-6">
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Ваша відповідь:
          </label>
          <textarea
            value={userAnswer}
            onChange={(e) => setUserAnswer(e.target.value)}
            className="w-full h-32 bg-gray-900 border border-gray-700 rounded-lg p-3 text-white font-mono text-sm focus:border-minecraft-emerald focus:outline-none resize-none"
            placeholder="Введіть вашу відповідь тут..."
          />
        </div>

        {/* Feedback */}
        {feedback && (
          <div className={`mt-4 p-4 rounded-lg border flex items-center gap-3 ${
            feedback.type === 'success' 
              ? 'bg-emerald-500/10 border-emerald-500/30' 
              : 'bg-red-500/10 border-red-500/30'
          }`}>
            {feedback.type === 'success' ? (
              <CheckCircle className="w-5 h-5 text-emerald-400" />
            ) : (
              <XCircle className="w-5 h-5 text-red-400" />
            )}
            <span className={feedback.type === 'success' ? 'text-emerald-400' : 'text-red-400'}>
              {feedback.message}
            </span>
          </div>
        )}

        {/* Hints */}
        <div className="mt-6 space-y-3">
          {currentTask.hints.length > 0 && (
            <button
              onClick={showNextHint}
              disabled={hintIndex >= currentTask.hints.length - 1 && showHint}
              className="flex items-center gap-2 text-minecraft-gold hover:text-minecraft-gold/80 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Lightbulb className="w-5 h-5" />
              <span>
                {!showHint 
                  ? 'Показати підказку' 
                  : hintIndex < currentTask.hints.length - 1 
                    ? 'Показати наступну підказку' 
                    : 'Всі підказки показано'
                }
              </span>
            </button>
          )}

          {showHint && (
            <div className="bg-gradient-to-br from-yellow-500/10 to-orange-600/10 rounded-lg p-4 border border-yellow-500/30">
              <div className="flex items-start gap-2">
                <Lightbulb className="w-5 h-5 text-minecraft-gold flex-shrink-0 mt-0.5" />
                <div className="space-y-2">
                  {currentTask.hints.slice(0, hintIndex + 1).map((hint, index) => (
                    <p key={index} className="text-gray-300">
                      <span className="font-semibold text-minecraft-gold">Підказка {index + 1}:</span> {hint}
                    </p>
                  ))}
                </div>
              </div>
            </div>
          )}

          {currentTask.solution && (
            <button
              onClick={() => setShowSolution(!showSolution)}
              className="flex items-center gap-2 text-gray-400 hover:text-white transition-colors"
            >
              {showSolution ? <ChevronDown className="w-5 h-5" /> : <ChevronRight className="w-5 h-5" />}
              <span>{showSolution ? 'Сховати рішення' : 'Показати рішення'}</span>
            </button>
          )}

          {showSolution && currentTask.solution && (
            <div className="bg-gray-900 rounded-lg p-4 border border-gray-700">
              <h4 className="text-sm font-semibold text-minecraft-diamond mb-2">Правильне рішення:</h4>
              <pre className="text-sm text-gray-300 overflow-x-auto">
                <code>{currentTask.solution}</code>
              </pre>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex items-center justify-between mt-6 pt-6 border-t border-gray-700">
          <button
            onClick={handlePreviousTask}
            disabled={currentTaskIndex === 0}
            className="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Попереднє завдання
          </button>

          <div className="flex gap-3">
            <button
              onClick={validateAnswer}
              disabled={completedTasks.has(currentTask.id)}
              className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Перевірити
            </button>

            {currentTaskIndex < tasks.length - 1 && (
              <button
                onClick={handleNextTask}
                className="btn-secondary"
              >
                Наступне завдання
              </button>
            )}

            {currentTaskIndex === tasks.length - 1 && completedTasks.size === tasks.length && (
              <button
                onClick={onComplete}
                className="btn-primary"
              >
                Завершити практику
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Tasks Overview */}
      <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
        <h4 className="text-white font-semibold mb-3">Всі завдання:</h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {tasks.map((task, index) => (
            <button
              key={task.id}
              onClick={() => {
                setCurrentTaskIndex(index);
                setUserAnswer('');
                setFeedback(null);
                setShowHint(false);
                setShowSolution(false);
                setHintIndex(0);
              }}
              className={`flex items-center gap-3 p-3 rounded-lg border transition-all ${
                index === currentTaskIndex
                  ? 'bg-minecraft-emerald/10 border-minecraft-emerald/50'
                  : 'bg-gray-900 border-gray-700 hover:border-gray-600'
              }`}
            >
              {completedTasks.has(task.id) ? (
                <CheckCircle className="w-5 h-5 text-minecraft-emerald flex-shrink-0" />
              ) : (
                <div className="w-5 h-5 rounded-full border-2 border-gray-600 flex-shrink-0" />
              )}
              <div className="text-left">
                <div className="text-sm font-medium text-white">{task.title}</div>
                <div className="text-xs text-gray-400">{task.taskType}</div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
