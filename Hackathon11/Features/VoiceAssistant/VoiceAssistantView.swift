// VoiceAssistantView.swift
// EchoStudy
// A11Y: Voice-first assistant — NOT a text chat. Voice is primary.
// Layout: ContextIndicator, TranscriptionView, VoiceWaveform, VoiceButton, text fallback.

import SwiftUI
import SwiftData

struct VoiceAssistantView: View {
    var contextSubject: Subject? = nil
    var contextTopic: Topic? = nil
    
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = VoiceAssistantViewModel()
    @State private var textInput: String = ""
    @State private var showTextInput: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Context Indicator
                ContextIndicator(
                    subjectName: contextSubject?.name,
                    topicName: contextTopic?.title
                )
                .padding(.top, 8)
                
                // MARK: - Transcript Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                if message.role == .assistant, message.isGenerated {
                                    GeneratedContentView(
                                        content: message.content,
                                        onSave: {
                                            // Save generated content to subject/topic
                                        },
                                        onReadAgain: {
                                            voiceEngine.speak(message.content, priority: .immediate)
                                        }
                                    )
                                    .id(message.id)
                                } else {
                                    AssistantResponseCard(
                                        message: message,
                                        onReadAgain: {
                                            voiceEngine.speak(message.content, priority: .immediate)
                                        }
                                    )
                                    .id(message.id)
                                }
                            }
                            
                            if viewModel.isProcessing {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("Pensando...")
                                        .font(FontTheme.subheadline)
                                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .accessibilityLabel("Procesando tu mensaje")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // MARK: - Live Transcription
                if voiceEngine.state == .listening {
                    TranscriptionView(text: voiceEngine.transcribedText)
                }
                
                // MARK: - Waveform (driven by real mic input)
                VoiceWaveformView(
                    isActive: voiceEngine.state == .listening || voiceEngine.state == .speaking,
                    audioLevel: voiceEngine.audioLevel,
                    barCount: 7
                )
                .frame(height: 40)
                .padding(.vertical, 8)
                
                // MARK: - Input Area
                inputArea
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Asistente de voz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .accessibilityLabel("Cerrar asistente de voz")
                }
            }
        }
        .onAppear {
            viewModel.currentContext = buildContextString()
            voiceEngine.onCommandDetected = { command in
                handleCommand(command)
            }
            voiceEngine.speak("Asistente de ARGOS. ¿En qué puedo ayudarte?")
        }
        .announceOnAppear("Asistente de voz de ARGOS. Habla o escribe tu pregunta.")
    }
    
    // MARK: - Input Area
    
    private var inputArea: some View {
        VStack(spacing: 12) {
            // Text input toggle
            if showTextInput {
                HStack(spacing: 12) {
                    TextField("Escribe tu pregunta...", text: $textInput)
                        .font(FontTheme.body)
                        .padding(12)
                        .glassEffect(in: .rect(cornerRadius: 12))
                        .submitLabel(.send)
                        .onSubmit { sendTextMessage() }
                        .accessibilityLabel("Campo de mensaje")
                        .accessibilityHint("Escribe tu pregunta y envía")
                    
                    Button {
                        sendTextMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(ColorTheme.accentHex)
                    }
                    .accessibilityLabel("Enviar mensaje")
                    .accessibleTapTarget()
                }
                .padding(.horizontal)
            }
            
            // Voice + Write toggle
            HStack(spacing: 20) {
                // Write toggle
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showTextInput.toggle()
                    }
                    HapticService.shared.light()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showTextInput ? "mic.fill" : "keyboard")
                            .font(FontTheme.body)
                        Text(showTextInput ? "Hablar" : "Escribir")
                            .font(FontTheme.caption)
                    }
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glassEffect(in: .capsule)
                }
                .accessibilityLabel(showTextInput ? "Cambiar a entrada de voz" : "Cambiar a entrada de texto")
                
                // Voice button (main CTA) — ring reacts to real mic level
                VoiceButton(state: voiceEngine.state, audioLevel: voiceEngine.audioLevel, size: 64) {
                    toggleListening()
                }
                
                // Interrupt button (visible when speaking)
                if voiceEngine.state == .speaking {
                    Button {
                        voiceEngine.interrupt()
                        HapticService.shared.light()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "stop.fill")
                                .font(FontTheme.body)
                            Text("Parar")
                                .font(FontTheme.caption)
                        }
                        .foregroundStyle(ColorTheme.errorHex)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glassEffect(in: .capsule)
                    }
                    .accessibilityLabel("Interrumpir lectura")
                    .transition(.opacity)
                } else {
                    Spacer().frame(width: 70)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    // MARK: - Actions
    
    private func toggleListening() {
        if voiceEngine.state == .listening {
            voiceEngine.stopListening()
            if !voiceEngine.transcribedText.isEmpty {
                let text = voiceEngine.transcribedText
                Task {
                    await viewModel.sendMessage(text, wasSpoken: true)
                    // Auto-read response
                    if let lastAssistant = viewModel.messages.last, lastAssistant.role == .assistant {
                        voiceEngine.speak(lastAssistant.content)
                    }
                }
            }
        } else if voiceEngine.state == .speaking {
            // Tapping while speaking interrupts
            voiceEngine.interrupt()
        } else {
            voiceEngine.startListening()
        }
    }
    
    private func sendTextMessage() {
        guard !textInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let message = textInput
        textInput = ""
        Task {
            await viewModel.sendMessage(message, wasSpoken: false)
            // Auto-read response
            if let lastAssistant = viewModel.messages.last, lastAssistant.role == .assistant {
                voiceEngine.speak(lastAssistant.content)
            }
        }
    }
    
    private func handleCommand(_ command: VoiceCommand) {
        // Navigation commands: close assistant and navigate
        if command.isNavigation || command.isUploadAction {
            voiceEngine.stopListening()
            HapticService.shared.success()
            
            let destinationName: String
            switch command {
            case .goHome: destinationName = "Inicio"
            case .goUpload: destinationName = "Subir material"
            case .goQuiz: destinationName = "Quiz"
            case .goSettings: destinationName = "Ajustes"
            case .goBack: destinationName = "pantalla anterior"
            case .openCamera: destinationName = "cámara"
            case .openGallery: destinationName = "galería"
            case .openDocument: destinationName = "documentos"
            default: destinationName = ""
            }
            
            voiceEngine.speak("Abriendo \(destinationName)")
            
            // Dismiss the assistant sheet, then navigate
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                router.navigateByVoice(command)
            }
            return
        }
        
        // Audio control commands
        switch command {
        case .pause: voiceEngine.pause()
        case .resume: voiceEngine.continueSpeaking()
        case .repeatLast: voiceEngine.repeatLast()
        case .stop: voiceEngine.interrupt()
        case .faster: voiceEngine.speedRate = min(voiceEngine.speedRate + 0.25, 2.0)
        case .slower: voiceEngine.speedRate = max(voiceEngine.speedRate - 0.25, 0.5)
        default: break
        }
    }
    
    private func buildContextString() -> String {
        if let topic = contextTopic, let subject = contextSubject {
            return "\(subject.name) > \(topic.title)"
        } else if let subject = contextSubject {
            return subject.name
        }
        return "General"
    }
}

