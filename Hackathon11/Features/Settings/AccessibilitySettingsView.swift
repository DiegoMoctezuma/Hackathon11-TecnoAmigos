// AccessibilitySettingsView.swift
// EchoStudy
// A11Y: Full accessibility configuration

import SwiftUI

struct AccessibilitySettingsView: View {
    @AppStorage(PreferenceKeys.highContrast) private var highContrast: Bool = false
    @AppStorage(PreferenceKeys.hapticFeedback) private var hapticFeedback: Bool = true
    @AppStorage(PreferenceKeys.soundsEnabled) private var soundsEnabled: Bool = true
    @AppStorage(PreferenceKeys.autoReadTopics) private var autoReadTopics: Bool = true
    @AppStorage(PreferenceKeys.autoReadSpeed) private var autoReadSpeed: Double = 1.0
    @AppStorage(PreferenceKeys.contrastLevel) private var contrastLevel: String = "Normal"
    @AppStorage(PreferenceKeys.additionalTextSize) private var additionalTextSize: Double = 0
    
    @Environment(VoiceEngine.self) private var voiceEngine
    
    private let contrastLevels = ["Normal", "Alto", "Máximo"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Contrast Level
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nivel de contraste")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    Picker("Contraste", selection: $contrastLevel) {
                        ForEach(contrastLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Nivel de contraste")
                    .onChange(of: contrastLevel) { _, newValue in
                        HapticService.shared.selection()
                        highContrast = newValue != "Normal"
                    }
                    
                    Text(contrastDescription)
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                // MARK: - Additional Text Size
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tamaño de texto adicional")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Ajuste: \(additionalTextSize > 0 ? "+" : "")\(Int(additionalTextSize)) pt")
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.accentHex)
                    
                    HStack(spacing: 12) {
                        Text("A")
                            .font(.system(size: 14))
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .accessibilityHidden(true)
                        
                        Slider(value: $additionalTextSize, in: -2...8, step: 1)
                            .tint(ColorTheme.accentHex)
                            .accessibilityLabel("Tamaño de texto adicional")
                            .accessibilityValue("\(Int(additionalTextSize)) puntos adicionales")
                        
                        Text("A")
                            .font(.system(size: 24))
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .accessibilityHidden(true)
                    }
                    
                    Text("Se suma al tamaño de Dynamic Type del sistema.")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                // MARK: - Haptics
                Toggle(isOn: $hapticFeedback) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vibración háptica")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        Text("Vibración al interactuar con botones y acciones")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .accessibilityLabel("Vibración háptica")
                .accessibilityValue(hapticFeedback ? "Activado" : "Desactivado")
                
                // MARK: - Sounds
                Toggle(isOn: $soundsEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sonidos")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        Text("Reproduce sonidos al completar acciones")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .accessibilityLabel("Sonidos")
                .accessibilityValue(soundsEnabled ? "Activado" : "Desactivado")
                
                // MARK: - Auto-read Topics
                Toggle(isOn: $autoReadTopics) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto-lectura al entrar a temas")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        Text("Lee el resumen automáticamente al abrir un tema")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .accessibilityLabel("Auto-lectura al entrar a temas")
                .accessibilityValue(autoReadTopics ? "Activado" : "Desactivado")
                
                // MARK: - Auto-read Speed
                if autoReadTopics {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Velocidad de auto-lectura: \(autoReadSpeed, specifier: "%.1f")x")
                            .font(FontTheme.headline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        
                        Slider(value: $autoReadSpeed, in: 0.5...2.5, step: 0.1)
                            .tint(ColorTheme.accentHex)
                            .accessibilityLabel("Velocidad de auto-lectura")
                            .accessibilityValue("\(autoReadSpeed, specifier: "%.1f") equis")
                        
                        Text("Independiente de la velocidad de voz general.")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        
                        Button {
                            voiceEngine.speedRate = Float(autoReadSpeed)
                            voiceEngine.speak("Esta es la velocidad de auto-lectura de temas.", priority: .immediate)
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Probar velocidad")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityLabel("Probar velocidad de auto-lectura")
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 20))
                }
                
                // MARK: - System Settings Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                            .foregroundStyle(ColorTheme.accentHex)
                        Text("Configuración del sistema")
                            .font(FontTheme.headline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                    }
                    
                    Text("Para ajustar Dynamic Type, VoiceOver y otras opciones de accesibilidad, abre Ajustes del sistema > Accesibilidad.")
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
            }
            .padding()
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Accesibilidad")
        .onChange(of: hapticFeedback) { _, newValue in
            HapticService.shared.isEnabled = newValue
        }
        .announceOnAppear("Ajustes de accesibilidad")
    }
    
    private var contrastDescription: String {
        switch contrastLevel {
        case "Alto": return "Colores con mayor contraste para mejorar la legibilidad."
        case "Máximo": return "Máximo contraste entre texto y fondo. Ideal para baja visión."
        default: return "Colores estándar de la aplicación."
        }
    }
}
