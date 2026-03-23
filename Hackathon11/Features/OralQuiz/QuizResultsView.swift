// QuizResultsView.swift
// EchoStudy
// A11Y: Quiz results summary

import SwiftUI
import SwiftData

struct QuizResultsView: View {
    let session: QuizSession
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var scorePercentage: Int {
        guard session.totalQuestions > 0 else { return 0 }
        return Int(Double(session.score) / Double(session.totalQuestions) * 100)
    }
    
    private var scoreColor: Color {
        if scorePercentage >= 80 { return ColorTheme.successHex }
        if scorePercentage >= 50 { return ColorTheme.warningHex }
        return ColorTheme.errorHex
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Score
                    VStack(spacing: 12) {
                        Text("\(session.score)/\(session.totalQuestions)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor)
                        
                        Text("\(scorePercentage)% correcto")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        
                        Text(scoreMessage)
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .glassEffect(in: .rect(cornerRadius: 24))
                    .padding(.horizontal)
                    
                    // MARK: - Question Review
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Revisión de respuestas")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(session.questions) { question in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: question.isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(question.isCorrect == true ? ColorTheme.successHex : ColorTheme.errorHex)
                                    
                                    Text(question.questionText)
                                        .font(FontTheme.subheadline)
                                        .foregroundStyle(ColorTheme.adaptiveText)
                                        .lineLimit(2)
                                }
                                
                                if question.isCorrect != true {
                                    Text("Respuesta correcta: \(question.correctAnswer)")
                                        .font(FontTheme.caption)
                                        .foregroundStyle(ColorTheme.successHex)
                                }
                            }
                            .padding(12)
                            .glassEffect(in: .rect(cornerRadius: 12))
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(question.isCorrect == true ? "Correcta" : "Incorrecta"). \(question.questionText)")
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Actions
                    Button("Cerrar") {
                        modelContext.insert(session)
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Resultados")
            .announceOnAppear("Resultado del quiz: \(session.score) de \(session.totalQuestions) correctas. \(scorePercentage) por ciento.")
        }
        .onAppear {
            voiceEngine.speak(
                "Resultado del quiz: \(session.score) de \(session.totalQuestions) correctas. \(scoreMessage)",
                priority: .high
            )
        }
    }
    
    private var scoreMessage: String {
        if scorePercentage >= 80 { return "¡Excelente trabajo! Dominas bien estos temas." }
        if scorePercentage >= 50 { return "Buen intento. Repasa los temas donde fallaste." }
        return "Necesitas repasar estos temas. No te desanimes, la práctica hace al maestro."
    }
}
