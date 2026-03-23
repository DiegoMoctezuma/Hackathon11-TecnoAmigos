// QuizSessionView.swift
// EchoStudy
// A11Y: Active quiz session with voice interaction

import SwiftUI

struct QuizSessionView: View {
    @Bindable var viewModel: OralQuizViewModel
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // MARK: - Progress
                VStack(spacing: 8) {
                    ProgressView(value: Double(viewModel.currentQuestionIndex), total: Double(viewModel.questions.count))
                        .tint(ColorTheme.accentHex)
                    
                    Text("Pregunta \(viewModel.currentQuestionIndex + 1) de \(viewModel.questions.count)")
                        .font(FontTheme.subheadline)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .accessibilityLabel("Pregunta \(viewModel.currentQuestionIndex + 1) de \(viewModel.questions.count)")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Question
                if let question = viewModel.currentQuestion {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.bubble.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(ColorTheme.accentHex)
                            .accessibilityHidden(true)
                        
                        Text(question.questionText)
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(20)
                    .glassEffect(in: .rect(cornerRadius: 24))
                    .padding(.horizontal)
                    .announceOnAppear(question.questionText)
                    .onAppear {
                        voiceEngine.speak(question.questionText)
                    }
                    
                    // MARK: - Feedback
                    if viewModel.showFeedback {
                        QuizAnswerFeedback(
                            isCorrect: viewModel.currentFeedbackCorrect,
                            explanation: question.explanation,
                            correctAnswer: question.correctAnswer
                        )
                        .padding(.horizontal)
                        
                        Button("Siguiente") {
                            HapticService.shared.medium()
                            viewModel.nextQuestion()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityLabel("Siguiente pregunta")
                    } else {
                        // MARK: - Answer Input
                        VStack(spacing: 12) {
                            TextField("Tu respuesta...", text: $viewModel.userAnswer)
                                .textFieldStyle(GlassTextFieldStyle())
                                .submitLabel(.done)
                                .onSubmit { submitCurrentAnswer() }
                                .accessibilityLabel("Tu respuesta")
                                .accessibilityHint("Escribe tu respuesta o usa el botón de micrófono")
                            
                            HStack(spacing: 16) {
                                VoiceButton(state: voiceEngine.state, size: 48) {
                                    toggleListening()
                                }
                                
                                Button("Enviar respuesta") {
                                    submitCurrentAnswer()
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Quiz en curso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Salir") {
                        voiceEngine.interrupt()
                        dismiss()
                    }
                    .accessibilityLabel("Salir del quiz")
                }
            }
        }
        .onAppear {
            voiceEngine.onCommandDetected = { command in
                switch command {
                case .repeatLast: voiceEngine.repeatLast()
                case .pause: voiceEngine.pause()
                case .next: viewModel.nextQuestion()
                default: break
                }
            }
        }
    }
    
    private func toggleListening() {
        if voiceEngine.state == .listening {
            voiceEngine.stopListening()
            if !voiceEngine.transcribedText.isEmpty {
                viewModel.userAnswer = voiceEngine.transcribedText
                submitCurrentAnswer()
            }
        } else {
            voiceEngine.startListening()
        }
    }
    
    private func submitCurrentAnswer() {
        guard !viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.submitAnswer(viewModel.userAnswer)
        HapticService.shared.medium()
    }
}
