// QuizSetupView.swift
// EchoStudy
// A11Y: 4-step quiz configuration screen

import SwiftUI
import SwiftData

struct QuizSetupView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @Query(sort: \Subject.name) private var subjects: [Subject]
    @State private var viewModel = OralQuizViewModel()
    
    private let questionPresets = [5, 10, 15, 20]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Step Indicator
            stepIndicator
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.bubble.fill")
                            .font(.system(size: 48))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(ColorTheme.accentHex)
                            .accessibilityHidden(true)
                        
                        Text("Modo repaso")
                            .font(FontTheme.title2)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(viewModel.currentStep.title)
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Step Content
                    switch viewModel.currentStep {
                    case .selectSubject:
                        subjectSelectionStep
                    case .selectTopics:
                        topicSelectionStep
                    case .questionCount:
                        questionCountStep
                    case .difficulty:
                        difficultyStep
                    }
                }
                .padding(.vertical)
            }
            
            // MARK: - Bottom Navigation
            bottomNavigation
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Quiz")
        .fullScreenCover(isPresented: $viewModel.isQuizActive) {
            QuizSessionView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showResults) {
            if let session = viewModel.currentSession {
                QuizResultsView(session: session, viewModel: viewModel)
            }
        }
        .announceOnAppear("Modo repaso. Configura tu quiz.")
    }
    
    // MARK: - Step Indicator
    
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(QuizSetupStep.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue
                          ? ColorTheme.accentHex
                          : ColorTheme.adaptiveTextSecondary.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Paso \(viewModel.currentStep.rawValue + 1) de \(QuizSetupStep.allCases.count)")
    }
    
    // MARK: - Step 1: Subject Selection
    
    private var subjectSelectionStep: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                        viewModel.selectSubject(subject)
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
                                    .font(.title3)
                            }
                        }
                        .padding(14)
                        .frame(minHeight: 48)
                        .glassEffect(in: .rect(cornerRadius: 16))
                    }
                    .accessibilityLabel("\(subject.name). \(subject.topics.count) temas")
                    .accessibilityAddTraits(viewModel.selectedSubject?.id == subject.id ? .isSelected : [])
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Step 2: Topic Selection
    
    private var topicSelectionStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Select All
            Button {
                HapticService.shared.selection()
                viewModel.toggleAllTopics()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.allTopicsSelected ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(viewModel.allTopicsSelected ? ColorTheme.accentHex : ColorTheme.adaptiveTextSecondary)
                    
                    Text("Todos los temas")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    
                    Spacer()
                    
                    Text("\(viewModel.selectedSubject?.topics.count ?? 0) temas")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .padding(14)
                .frame(minHeight: 48)
                .glassEffect(in: .rect(cornerRadius: 16))
            }
            .accessibilityLabel("Todos los temas")
            .accessibilityValue(viewModel.allTopicsSelected ? "Seleccionado" : "No seleccionado")
            .accessibilityAddTraits(viewModel.allTopicsSelected ? .isSelected : [])
            
            // Individual topics
            if let topics = viewModel.selectedSubject?.topics {
                ForEach(topics) { topic in
                    Button {
                        HapticService.shared.selection()
                        viewModel.toggleTopic(topic)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.selectedTopics.contains(topic) ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundStyle(viewModel.selectedTopics.contains(topic) ? ColorTheme.accentHex : ColorTheme.adaptiveTextSecondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(topic.title)
                                    .font(FontTheme.body)
                                    .foregroundStyle(ColorTheme.adaptiveText)
                                
                                if !topic.shortSummary.isEmpty {
                                    Text(topic.shortSummary)
                                        .font(FontTheme.caption)
                                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(14)
                        .frame(minHeight: 48)
                        .glassEffect(in: .rect(cornerRadius: 16))
                    }
                    .accessibilityLabel(topic.title)
                    .accessibilityValue(viewModel.selectedTopics.contains(topic) ? "Seleccionado" : "No seleccionado")
                    .accessibilityAddTraits(viewModel.selectedTopics.contains(topic) ? .isSelected : [])
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Step 3: Question Count
    
    private var questionCountStep: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.questionCount)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(ColorTheme.accentHex)
                .accessibilityHidden(true)
            
            Text("preguntas")
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .accessibilityHidden(true)
            
            // Preset buttons
            HStack(spacing: 12) {
                ForEach(questionPresets, id: \.self) { preset in
                    Button {
                        HapticService.shared.selection()
                        viewModel.questionCount = preset
                    } label: {
                        Text("\(preset)")
                            .font(FontTheme.headline)
                            .foregroundStyle(viewModel.questionCount == preset
                                             ? .white
                                             : ColorTheme.adaptiveText)
                            .frame(width: 56, height: 56)
                            .background(
                                viewModel.questionCount == preset
                                ? AnyShapeStyle(ColorTheme.accentHex)
                                : AnyShapeStyle(Color.clear)
                            )
                            .glassEffect(in: .rect(cornerRadius: 16))
                    }
                    .accessibilityLabel("\(preset) preguntas")
                    .accessibilityAddTraits(viewModel.questionCount == preset ? .isSelected : [])
                }
            }
            
            // Stepper for fine control
            Stepper("Ajustar: \(viewModel.questionCount) preguntas",
                    value: $viewModel.questionCount, in: 3...30)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveText)
                .padding(14)
                .glassEffect(in: .rect(cornerRadius: 16))
                .accessibilityLabel("Número de preguntas: \(viewModel.questionCount)")
                .accessibilityHint("Usa más o menos para ajustar")
        }
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Número de preguntas: \(viewModel.questionCount)")
    }
    
    // MARK: - Step 4: Difficulty
    
    private var difficultyStep: some View {
        VStack(spacing: 20) {
            // Segmented picker
            Picker("Dificultad", selection: $viewModel.difficulty) {
                ForEach(QuizDifficulty.allCases) { diff in
                    Text(diff.rawValue).tag(diff)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .accessibilityLabel("Nivel de dificultad")
            .onChange(of: viewModel.difficulty) { _, _ in
                HapticService.shared.selection()
            }
            
            // Description
            VStack(spacing: 12) {
                Image(systemName: difficultyIcon)
                    .font(.system(size: 48))
                    .foregroundStyle(difficultyColor)
                    .symbolEffect(.bounce, value: viewModel.difficulty)
                    .accessibilityHidden(true)
                
                Text(difficultyDescription)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .glassEffect(in: .rect(cornerRadius: 20))
            .padding(.horizontal)
            
            // Timer toggle
            Toggle(isOn: $viewModel.timerEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Timer por pregunta")
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    Text("60 segundos para responder cada pregunta")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
            }
            .padding(14)
            .glassEffect(in: .rect(cornerRadius: 16))
            .padding(.horizontal)
            .accessibilityLabel("Timer por pregunta")
            .accessibilityValue(viewModel.timerEnabled ? "Activado" : "Desactivado")
            
            // Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Resumen del quiz")
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityAddTraits(.isHeader)
                
                HStack {
                    Label(viewModel.selectedSubject?.name ?? "", systemImage: "book.fill")
                    Spacer()
                }
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                HStack {
                    Label("\(viewModel.selectedTopics.count) temas", systemImage: "list.bullet")
                    Spacer()
                }
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                HStack {
                    Label("\(viewModel.questionCount) preguntas", systemImage: "number")
                    Spacer()
                }
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                HStack {
                    Label(viewModel.difficulty.rawValue, systemImage: "gauge.medium")
                    Spacer()
                }
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 16))
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
        }
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigation: some View {
        HStack(spacing: 12) {
            if viewModel.currentStep != .selectSubject {
                Button {
                    HapticService.shared.light()
                    viewModel.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(FontTheme.headline)
                }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityLabel("Paso anterior")
            }
            
            if viewModel.isLastSetupStep {
                Button {
                    HapticService.shared.heavy()
                    Task { await viewModel.startQuiz() }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Comenzar quiz")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityHint("Inicia el quiz oral con \(viewModel.questionCount) preguntas de nivel \(viewModel.difficulty.rawValue)")
            } else {
                Button {
                    HapticService.shared.medium()
                    viewModel.nextStep()
                } label: {
                    HStack {
                        Text("Siguiente")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!viewModel.canProceedToNextStep)
                .accessibilityHint("Avanzar al siguiente paso de configuración")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .glassEffect()
    }
    
    // MARK: - Difficulty Helpers
    
    private var difficultyIcon: String {
        switch viewModel.difficulty {
        case .basic: return "gauge.open.with.lines.needle.33percent"
        case .intermediate: return "gauge.open.with.lines.needle.50percent"
        case .advanced: return "gauge.open.with.lines.needle.84percent"
        }
    }
    
    private var difficultyColor: Color {
        switch viewModel.difficulty {
        case .basic: return ColorTheme.successHex
        case .intermediate: return ColorTheme.accentHex
        case .advanced: return ColorTheme.errorHex
        }
    }
    
    private var difficultyDescription: String {
        switch viewModel.difficulty {
        case .basic: return "Preguntas sencillas de comprensión y recuerdo. Ideal para un primer repaso."
        case .intermediate: return "Preguntas que requieren análisis y relación entre conceptos."
        case .advanced: return "Preguntas de aplicación, síntesis y evaluación crítica."
        }
    }
}
