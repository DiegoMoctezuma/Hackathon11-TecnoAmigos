// AccessibilitySetupView.swift
// EchoStudy
// A11Y: Initial accessibility configuration during onboarding

import SwiftUI

struct AccessibilitySetupView: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @AppStorage(PreferenceKeys.highContrast) private var highContrast: Bool = false
    @AppStorage(PreferenceKeys.hapticFeedback) private var hapticFeedback: Bool = true
    @AppStorage(PreferenceKeys.soundsEnabled) private var soundsEnabled: Bool = true
    
    @State private var contrastLevel: ContrastLevel = .normal
    
    var onComplete: () -> Void
    
    enum ContrastLevel: String, CaseIterable, Identifiable {
        case normal = "Normal"
        case high = "Alto"
        case maximum = "Máximo"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .normal: return "Colores estándar de la app"
            case .high: return "Mayor contraste entre texto y fondo"
            case .maximum: return "Máximo contraste, ideal para baja visión"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    // MARK: - Header
                    VStack(spacing: 12) {
                        Image(systemName: "accessibility")
                            .font(.system(size: 56))
                            .foregroundStyle(ColorTheme.accentHex)
                            .accessibilityHidden(true)
                        
                        Text("Personaliza tu experiencia")
                            .font(FontTheme.title)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("Configura la accesibilidad según tus preferencias")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Contrast Level
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nivel de contraste")
                            .font(FontTheme.headline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(ContrastLevel.allCases) { level in
                            Button {
                                HapticService.shared.selection()
                                contrastLevel = level
                                highContrast = level != .normal
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: contrastLevel == level ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(contrastLevel == level ? ColorTheme.accentHex : ColorTheme.adaptiveTextSecondary)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(level.rawValue)
                                            .font(FontTheme.headline)
                                            .foregroundStyle(ColorTheme.adaptiveText)
                                        Text(level.description)
                                            .font(FontTheme.caption)
                                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(14)
                                .frame(minHeight: 48)
                                .glassEffect(in: .rect(cornerRadius: 16))
                            }
                            .accessibilityLabel("\(level.rawValue). \(level.description)")
                            .accessibilityAddTraits(contrastLevel == level ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Sounds
                    Toggle(isOn: $soundsEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sonidos")
                                .font(FontTheme.headline)
                                .foregroundStyle(ColorTheme.adaptiveText)
                            Text("Reproduce sonidos para acciones y notificaciones")
                                .font(FontTheme.caption)
                                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        }
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 16))
                    .padding(.horizontal)
                    .accessibilityLabel("Sonidos")
                    .accessibilityValue(soundsEnabled ? "Activado" : "Desactivado")
                    
                    // MARK: - Haptics
                    Toggle(isOn: $hapticFeedback) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vibración háptica")
                                .font(FontTheme.headline)
                                .foregroundStyle(ColorTheme.adaptiveText)
                            Text("Vibración al interactuar con la app")
                                .font(FontTheme.caption)
                                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        }
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 16))
                    .padding(.horizontal)
                    .accessibilityLabel("Vibración háptica")
                    .accessibilityValue(hapticFeedback ? "Activado" : "Desactivado")
                }
                .padding(.vertical)
            }
            
            // MARK: - Confirm Button
            Button {
                HapticService.shared.heavy()
                HapticService.shared.isEnabled = hapticFeedback
                voiceEngine.speak("Configuración guardada. Bienvenido a ARGOS.", priority: .high)
                onComplete()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Confirmar y comenzar")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .accessibilityHint("Guarda las opciones de accesibilidad y entra al inicio")
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .onAppear {
            voiceEngine.speak("Personaliza tu experiencia. Elige nivel de contraste, sonidos y vibración.", priority: .high)
        }
    }
}