// MARK: - Context Indicator

struct ContextIndicator: View {
    let subjectName: String?
    let topicName: String?
    
    private var contextText: String {
        if let topic = topicName, let subject = subjectName {
            return "\(subject) > \(topic)"
        } else if let subject = subjectName {
            return subject
        }
        return "General"
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .font(FontTheme.caption)
            Text("Contexto: \(contextText)")
                .font(FontTheme.caption)
        }
        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .glassEffect(in: .capsule)
        .padding(.horizontal)
        .accessibilityLabel("Estás en el contexto: \(contextText)")
    }
}

// MARK: - Transcription View

struct TranscriptionView: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "waveform")
                .foregroundStyle(ColorTheme.accentHex)
                .accessibilityHidden(true)
            
            Text(text.isEmpty ? "Escuchando..." : text)
                .font(FontTheme.body)
                .foregroundStyle(text.isEmpty ? ColorTheme.adaptiveTextSecondary : ColorTheme.adaptiveText)
                .lineLimit(3)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassEffect(in: .rect(cornerRadius: 12))
        .padding(.horizontal)
        .accessibilityLabel("Transcripción en tiempo real: \(text.isEmpty ? "Escuchando" : text)")
    }
}

// MARK: - Assistant Response Card

struct AssistantResponseCard: View {
    let message: VoiceAssistantViewModel.AssistantMessage
    let onReadAgain: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            if message.role == .user { Spacer(minLength: 60) }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
                // Role label
                Text(message.role == .user ? "Tú" : "EchoStudy")
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                // Content
                Text(message.content)
                    .font(FontTheme.body)
                    .foregroundStyle(message.role == .user ? .white : ColorTheme.adaptiveText)
                    .padding(14)
                    .background(message.role == .user ? ColorTheme.accentHex : Color.clear)
                    .glassEffect(in: .rect(cornerRadius: 16))
                
                // Actions for assistant messages
                if message.role == .assistant {
                    HStack(spacing: 16) {
                        Button {
                            onReadAgain()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "speaker.wave.2")
                                Text("Leer")
                            }
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.secondaryHex)
                        }
                        .accessibilityLabel("Leer de nuevo esta respuesta")
                        
                        // Feedback
                        FeedbackCollectorView(
                            predictionId: message.id.uuidString,
                            predictionType: "assistant_response"
                        )
                    }
                }
                
                // Timestamp
                Text(message.timestamp.accessibleRelativeString)
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading)
            // A11Y: Combine for VoiceOver
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(message.role == .user ? "Tú" : "ARGOS"): \(message.content)")
            
            if message.role == .assistant { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Generated Content View

struct GeneratedContentView: View {
    let content: String
    let onSave: () -> Void
    let onReadAgain: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(ColorTheme.accentHex)
                Text("Contenido generado")
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                
                Spacer()
                
                ConfidenceBadge(confidence: 0.75)
            }
            
            // Content
            Text(content)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveText)
                .lineSpacing(3)
            
            // Actions
            HStack(spacing: 12) {
                Button {
                    HapticService.shared.success()
                    onSave()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Guardar")
                    }
                    .font(FontTheme.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(ColorTheme.primaryHex)
                    .clipShape(Capsule())
                }
                .accessibilityLabel("Guardar contenido generado en la materia")
                
                Button {
                    onReadAgain()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2")
                        Text("Leer")
                    }
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.secondaryHex)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .glassEffect(in: .capsule)
                .accessibilityLabel("Leer contenido generado en voz alta")
                
                Spacer()
            }
            
            // Transparency
            AITransparencyCard(
                explanation: "Este contenido fue generado por IA basándose en tus materiales de estudio. Revísalo antes de guardarlo.",
                confidence: 0.75,
                factors: ["Análisis de texto local", "Materiales de estudio"],
                sourceDescription: "Contenido generado"
            )
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ColorTheme.accentHex.opacity(0.5), lineWidth: 1.5)
        )
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding(.horizontal, 4)
        .announceOnAppear("Contenido generado por la IA disponible")
    }
}
