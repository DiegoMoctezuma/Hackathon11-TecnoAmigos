// QuizSessionView.swift
// EchoStudy
// A11Y: Immersive full-screen quiz session with voice interaction

import SwiftUI

struct QuizSessionView: View {
    @Bindable var viewModel: OralQuizViewModel
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(\.dismiss) private var dismiss
    @State private var showExitConfirm = false
    @State private var showTextInput = false
    
    var body: some View {
        ZStack {
            // Background
            ColorTheme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Bar
                topBar
                
                // MARK: - Timer Bar
                if viewModel.timerEnabled {
                    timerBar
                }
                
                Spacer()
                
                // MARK: - Question Area
                if let question = viewModel.currentQuestion {
                    if viewModel.showFeedback {
                        QuizFeedbackView(
                            isCorrect: viewModel.currentFeedbackCorrect,
                            question: question,
                            onNext: {
                                HapticService.shared.medium()
                                viewModel.nextQuestion()
                            },
                            onDeepenTopic: nil
                        )
                        .padding(.horizontal)
                    } else {
                        questionCard(question)
                    }
                }
                
                Spacer()
                
                // MARK: - Answer Area
                if !viewModel.showFeedback {
                    answerArea
                }
            }
        }
        .statusBarHidden(true)
        .onAppear {
            setupVoiceCommands()
        }
        .alert("¿Salir del quiz?", isPresented: $showExitConfirm) {
            Button("Continuar quiz", role: .cancel) {}
            Button("Salir", role: .destructive) {
                voiceEngine.interrupt()
                viewModel.stopTimer()
                dismiss()
            }
        } message: {
            Text("Perderás el progreso de este quiz.")
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    showExitConfirm = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .accessibilityLabel("Salir del quiz")
                .accessibleTapTarget()
                
                Spacer()
                
                Text("Pregunta \(viewModel.currentQuestionIndex + 1) de \(viewModel.questions.count)")
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityLabel("Pregunta \(viewModel.currentQuestionIndex + 1) de \(viewModel.questions.count)")
                
                Spacer()
                
                // Placeholder for symmetry
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            
            ProgressView(value: viewModel.progress)
                .tint(ColorTheme.accentHex)
                .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Timer Bar
    
    private var timerBar: some View {
        GeometryReader { geo in
            let fraction = Double(viewModel.timerRemaining) / Double(viewModel.timerSeconds)
            let timerColor: Color = fraction > 0.5 ? ColorTheme.accentHex :
                                     fraction > 0.2 ? ColorTheme.warningHex : ColorTheme.errorHex
            
            Rectangle()
                .fill(timerColor)
                .frame(width: geo.size.width * fraction)
                .animation(.linear(duration: 1), value: viewModel.timerRemaining)
        }
        .frame(height: 4)
        .accessibilityLabel("Tiempo restante: \(viewModel.timerRemaining) segundos")
    }
    
    // MARK: - Question Card
    
    private func questionCard(_ question: QuizQuestion) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.bubble.fill")
                .font(.system(size: 44))
                .foregroundStyle(ColorTheme.accentHex)
                .symbolEffect(.pulse)
                .accessibilityHidden(true)
            
            Text(question.questionText)
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(24)
        .glassEffect(in: .rect(cornerRadius: 24))
        .padding(.horizontal)
        .onAppear {
            voiceEngine.speak(question.questionText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pregunta: \(question.questionText)")
    }
    
    // MARK: - Answer Area
    
    private var answerArea: some View {
        VStack(spacing: 12) {
            // Text input area (only when toggled)
            if showTextInput {
                HStack(spacing: 12) {
                    TextField("Escribe tu respuesta...", text: $viewModel.userAnswer)
                        .textFieldStyle(GlassTextFieldStyle())
                        .submitLabel(.send)
                        .onSubmit { submitCurrentAnswer() }
                        .accessibilityLabel("Tu respuesta escrita")
                    
                    Button {
                        submitCurrentAnswer()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(ColorTheme.accentHex)
                    }
                    .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("Enviar respuesta")
                    .accessibleTapTarget()
                }
            }
            
            // All controls in a single row inside the capsule
            HStack(spacing: 16) {
                // Keyboard/Mic toggle
                Button {
                    showTextInput.toggle()
                } label: {
                    Image(systemName: showTextInput ? "mic.fill" : "keyboard")
                        .font(.title3)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(showTextInput ? "Cambiar a entrada por voz" : "Cambiar a entrada por texto")
                
                // Repeat button
                Button {
                    HapticService.shared.light()
                    if let q = viewModel.currentQuestion {
                        voiceEngine.speak(q.questionText, priority: .immediate)
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Repetir pregunta")
                
                // Main voice button (center, larger)
                VoiceButton(state: voiceEngine.state, size: 60) {
                    toggleListening()
                }
                
                // Skip button
                Button {
                    HapticService.shared.light()
                    viewModel.skipQuestion()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Saltar pregunta")
                
                // Send button
                Button {
                    submitCurrentAnswer()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.userAnswer.isEmpty ? ColorTheme.adaptiveTextSecondary : ColorTheme.accentHex)
                        .frame(width: 44, height: 44)
                }
                .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityLabel("Enviar respuesta")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
        .glassEffect(in: .capsule)
    }
    
    // MARK: - Actions
    
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
        let answer = viewModel.userAnswer.trimmingCharacters(in: .whitespaces)
        guard !answer.isEmpty else { return }
        viewModel.submitAnswer(answer)
        HapticService.shared.medium()
    }
    
    private func setupVoiceCommands() {
        voiceEngine.onCommandDetected = { command in
            switch command {
            case .repeatLast:
                if let q = viewModel.currentQuestion {
                    voiceEngine.speak(q.questionText, priority: .immediate)
                }
            case .pause: voiceEngine.pause()
            case .resume: voiceEngine.continueSpeaking()
            case .next: viewModel.skipQuestion()
            case .stop:
                voiceEngine.interrupt()
                showExitConfirm = true
            default: break
            }
        }
    }
}
