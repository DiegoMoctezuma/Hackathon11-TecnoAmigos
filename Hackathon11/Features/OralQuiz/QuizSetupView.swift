// QuizSetupView.swift
// EchoStudy
// A11Y: Quiz configuration screen

import SwiftUI
import SwiftData

struct QuizSetupView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @Query(sort: \Subject.name) private var subjects: [Subject]
    @State private var viewModel = OralQuizViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.system(size: 48))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(ColorTheme.accentHex)
                        .accessibilityHidden(true)
                    
                    Text("Quiz oral")
                        .font(FontTheme.title2)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Autoevaluación por voz. La IA pregunta, tú respondes.")
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // MARK: - Subject Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Selecciona una materia")
                        .font(FontTheme.title3)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    if subjects.isEmpty {
                        EmptyStateView(
                            iconName: "books.vertical",
                            title: "Sin materias",
                            message: "Primero sube material de estudio para crear materias y temas"
                        )
                    } else {
                        ForEach(subjects) { subject in
                            Button {
                                HapticService.shared.selection()
                                viewModel.selectedSubject = subject
                                viewModel.selectedTopics = subject.topics
                            } label: {
                                HStack(spacing: 12) {
                                    SubjectIcon(iconName: subject.iconName, colorHex: subject.colorHex)
                                    
                                    VStack(alignment: .leading) {
                                        Text(subject.name)
                                            .font(FontTheme.headline)
                                            .foregroundStyle(ColorTheme.adaptiveText)
                                        Text("\(subject.topics.count) temas")
                                            .font(FontTheme.subheadline)
                                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedSubject?.id == subject.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(ColorTheme.successHex)
                                    }
                                }
                                .padding(12)
                                .glassEffect(in: .rect(cornerRadius: 16))
                            }
                            .accessibilityLabel("\(subject.name). \(subject.topics.count) temas")
                            .accessibilityAddTraits(viewModel.selectedSubject?.id == subject.id ? .isSelected : [])
                        }
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Question Count
                if viewModel.selectedSubject != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Número de preguntas: \(viewModel.questionCount)")
                            .font(FontTheme.headline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        
                        Stepper("", value: $viewModel.questionCount, in: 3...20)
                            .accessibilityLabel("Número de preguntas: \(viewModel.questionCount)")
                            .accessibilityHint("Usa más o menos para ajustar")
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Start Button
                    Button {
                        HapticService.shared.heavy()
                        Task { await viewModel.startQuiz() }
                    } label: {
                        Text("Comenzar quiz")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .accessibilityHint("Inicia el quiz oral con \(viewModel.questionCount) preguntas")
                }
            }
            .padding(.vertical)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Quiz")
        .fullScreenCover(isPresented: $viewModel.isQuizActive) {
            QuizSessionView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showResults) {
            if let session = viewModel.currentSession {
                QuizResultsView(session: session)
            }
        }
        .announceOnAppear("Quiz oral. Selecciona una materia para comenzar.")
    }
}
