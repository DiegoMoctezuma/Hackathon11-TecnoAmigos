// QuizFeedbackView.swift
// EchoStudy
// A11Y: Immediate feedback after each quiz answer

import SwiftUI
import SwiftData

struct QuizFeedbackView: View {
    let isCorrect: Bool
    let question: QuizQuestion
    var onNext: () -> Void
    var onDeepenTopic: (() -> Void)?
    
    @Environment(VoiceEngine.self) private var voiceEngine
    
    private var feedbackColor: Color {
        isCorrect ? ColorTheme.successHex : ColorTheme.errorHex
    }
    
    private var feedbackIcon: String {
        isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    private var feedbackTitle: String {
        isCorrect ? "¡Correcto!" : "Incorrecto"
    }
    
    private var narrationText: String {
        if isCorrect {
            return "Correcto. \(question.explanation)"
        } else {
            return "Incorrecto. La respuesta correcta es: \(question.correctAnswer). \(question.explanation)"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Result Header
            HStack(spacing: 12) {
                Image(systemName: feedbackIcon)
                    .font(.system(size: 36))
                    .foregroundStyle(feedbackColor)
                    .symbolEffect(.bounce, value: isCorrect)
                
                Text(feedbackTitle)
                    .font(FontTheme.title2)
                    .foregroundStyle(feedbackColor)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isCorrect ? "Respuesta correcta" : "Respuesta incorrecta")
            
            // MARK: - Correct Answer (if wrong)
            if !isCorrect {
                VStack(alignment: .leading, spacing: 8) {
                    Text("La respuesta correcta es:")
                        .font(FontTheme.subheadline)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    
                    Text(question.correctAnswer)
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(feedbackColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // MARK: - Explanation
            if !question.explanation.isEmpty {
                Text(question.explanation)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // MARK: - Feedback Collector (compact)
            FeedbackCollectorView(
                predictionId: question.id.uuidString,
                predictionType: "quiz_question"
            )
            
            // MARK: - Action Buttons
            VStack(spacing: 10) {
                Button {
                    onNext()
                } label: {
                    HStack {
                        Text("Siguiente pregunta")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityLabel("Siguiente pregunta")
                
                if let onDeepenTopic {
                    Button {
                        onDeepenTopic()
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("Profundizar en este tema")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityLabel("Profundizar en este tema")
                }
            }
        }
        .padding(20)
        .background(feedbackColor.opacity(0.05))
        .glassEffect(in: .rect(cornerRadius: 24))
        .onAppear {
            if isCorrect {
                HapticService.shared.success()
            } else {
                HapticService.shared.error()
            }
            voiceEngine.speak(narrationText, priority: .high)
        }
        .accessibilityElement(children: .contain)
    }
}
