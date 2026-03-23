// AccessibilitySettingsView.swift
// EchoStudy
// A11Y: Accessibility configuration

import SwiftUI

struct AccessibilitySettingsView: View {
    @AppStorage(PreferenceKeys.highContrast) private var highContrast: Bool = false
    @AppStorage(PreferenceKeys.hapticFeedback) private var hapticFeedback: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // High contrast
                Toggle(isOn: $highContrast) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alto contraste")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        Text("Aumenta el contraste de los colores")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .accessibilityLabel("Alto contraste")
                .accessibilityValue(highContrast ? "Activado" : "Desactivado")
                
                // Haptic feedback
                Toggle(isOn: $hapticFeedback) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vibración háptica")
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        Text("Vibración al interactuar con botones")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .accessibilityLabel("Vibración háptica")
                .accessibilityValue(hapticFeedback ? "Activado" : "Desactivado")
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Configuración del sistema")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    
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
    }
}
