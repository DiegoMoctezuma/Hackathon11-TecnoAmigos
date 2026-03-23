// SettingsView.swift
// EchoStudy
// A11Y: Grouped settings with full VoiceOver support

import SwiftUI

struct SettingsView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Voice
                settingsSection(title: "Voz", icon: "waveform") {
                    settingsRow(icon: "speaker.wave.3.fill", title: "Configuración de voz", subtitle: "Velocidad, tono, idioma") {
                        router.push(.voiceSettings)
                    }
                }
                
                // MARK: - Accessibility
                settingsSection(title: "Accesibilidad", icon: "accessibility") {
                    settingsRow(icon: "textformat.size", title: "Accesibilidad visual", subtitle: "Contraste, tamaño, haptics") {
                        router.push(.accessibilitySettings)
                    }
                }
                
                // MARK: - Data
                settingsSection(title: "Datos", icon: "lock.shield") {
                    settingsRow(icon: "hand.raised.fill", title: "Privacidad de datos", subtitle: "Almacenamiento y permisos") {
                        router.push(.dataPrivacy)
                    }
                }
                
                // MARK: - About
                settingsSection(title: "Información", icon: "info.circle") {
                    settingsRow(icon: "info.circle.fill", title: "Acerca de EchoStudy", subtitle: "Versión y créditos") {
                        router.push(.about)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Ajustes")
        .announceOnAppear("Ajustes de EchoStudy")
    }
    
    private func settingsSection(title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.accentHex)
                Text(title)
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
            }
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal)
            
            content()
        }
    }
    
    private func settingsRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticService.shared.light()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(ColorTheme.accentHex)
                    .frame(width: 32)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    Text(subtitle)
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 16))
        }
        .padding(.horizontal)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityAddTraits(.isButton)
    }
}
