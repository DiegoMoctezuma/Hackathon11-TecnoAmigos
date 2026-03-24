// VoiceCalibrationView.swift
// EchoStudy
// A11Y: Voice speed calibration with live preview

import SwiftUI

struct VoiceCalibrationView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @AppStorage(PreferenceKeys.voiceSpeed) private var savedVoiceSpeed: Double = 1.0
    @State private var voiceSpeed: Float = 1.0
    @State private var isSpeaking = false
    
    var onComplete: () -> Void
    
    private let sampleText = "ARGOS convierte tus materiales de estudio en resúmenes organizados por tema. Puedes escucharlos, hacer preguntas con tu voz y evaluarte con quizzes orales. Todo diseñado para que aprendas a tu ritmo."
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 28) {
                // MARK: - Icon
                Image(systemName: "waveform.and.mic")
                    .font(.system(size: 64))
                    .foregroundStyle(ColorTheme.accentHex)
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking)
                    .accessibilityHidden(true)
                
                // MARK: - Title
                VStack(spacing: 8) {
                    Text("Calibrar velocidad de voz")
                        .font(FontTheme.title)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Voy a leer un párrafo. Ajusta la velocidad a tu gusto.")
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // MARK: - Speed Slider
                VStack(spacing: 12) {
                    Text("Velocidad: \(voiceSpeed, specifier: "%.1f")x")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "tortoise.fill")
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .accessibilityHidden(true)
                        
                        Slider(value: $voiceSpeed, in: 0.5...2.5, step: 0.1)
                            .tint(ColorTheme.accentHex)
                            .accessibilityLabel("Velocidad de voz")
                            .accessibilityValue("\(voiceSpeed, specifier: "%.1f") equis")
                        
                        Image(systemName: "hare.fill")
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal)
                    
                    // Preset speed buttons
                    HStack(spacing: 16) {
                        ForEach([0.75, 1.0, 1.5, 2.0], id: \.self) { speed in
                            Button {
                                HapticService.shared.selection()
                                voiceSpeed = Float(speed)
                                previewSpeed()
                            } label: {
                                Text("\(speed, specifier: "%.1f")x")
                                    .font(FontTheme.subheadline)
                                    .foregroundStyle(
                                        abs(Double(voiceSpeed) - speed) < 0.05
                                        ? .white : ColorTheme.adaptiveText
                                    )
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        abs(Double(voiceSpeed) - speed) < 0.05
                                        ? AnyShapeStyle(ColorTheme.accentHex)
                                        : AnyShapeStyle(Color.clear)
                                    )
                                    .glassEffect(in: .capsule)
                            }
                            .accessibilityLabel("\(speed, specifier: "%.1f") equis")
                            .accessibilityAddTraits(abs(Double(voiceSpeed) - speed) < 0.05 ? .isSelected : [])
                        }
                    }
                }
                .padding(20)
                .glassEffect(in: .rect(cornerRadius: 24))
                .padding(.horizontal)
                
                // MARK: - Preview Button
                Button {
                    HapticService.shared.medium()
                    previewSpeed()
                } label: {
                    HStack {
                        Image(systemName: isSpeaking ? "stop.fill" : "play.fill")
                        Text(isSpeaking ? "Detener" : "Escuchar ejemplo")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal)
                .accessibilityLabel(isSpeaking ? "Detener la lectura" : "Escuchar un texto de ejemplo con la velocidad seleccionada")
            }
            
            Spacer()
            
            // MARK: - Done Button
            Button {
                HapticService.shared.heavy()
                voiceEngine.interrupt()
                savedVoiceSpeed = Double(voiceSpeed)
                voiceEngine.speedRate = voiceSpeed
                onComplete()
            } label: {
                Text("Listo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .accessibilityHint("Guarda la velocidad seleccionada y continúa")
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .onAppear {
            voiceSpeed = Float(savedVoiceSpeed)
            voiceEngine.speak("Voy a leer un párrafo. Ajusta la velocidad a tu gusto.", priority: .high)
        }
        .onChange(of: voiceSpeed) { _, newValue in
            voiceEngine.speedRate = newValue
        }
    }
    
    private func previewSpeed() {
        if isSpeaking {
            voiceEngine.interrupt()
            isSpeaking = false
        } else {
            isSpeaking = true
            voiceEngine.speedRate = voiceSpeed
            voiceEngine.speak(sampleText, priority: .immediate)
            voiceEngine.onSpeechFinished = {
                isSpeaking = false
            }
        }
    }
}
