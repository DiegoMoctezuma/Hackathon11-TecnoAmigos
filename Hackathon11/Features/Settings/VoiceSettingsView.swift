// VoiceSettingsView.swift
// EchoStudy
// A11Y: Voice configuration with speed, voice selection, language, test

import SwiftUI
import AVFoundation

struct VoiceSettingsView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @AppStorage(PreferenceKeys.voiceSpeed) private var voiceSpeed: Double = 1.0
    @AppStorage(PreferenceKeys.autoReadResults) private var autoReadResults: Bool = true
    @AppStorage(PreferenceKeys.preferredVoiceId) private var preferredVoiceId: String = ""
    @AppStorage(PreferenceKeys.voiceLanguage) private var voiceLanguage: String = "es-MX"
    
    @State private var availableVoices: [AVSpeechSynthesisVoice] = []
    @State private var selectedVoice: AVSpeechSynthesisVoice?
    
    private let supportedLanguages = [
        ("es-MX", "Español (México)"),
        ("es-ES", "Español (España)"),
        ("en-US", "English (US)"),
        ("en-GB", "English (UK)")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Speed
                VStack(alignment: .leading, spacing: 12) {
                    Text("Velocidad de lectura")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("\(voiceSpeed, specifier: "%.1f")x")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(ColorTheme.accentHex)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "tortoise.fill")
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .accessibilityHidden(true)
                        
                        Slider(value: $voiceSpeed, in: 0.5...2.5, step: 0.1)
                            .tint(ColorTheme.accentHex)
                            .accessibilityLabel("Velocidad de lectura")
                            .accessibilityValue("\(voiceSpeed, specifier: "%.1f") equis")
                        
                        Image(systemName: "hare.fill")
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .accessibilityHidden(true)
                    }
                    
                    Button {
                        voiceEngine.speedRate = Float(voiceSpeed)
                        voiceEngine.speak("Esta es la velocidad de lectura seleccionada. Así sonarán los resúmenes y explicaciones.", priority: .immediate)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Probar voz")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityLabel("Probar la velocidad de voz actual")
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                // MARK: - Voice Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Selección de voz")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    if availableVoices.isEmpty {
                        Text("Cargando voces disponibles...")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    } else {
                        ForEach(availableVoices, id: \.identifier) { voice in
                            Button {
                                HapticService.shared.selection()
                                selectedVoice = voice
                                preferredVoiceId = voice.identifier
                                previewVoice(voice)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: selectedVoice?.identifier == voice.identifier ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedVoice?.identifier == voice.identifier ? ColorTheme.accentHex : ColorTheme.adaptiveTextSecondary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(voice.name)
                                            .font(FontTheme.body)
                                            .foregroundStyle(ColorTheme.adaptiveText)
                                        Text(qualityLabel(for: voice))
                                            .font(FontTheme.caption)
                                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        previewVoice(voice)
                                    } label: {
                                        Image(systemName: "play.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(ColorTheme.accentHex)
                                    }
                                    .accessibilityLabel("Escuchar voz \(voice.name)")
                                    .accessibleTapTarget()
                                }
                                .padding(12)
                                .frame(minHeight: 48)
                                .glassEffect(in: .rect(cornerRadius: 12))
                            }
                            .accessibilityLabel("\(voice.name). \(qualityLabel(for: voice))")
                            .accessibilityAddTraits(selectedVoice?.identifier == voice.identifier ? .isSelected : [])
                        }
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                // MARK: - Language
                VStack(alignment: .leading, spacing: 12) {
                    Text("Idioma de reconocimiento")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    ForEach(supportedLanguages, id: \.0) { code, name in
                        Button {
                            HapticService.shared.selection()
                            voiceLanguage = code
                            loadVoices()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: voiceLanguage == code ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(voiceLanguage == code ? ColorTheme.accentHex : ColorTheme.adaptiveTextSecondary)
                                
                                Text(name)
                                    .font(FontTheme.body)
                                    .foregroundStyle(ColorTheme.adaptiveText)
                                
                                Spacer()
                            }
                            .padding(12)
                            .frame(minHeight: 48)
                            .glassEffect(in: .rect(cornerRadius: 12))
                        }
                        .accessibilityLabel(name)
                        .accessibilityAddTraits(voiceLanguage == code ? .isSelected : [])
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                // MARK: - Auto-read
                Toggle(isOn: $autoReadResults) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Leer resultados automáticamente")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        Text("Lee en voz alta los resultados de la IA al procesarlos")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .accessibilityLabel("Leer resultados automáticamente")
                .accessibilityValue(autoReadResults ? "Activado" : "Desactivado")
            }
            .padding()
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Voz")
        .onAppear { loadVoices() }
        .onChange(of: voiceSpeed) { _, newValue in
            voiceEngine.speedRate = Float(newValue)
        }
    }
    
    private func loadVoices() {
        let langPrefix = String(voiceLanguage.prefix(2))
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(langPrefix) }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
        
        if let currentId = availableVoices.first(where: { $0.identifier == preferredVoiceId }) {
            selectedVoice = currentId
        } else {
            selectedVoice = availableVoices.first
        }
    }
    
    private func previewVoice(_ voice: AVSpeechSynthesisVoice) {
        let utterance = AVSpeechUtterance(string: "Hola, soy la voz de ARGOS. Así sonarán tus resúmenes.")
        utterance.voice = voice
        utterance.rate = Float(voiceSpeed) * AVSpeechUtteranceDefaultSpeechRate
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    private func qualityLabel(for voice: AVSpeechSynthesisVoice) -> String {
        switch voice.quality {
        case .enhanced: return "Calidad mejorada"
        case .premium: return "Calidad premium"
        default: return "Calidad estándar"
        }
    }
}
