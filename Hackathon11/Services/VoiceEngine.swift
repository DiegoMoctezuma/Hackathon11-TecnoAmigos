// VoiceEngine.swift
// EchoStudy
// Centralized voice service: speech recognition + synthesis + command parsing

import Foundation
import AVFoundation
import Speech

// MARK: - Voice Engine State

enum VoiceEngineState: Equatable {
    case idle
    case listening
    case processing
    case speaking
}

// MARK: - Speech Priority

enum SpeechPriority: Int, Comparable {
    case low = 0
    case normal = 1
    case high = 2
    case immediate = 3
    
    static func < (lhs: SpeechPriority, rhs: SpeechPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Voice Command

enum VoiceCommand: String, CaseIterable {
    // Audio controls
    case pause = "pausa"
    case resume = "continúa"
    case repeatLast = "repite"
    case next = "siguiente"
    case previous = "anterior"
    case stop = "detente"
    case help = "ayuda"
    case louder = "más fuerte"
    case slower = "más lento"
    case faster = "más rápido"
    // Navigation
    case goHome = "inicio"
    case goUpload = "subir"
    case goQuiz = "quiz"
    case goSettings = "ajustes"
    case goBack = "atrás"
    // Upload actions
    case openCamera = "tomar foto"
    case openGallery = "seleccionar imagen"
    case openDocument = "seleccionar documento"
    
    /// Whether this command triggers app navigation
    var isNavigation: Bool {
        switch self {
        case .goHome, .goUpload, .goQuiz, .goSettings, .goBack: return true
        default: return false
        }
    }
    
    /// Whether this command triggers an upload action
    var isUploadAction: Bool {
        switch self {
        case .openCamera, .openGallery, .openDocument: return true
        default: return false
        }
    }
    
    /// Synonyms that also trigger this command
    private var synonyms: [String] {
        switch self {
        case .goHome: return ["ir a inicio", "llévame a inicio", "inicio", "home", "principal"]
        case .goUpload: return ["subir material", "ir a subir", "llévame a subir", "subir", "cargar"]
        case .goQuiz: return ["ir a quiz", "llévame a quiz", "quiz", "examen", "evaluación"]
        case .goSettings: return ["ir a ajustes", "llévame a ajustes", "ajustes", "configuración", "settings"]
        case .goBack: return ["ir atrás", "atrás", "regresar", "volver"]
        case .openCamera: return ["tomar foto", "abrir cámara", "cámara", "tomar una foto", "sacar foto", "foto"]
        case .openGallery: return ["seleccionar imagen", "abrir galería", "galería", "elegir imagen", "seleccionar de galería", "imagen de galería"]
        case .openDocument: return ["seleccionar documento", "abrir documento", "documento", "subir documento", "subir pdf", "elegir documento", "pdf"]
        default: return [rawValue]
        }
    }
    
    static func detect(in text: String) -> VoiceCommand? {
        let lowered = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // Check navigation commands first (longer phrases match before short ones)
        // Sort synonyms by length descending to match longer phrases first
        for command in VoiceCommand.allCases {
            let sorted = command.synonyms.sorted { $0.count > $1.count }
            if sorted.contains(where: { lowered.contains($0) }) {
                return command
            }
        }
        return nil
    }
}

// MARK: - Voice Engine

@Observable
@MainActor
final class VoiceEngine: NSObject {
    static let shared = VoiceEngine()
    
    // MARK: - Published State
    var state: VoiceEngineState = .idle
    var transcribedText: String = ""
    var isAuthorized: Bool = false
    var speedRate: Float = 1.0
    var currentLanguage: String = "es-MX"
    var errorMessage: String?
    /// Current microphone input level (0.0 – 1.0) for visual feedback
    var audioLevel: Float = 0.0
    
    // MARK: - Callbacks
    var onCommandDetected: ((VoiceCommand) -> Void)?
    var onTranscriptionUpdate: ((String) -> Void)?
    var onSpeechFinished: (() -> Void)?
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    /// A new engine is created for each listening session to avoid
    /// stale audio graph state (error -10868) after category changes.
    private var audioEngine: AVAudioEngine?
    private var lastSpokenText: String = ""
    
    // MARK: - Init
    
    private override init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLanguage))
        synthesizer.delegate = self
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        // Request speech recognition authorization
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        // Request microphone authorization
        let micGranted: Bool
        if #available(iOS 17, *) {
            micGranted = await AVAudioApplication.requestRecordPermission()
        } else {
            micGranted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        
        isAuthorized = speechStatus == .authorized && micGranted
    }
    
    // MARK: - Speech Recognition
    
    func startListening() {
        // Auto-request authorization if not yet done
        if !isAuthorized {
            Task {
                await requestAuthorization()
                if isAuthorized {
                    self.performStartListening()
                } else {
                    self.errorMessage = "Permisos de voz no autorizados. Actívalos en Ajustes."
                }
            }
            return
        }
        
        performStartListening()
    }
    
    private func performStartListening() {
        
        // Tear down any previous session completely
        stopListening()
        
        // A11Y: Ensure speech recognizer uses the correct language
        if speechRecognizer?.locale.identifier != currentLanguage {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLanguage))
        }
        
        // 1. Configure audio session FIRST
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Error configurando audio: \(error.localizedDescription)"
            return
        }
        
        // 2. Create a FRESH audio engine every time. Reusing an engine
        //    after an audio session category change causes error -10868
        //    because the internal AUGraph retains stale node state.
        let engine = AVAudioEngine()
        self.audioEngine = engine
        
        // 3. Set up recognition request
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.recognitionRequest = request
        
        // 4. Install tap — format nil lets Core Audio pick the hardware format
        let inputNode = engine.inputNode
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { [weak self] buffer, _ in
            request.append(buffer)
            
            // Calculate audio level for visual feedback
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameCount = Int(buffer.frameLength)
            guard frameCount > 0 else { return }
            var sum: Float = 0
            for i in 0..<frameCount {
                sum += channelData[i] * channelData[i]
            }
            let rms = sqrtf(sum / Float(frameCount))
            let normalized = min(max(rms * 10, 0), 1)
            
            Task { @MainActor [weak self] in
                self?.audioLevel = normalized
            }
        }
        
        // 5. Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                    self.onTranscriptionUpdate?(self.transcribedText)
                    if let command = VoiceCommand.detect(in: self.transcribedText) {
                        self.onCommandDetected?(command)
                    }
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                }
            }
        }
        
        // 6. Start engine
        do {
            engine.prepare()
            try engine.start()
            state = .listening
            transcribedText = ""
            HapticService.shared.success()
        } catch {
            errorMessage = "Error iniciando audio: \(error.localizedDescription)"
        }
    }
    
    func stopListening() {
        // 1. Stop engine and remove tap
        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            engine.inputNode.removeTap(onBus: 0)
        }
        
        // 2. End recognition
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // 3. Discard engine so the next session gets a fresh one
        audioEngine = nil
        
        // 4. Deactivate audio session so other apps / synthesis can use it
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // Non-fatal
        }
        
        audioLevel = 0.0
        if state == .listening {
            state = .idle
        }
    }
    
    // MARK: - Speech Synthesis
    
    func speak(_ text: String, priority: SpeechPriority = .normal) {
        if priority == .immediate {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        lastSpokenText = text
        let utterance = AVSpeechUtterance(string: text)
        
        // A11Y: Force Spanish voice with fallback chain
        // Try preferred language first, then any Spanish variant, then system default
        if let preferredVoice = AVSpeechSynthesisVoice(language: currentLanguage) {
            utterance.voice = preferredVoice
        } else if let anySpanish = AVSpeechSynthesisVoice(language: "es-MX") ?? AVSpeechSynthesisVoice(language: "es-ES") {
            utterance.voice = anySpanish
        }
        // If all fail, iOS will use system default — at least it won't crash
        
        utterance.rate = speedRate * AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.1
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            // Continue even if audio session setup fails
        }
        
        synthesizer.speak(utterance)
        state = .speaking
    }
    
    func interrupt() {
        synthesizer.stopSpeaking(at: .immediate)
        state = .idle
    }
    
    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    func continueSpeaking() {
        synthesizer.continueSpeaking()
    }
    
    func repeatLast() {
        guard !lastSpokenText.isEmpty else { return }
        speak(lastSpokenText, priority: .immediate)
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceEngine: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .idle
            self.onSpeechFinished?()
        }
    }
}
