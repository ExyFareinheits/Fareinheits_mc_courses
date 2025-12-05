import { Lesson } from '../types/lesson';
import { CheckCircle, Clock, Code } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism';

interface LessonViewProps {
  lesson: Lesson;
  onComplete: () => void;
  isCompleted: boolean;
}

export default function LessonView({ lesson, onComplete, isCompleted }: LessonViewProps) {
  return (
    <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl border border-gray-700 overflow-hidden">
      {/* Header */}
      <div className="bg-gradient-to-r from-minecraft-emerald/10 to-minecraft-diamond/10 border-b border-gray-700 p-6">
        <div className="flex items-start justify-between max-w-6xl mx-auto">
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-2">
              {isCompleted && (
                <div className="w-10 h-10 rounded-full bg-minecraft-emerald/20 flex items-center justify-center">
                  <CheckCircle className="text-minecraft-emerald" size={20} />
                </div>
              )}
              <h2 className="text-2xl md:text-3xl font-bold text-white">{lesson.title}</h2>
            </div>
            <div className="flex flex-wrap items-center gap-4">
              <div className="flex items-center gap-2 bg-gray-800/50 px-4 py-2 rounded-lg">
                <Clock size={18} className="text-minecraft-diamond" />
                <span className="text-sm font-medium text-gray-300">{lesson.duration}</span>
              </div>
              {isCompleted && (
                <div className="flex items-center gap-2 bg-minecraft-emerald/20 px-4 py-2 rounded-lg">
                  <CheckCircle size={18} className="text-minecraft-emerald" />
                  <span className="text-sm font-semibold text-minecraft-emerald">Урок завершено</span>
                </div>
              )}
              {lesson.type === 'video' && (
                <div className="flex items-center gap-2 bg-red-500/20 px-4 py-2 rounded-lg">
                  <span className="text-sm font-semibold text-red-400">🎥 Відео урок</span>
                </div>
              )}
              {lesson.type === 'text' && (
                <div className="flex items-center gap-2 bg-blue-500/20 px-4 py-2 rounded-lg">
                  <span className="text-sm font-semibold text-blue-400">📖 Текстовий урок</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="py-8 px-4 md:px-6">
        <div className="max-w-none">
          {/* Video */}
          {lesson.videoUrl && (
            <div className="mb-8 rounded-xl overflow-hidden">
              <iframe
                src={lesson.videoUrl}
                className="w-full aspect-video"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              ></iframe>
            </div>
          )}

          {/* Text Content */}
          <div className="prose prose-invert prose-lg max-w-none mb-8">
          <ReactMarkdown
            components={{
              code({ className, children, ...props }: any) {
                const match = /language-(\w+)/.exec(className || '');
                const inline = !className;
                return !inline && match ? (
                  <SyntaxHighlighter
                    style={vscDarkPlus as any}
                    language={match[1]}
                    PreTag="div"
                    className="rounded-xl my-6"
                    customStyle={{ fontSize: '15px', padding: '24px' }}
                    {...props}
                  >
                    {String(children).replace(/\n$/, '')}
                  </SyntaxHighlighter>
                ) : (
                  <code className="bg-gray-800 px-2.5 py-1 rounded text-minecraft-emerald font-mono text-base" {...props}>
                    {children}
                  </code>
                );
              },
              h1: ({ children }) => (
                <h1 className="text-4xl lg:text-5xl font-bold text-white mb-6 mt-10 first:mt-0">{children}</h1>
              ),
              h2: ({ children }) => (
                <h2 className="text-3xl lg:text-4xl font-bold text-white mb-4 mt-10">{children}</h2>
              ),
              h3: ({ children }) => (
                <h3 className="text-2xl lg:text-3xl font-bold text-minecraft-emerald mb-4 mt-8">{children}</h3>
              ),
              p: ({ children }) => (
                <p className="text-gray-200 text-lg lg:text-xl leading-relaxed mb-6">{children}</p>
              ),
              ul: ({ children }) => (
                <ul className="list-disc list-outside text-gray-200 space-y-3 mb-6 ml-8 pl-2 text-lg">{children}</ul>
              ),
              ol: ({ children }) => (
                <ol className="list-decimal list-outside text-gray-200 space-y-3 mb-6 ml-8 pl-2 text-lg">{children}</ol>
              ),
              li: ({ children }) => (
                <li className="text-gray-200 leading-relaxed">{children}</li>
              ),
              table: ({ children }) => (
                <div className="overflow-x-auto mb-8">
                  <table className="min-w-full border border-gray-700 rounded-lg overflow-hidden">
                    {children}
                  </table>
                </div>
              ),
              thead: ({ children }) => (
                <thead className="bg-gray-800">{children}</thead>
              ),
              tbody: ({ children }) => (
                <tbody className="bg-gray-900/50">{children}</tbody>
              ),
              tr: ({ children }) => (
                <tr className="border-b border-gray-700">{children}</tr>
              ),
              th: ({ children }) => (
                <th className="px-6 py-3 text-left text-minecraft-emerald font-semibold text-base">
                  {children}
                </th>
              ),
              td: ({ children }) => (
                <td className="px-6 py-3 text-gray-200 text-base">{children}</td>
              ),
              blockquote: ({ children }) => (
                <blockquote className="border-l-4 border-minecraft-emerald bg-minecraft-emerald/5 pl-6 py-3 italic text-gray-300 my-6 text-lg">
                  {children}
                </blockquote>
              ),
            }}
          >
            {lesson.content}
          </ReactMarkdown>
        </div>

          {/* Code Examples */}
          {lesson.codeExamples && lesson.codeExamples.length > 0 && (
            <div className="space-y-6 mb-10">
              <h3 className="text-3xl font-bold text-white flex items-center gap-3">
                <Code className="text-minecraft-diamond" size={32} />
                Приклади коду
              </h3>
              {lesson.codeExamples.map((example) => (
                <div
                  key={example.id}
                  className="bg-gray-900/50 rounded-xl border border-gray-700 overflow-hidden"
                >
                  <div className="bg-gray-800/50 px-6 py-4 border-b border-gray-700">
                    <h4 className="text-xl font-semibold text-minecraft-emerald">
                      {example.title}
                    </h4>
                  </div>
                  <SyntaxHighlighter
                    language={example.language}
                    style={vscDarkPlus}
                    customStyle={{ margin: 0, borderRadius: 0, fontSize: '15px', padding: '24px' }}
                  >
                    {example.code}
                  </SyntaxHighlighter>
                  <div className="px-6 py-4 bg-gray-800/30 border-t border-gray-700">
                    <p className="text-gray-300 text-base leading-relaxed">{example.explanation}</p>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Complete Button */}
          <div className="flex justify-center pt-8 border-t border-gray-700">
            {!isCompleted ? (
              <button 
                onClick={onComplete} 
                className="btn-primary flex items-center gap-2 px-8 py-4 text-lg shadow-lg transform hover:scale-105 transition-all"
              >
                <CheckCircle size={24} />
                Позначити як завершене
              </button>
            ) : (
              <div className="flex flex-col items-center gap-4 bg-minecraft-emerald/10 rounded-xl p-8 border-2 border-minecraft-emerald/30 w-full max-w-xl mx-auto">
                <div className="w-16 h-16 rounded-full bg-minecraft-emerald/20 flex items-center justify-center mb-2">
                  <CheckCircle className="text-minecraft-emerald" size={40} />
                </div>
                <div className="text-center">
                  <h3 className="text-2xl font-bold text-minecraft-emerald mb-1">Урок завершено!</h3>
                  <p className="text-gray-400">Чудова робота! Переходьте до наступного уроку.</p>
                </div>
                <button 
                  onClick={onComplete} 
                  className="btn-secondary flex items-center gap-2 mt-2"
                >
                  <CheckCircle size={20} />
                  Переглянути ще раз
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
