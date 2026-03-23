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
    
    static func detect(in text: String) -> VoiceCommand? {
        let lowered = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return VoiceCommand.allCases.first { lowered.contains($0.rawValue) }
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
    
    // MARK: - Callbacks
    var onCommandDetected: ((VoiceCommand) -> Void)?
    var onTranscriptionUpdate: ((String) -> Void)?
    var onSpeechFinished: (() -> Void)?
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
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
        guard isAuthorized else {
            errorMessage = "Permisos de voz no autorizados"
            return
        }
        
        // Stop any existing task
        stopListening()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Error configurando audio: \(error.localizedDescription)"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                    self.onTranscriptionUpdate?(self.transcribedText)
                    
                    // Check for voice commands
                    if let command = VoiceCommand.detect(in: self.transcribedText) {
                        self.onCommandDetected?(command)
                    }
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                }
            }
        }
        
        do {
            try audioEngine.start()
            state = .listening
            transcribedText = ""
        } catch {
            errorMessage = "Error iniciando audio: \(error.localizedDescription)"
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
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
        utterance.voice = AVSpeechSynthesisVoice(language: currentLanguage)
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
