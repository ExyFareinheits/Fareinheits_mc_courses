import { useState } from 'react';
import { Lesson, Quiz } from '../types/lesson';
import { useProgressStore } from '../store/progressStore';
import { useAuthStore } from '../store/authStore';
import { CheckCircle, XCircle, Award, RotateCcw } from 'lucide-react';

interface QuizViewProps {
  lesson: Lesson;
  quiz: Quiz;
  courseId: string;
  onComplete: () => void;
}

export default function QuizView({ lesson, quiz, courseId, onComplete }: QuizViewProps) {
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedAnswers, setSelectedAnswers] = useState<{ [key: number]: number }>({});
  const [showResults, setShowResults] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const { user } = useAuthStore();
  const { saveQuizScore } = useProgressStore();

  const question = quiz.questions[currentQuestion];
  const totalQuestions = quiz.questions.length;

  const handleSelectAnswer = (answerIndex: number) => {
    if (submitted) return;
    setSelectedAnswers({
      ...selectedAnswers,
      [currentQuestion]: answerIndex,
    });
  };

  const handleNext = () => {
    if (currentQuestion < totalQuestions - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSubmitted(false);
    }
  };

  const handlePrevious = () => {
    if (currentQuestion > 0) {
      setCurrentQuestion(currentQuestion - 1);
      setSubmitted(false);
    }
  };

  const handleSubmitAnswer = () => {
    setSubmitted(true);
  };

  const handleFinishQuiz = async () => {
    const correctAnswers = quiz.questions.filter(
      (q, index) => selectedAnswers[index] === q.correctAnswer
    ).length;
    const score = (correctAnswers / totalQuestions) * 100;

    await saveQuizScore(courseId, lesson.id, score, user?.id);
    
    if (score >= 70) {
      onComplete();
    }
    
    setShowResults(true);
  };

  const handleRetry = () => {
    setCurrentQuestion(0);
    setSelectedAnswers({});
    setShowResults(false);
    setSubmitted(false);
  };

  const isAnswerCorrect = () => {
    return selectedAnswers[currentQuestion] === question.correctAnswer;
  };

  const calculateScore = () => {
    const correctAnswers = quiz.questions.filter(
      (q, index) => selectedAnswers[index] === q.correctAnswer
    ).length;
    return (correctAnswers / totalQuestions) * 100;
  };

  if (showResults) {
    const score = calculateScore();
    const passed = score >= 70;

    return (
      <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl border border-gray-700 p-8">
        <div className="text-center space-y-6">
          <div className={`w-32 h-32 mx-auto rounded-full flex items-center justify-center ${passed ? 'bg-minecraft-emerald/20' : 'bg-red-500/20'}`}>
            {passed ? (
              <Award size={64} className="text-minecraft-emerald" />
            ) : (
              <XCircle size={64} className="text-red-500" />
            )}
          </div>

          <h2 className="text-4xl font-bold text-white">
            {passed ? 'Вітаємо! 🎉' : 'Спробуйте ще раз'}
          </h2>

          <div className="bg-gray-900/50 rounded-xl p-6 border border-gray-700 max-w-md mx-auto">
            <div className="text-5xl font-bold mb-2">
              <span className={passed ? 'text-minecraft-emerald' : 'text-red-500'}>
                {Math.round(score)}%
              </span>
            </div>
            <div className="text-gray-400">
              {quiz.questions.filter((q, index) => selectedAnswers[index] === q.correctAnswer).length} з {totalQuestions} правильних відповідей
            </div>
          </div>

          <p className="text-gray-300 max-w-lg mx-auto">
            {passed
              ? 'Ви успішно пройшли тест! Можете перейти до наступного уроку.'
              : 'Для проходження потрібно набрати мінімум 70%. Спробуйте ще раз!'}
          </p>

          <div className="flex gap-4 justify-center">
            <button onClick={handleRetry} className="btn-secondary flex items-center gap-2">
              <RotateCcw size={20} />
              Пройти ще раз
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl border border-gray-700">
      {/* Header */}
      <div className="bg-gradient-to-r from-minecraft-gold/10 to-minecraft-emerald/10 border-b border-gray-700 p-6">
        <h2 className="text-3xl font-bold text-white mb-2">{lesson.title}</h2>
        <div className="flex items-center gap-4">
          <div className="text-gray-400">
            Питання {currentQuestion + 1} з {totalQuestions}
          </div>
          <div className="flex-1 bg-gray-700 rounded-full h-2">
            <div
              className="bg-gradient-to-r from-minecraft-gold to-minecraft-emerald h-2 rounded-full transition-all"
              style={{ width: `${((currentQuestion + 1) / totalQuestions) * 100}%` }}
            ></div>
          </div>
        </div>
      </div>

      {/* Question */}
      <div className="p-8">
        <h3 className="text-2xl font-semibold text-white mb-6">{question.question}</h3>

        {/* Options */}
        <div className="space-y-3 mb-8">
          {question.options.map((option, index) => {
            const isSelected = selectedAnswers[currentQuestion] === index;
            const isCorrect = index === question.correctAnswer;
            const showCorrectAnswer = submitted && isCorrect;
            const showWrongAnswer = submitted && isSelected && !isCorrect;

            return (
              <button
                key={index}
                onClick={() => handleSelectAnswer(index)}
                disabled={submitted}
                className={`w-full p-4 rounded-xl border-2 transition-all text-left ${
                  showCorrectAnswer
                    ? 'border-minecraft-emerald bg-minecraft-emerald/10'
                    : showWrongAnswer
                    ? 'border-red-500 bg-red-500/10'
                    : isSelected
                    ? 'border-minecraft-diamond bg-minecraft-diamond/10'
                    : 'border-gray-700 bg-gray-800/50 hover:border-gray-600'
                } ${submitted ? 'cursor-not-allowed' : 'cursor-pointer'}`}
              >
                <div className="flex items-center justify-between">
                  <span className="text-white font-medium">{option}</span>
                  {submitted && (
                    <>
                      {showCorrectAnswer && <CheckCircle className="text-minecraft-emerald" size={24} />}
                      {showWrongAnswer && <XCircle className="text-red-500" size={24} />}
                    </>
                  )}
                </div>
              </button>
            );
          })}
        </div>

        {/* Explanation */}
        {submitted && (
          <div className={`p-4 rounded-xl border-2 mb-6 ${
            isAnswerCorrect()
              ? 'border-minecraft-emerald bg-minecraft-emerald/5'
              : 'border-red-500 bg-red-500/5'
          }`}>
            <div className="flex items-start gap-3">
              {isAnswerCorrect() ? (
                <CheckCircle className="text-minecraft-emerald flex-shrink-0 mt-1" size={24} />
              ) : (
                <XCircle className="text-red-500 flex-shrink-0 mt-1" size={24} />
              )}
              <div>
                <div className={`font-bold mb-1 ${
                  isAnswerCorrect() ? 'text-minecraft-emerald' : 'text-red-500'
                }`}>
                  {isAnswerCorrect() ? 'Правильно!' : 'Неправильно'}
                </div>
                <div className="text-gray-300">{question.explanation}</div>
              </div>
            </div>
          </div>
        )}

        {/* Navigation */}
        <div className="flex justify-between items-center pt-6 border-t border-gray-700">
          <button
            onClick={handlePrevious}
            disabled={currentQuestion === 0}
            className="px-6 py-3 rounded-xl bg-gray-800 text-white font-semibold disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-700 transition-colors"
          >
            Назад
          </button>

          <div className="flex gap-3">
            {!submitted ? (
              <button
                onClick={handleSubmitAnswer}
                disabled={selectedAnswers[currentQuestion] === undefined}
                className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Перевірити
              </button>
            ) : currentQuestion < totalQuestions - 1 ? (
              <button onClick={handleNext} className="btn-primary">
                Наступне питання
              </button>
            ) : (
              <button onClick={handleFinishQuiz} className="btn-primary flex items-center gap-2">
                <Award size={20} />
                Завершити тест
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
