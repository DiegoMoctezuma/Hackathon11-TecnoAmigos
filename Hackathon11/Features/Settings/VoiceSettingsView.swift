// VoiceSettingsView.swift
// EchoStudy
// A11Y: Voice configuration

import SwiftUI

struct VoiceSettingsView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @AppStorage(PreferenceKeys.voiceSpeed) private var voiceSpeed: Double = 1.0
    @AppStorage(PreferenceKeys.autoReadResults) private var autoReadResults: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Speed
                VStack(alignment: .leading, spacing: 8) {
                    Text("Velocidad de lectura: \(voiceSpeed, specifier: "%.1f")x")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    
                    Slider(value: $voiceSpeed, in: 0.5...2.0, step: 0.25)
                        .tint(ColorTheme.accentHex)
                        .accessibilityLabel("Velocidad de lectura")
                        .accessibilityValue("\(voiceSpeed, specifier: "%.1f") equis")
                    
                    Button("Probar velocidad") {
                        voiceEngine.speedRate = Float(voiceSpeed)
                        voiceEngine.speak("Esta es la velocidad de lectura seleccionada", priority: .immediate)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                // Auto-read
                Toggle(isOn: $autoReadResults) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Leer resultados automáticamente")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        Text("Lee en voz alta los resultados de la IA")
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
        .onChange(of: voiceSpeed) { _, newValue in
            voiceEngine.speedRate = Float(newValue)
        }
    }
}
