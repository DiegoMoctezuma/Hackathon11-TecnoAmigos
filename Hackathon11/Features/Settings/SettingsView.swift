// SettingsView.swift
// EchoStudy
// A11Y: Grouped settings with 5 sections and full VoiceOver support

import SwiftUI

// MARK: - Settings Sub-Navigation

enum SettingsDestination: Hashable {
    case voice
    case accessibility
    case dataPrivacy
    case about
}

struct SettingsView: View {
    // Settings uses its own NavigationStack for sub-pages
    
    // A11Y: Local path for settings sub-navigation
    @State private var settingsPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $settingsPath) {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Voice
                    settingsSection(title: "Voz", icon: "waveform") {
                        settingsRow(icon: "speaker.wave.3.fill", title: "Configuración de voz", subtitle: "Velocidad, selección de voz, idioma") {
                            settingsPath.append(SettingsDestination.voice)
                        }
                    }
                    
                    // MARK: - Accessibility
                    settingsSection(title: "Accesibilidad", icon: "accessibility") {
                        settingsRow(icon: "textformat.size", title: "Accesibilidad visual", subtitle: "Contraste, tamaño, haptics, sonidos") {
                            settingsPath.append(SettingsDestination.accessibility)
                        }
                    }
                    
                    // MARK: - Data & Privacy
                    settingsSection(title: "Datos y privacidad", icon: "lock.shield") {
                        settingsRow(icon: "hand.raised.fill", title: "Privacidad de datos", subtitle: "Almacenamiento local y permisos") {
                            settingsPath.append(SettingsDestination.dataPrivacy)
                        }
                    }
                    
                    // MARK: - AI
                    settingsSection(title: "Inteligencia Artificial", icon: "brain") {
                        settingsRow(icon: "cpu.fill", title: "Configuración de IA", subtitle: "Transparencia y consentimiento de datos") {
                            settingsPath.append(SettingsDestination.dataPrivacy)
                        }
                    }
                    
                    // MARK: - About
                    settingsSection(title: "Información", icon: "info.circle") {
                        settingsRow(icon: "info.circle.fill", title: "Acerca de EchoStudy", subtitle: "Versión, créditos y licencias") {
                            settingsPath.append(SettingsDestination.about)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Ajustes")
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .voice:
                    VoiceSettingsView()
                case .accessibility:
                    AccessibilitySettingsView()
                case .dataPrivacy:
                    DataPrivacyView()
                case .about:
                    AboutView()
                }
            }
            .announceOnAppear("Ajustes de ARGOS")
        }
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
            .frame(minHeight: 48)
            .glassEffect(in: .rect(cornerRadius: 16))
        }
        .padding(.horizontal)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityAddTraits(.isButton)
    }
}
