// QuizResultsView.swift
// EchoStudy
// A11Y: Quiz results summary with reinforcement topics and trends

import SwiftUI
import SwiftData

struct QuizResultsView: View {
    let session: QuizSession
    @Bindable var viewModel: OralQuizViewModel
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var hasSaved = false
    
    @Query(sort: \QuizSession.completedAt, order: .reverse) private var pastSessions: [QuizSession]
    
    private var scorePercentage: Int {
        guard session.totalQuestions > 0 else { return 0 }
        return Int(Double(session.score) / Double(session.totalQuestions) * 100)
    }
    
    private var scoreColor: Color {
        if scorePercentage >= 80 { return ColorTheme.successHex }
        if scorePercentage >= 50 { return ColorTheme.warningHex }
        return ColorTheme.errorHex
    }
    
    private var previousScore: Int? {
        guard pastSessions.count > 1 else { return nil }
        let prev = pastSessions[1]
        guard prev.totalQuestions > 0 else { return nil }
        return Int(Double(prev.score) / Double(prev.totalQuestions) * 100)
    }
    
    private var trendText: String {
        guard let prev = previousScore else { return "" }
        let diff = scorePercentage - prev
        if diff > 0 { return "↑ \(diff)% mejor que tu quiz anterior" }
        if diff < 0 { return "↓ \(abs(diff))% menos que tu quiz anterior" }
        return "→ Igual que tu quiz anterior"
    }
    
    private var incorrectQuestions: [QuizQuestion] {
        session.questions.filter { $0.isCorrect != true }
    }
    
    private var correctQuestions: [QuizQuestion] {
        session.questions.filter { $0.isCorrect == true }
    }
    
    private var fullNarration: String {
        var text = "Completaste el quiz. Tu puntuación: \(session.score) de \(session.totalQuestions), \(scorePercentage) por ciento. "
        if !viewModel.masteredTopics.isEmpty {
            text += "Temas dominados: \(viewModel.masteredTopics.map(\.title).joined(separator: ", ")). "
        }
        if !viewModel.topicsToReinforce.isEmpty {
            text += "Temas a reforzar: \(viewModel.topicsToReinforce.map(\.title).joined(separator: ", "))."
        }
        return text
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Score Card
                    VStack(spacing: 12) {
                        Text("\(session.score)/\(session.totalQuestions)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor)
                        
                        Text("\(scorePercentage)% correcto")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        
                        Text(scoreMessage)
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                        
                        // Trend
                        if !trendText.isEmpty {
                            Text(trendText)
                                .font(FontTheme.subheadline)
                                .foregroundStyle(previousScore.map { scorePercentage >= $0 ? ColorTheme.successHex : ColorTheme.errorHex } ?? ColorTheme.adaptiveTextSecondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(24)
                    .glassEffect(in: .rect(cornerRadius: 24))
                    .padding(.horizontal)
                    
                    // MARK: - Topics to Reinforce
                    if !viewModel.topicsToReinforce.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Temas a reforzar")
                                .font(FontTheme.title3)
                                .foregroundStyle(ColorTheme.adaptiveText)
                                .accessibilityAddTraits(.isHeader)
                            
                            ForEach(viewModel.topicsToReinforce) { topic in
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(ColorTheme.warningHex)
                                        .accessibilityHidden(true)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(topic.title)
                                            .font(FontTheme.headline)
                                            .foregroundStyle(ColorTheme.adaptiveText)
                                        Text(topic.shortSummary)
                                            .font(FontTheme.caption)
                                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        HapticService.shared.light()
                                        dismiss()
                                        router.push(.topicDetail(topic))
                                    } label: {
                                        Text("Ir al tema")
                                            .font(FontTheme.caption)
                                            .foregroundStyle(ColorTheme.accentHex)
                                    }
                                    .accessibilityLabel("Ir al tema \(topic.title)")
                                }
                                .padding(12)
                                .glassEffect(in: .rect(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Mastered Topics
                    if !viewModel.masteredTopics.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Temas dominados")
                                .font(FontTheme.title3)
                                .foregroundStyle(ColorTheme.adaptiveText)
                                .accessibilityAddTraits(.isHeader)
                            
                            ForEach(viewModel.masteredTopics) { topic in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(ColorTheme.successHex)
                                        .accessibilityHidden(true)
                                    
                                    Text(topic.title)
                                        .font(FontTheme.body)
                                        .foregroundStyle(ColorTheme.adaptiveText)
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .glassEffect(in: .rect(cornerRadius: 12))
                                .accessibilityLabel("Tema dominado: \(topic.title)")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
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
                    VStack(spacing: 12) {
                        Button {
                            HapticService.shared.heavy()
                            viewModel.resetForRepeatQuiz()
                            dismiss()
                            Task { await viewModel.startQuiz() }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Repetir quiz")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button {
                            HapticService.shared.medium()
                            viewModel.resetForNewQuiz()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Nuevo quiz")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Resultados")
            .announceOnAppear("Resultado del quiz: \(session.score) de \(session.totalQuestions) correctas. \(scorePercentage) por ciento.")
        }
        .onAppear {
            saveSession()
            voiceEngine.speak(fullNarration, priority: .high)
        }
    }
    
    private func saveSession() {
        guard !hasSaved else { return }
        hasSaved = true
        modelContext.insert(session)
    }
    
    private var scoreMessage: String {
        if scorePercentage >= 80 { return "¡Excelente trabajo! Dominas bien estos temas." }
        if scorePercentage >= 50 { return "Buen intento. Repasa los temas donde fallaste." }
        return "Necesitas repasar estos temas. No te desanimes, la práctica hace al maestro."
    }
}
