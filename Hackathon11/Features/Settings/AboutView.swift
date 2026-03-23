// AboutView.swift
// EchoStudy

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App icon
                Image(systemName: "waveform.and.mic")
                    .font(.system(size: 64))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(ColorTheme.accentHex)
                    .padding(.top, 20)
                    .accessibilityHidden(true)
                
                Text("EchoStudy")
                    .font(FontTheme.largeTitle)
                    .foregroundStyle(ColorTheme.adaptiveText)
                
                Text("Tu compañero de estudio accesible")
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                // Mission
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nuestra misión")
                        .font(FontTheme.title3)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("No adaptamos una app para que sea accesible — la diseñamos desde la perspectiva de quien no puede ver. EchoStudy empodera a estudiantes con discapacidad visual para estudiar de forma autónoma.")
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                // Tech stack
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tecnologías")
                        .font(FontTheme.title3)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    techRow("SwiftUI + Liquid Glass", "Interfaz nativa iOS 26")
                    techRow("Vision (OCR)", "Extracción de texto de imágenes")
                    techRow("NaturalLanguage", "Análisis y extracción de temas")
                    techRow("AVFoundation", "Reconocimiento y síntesis de voz")
                    techRow("SwiftData", "Persistencia local segura")
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                Text("Versión 1.0.0")
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            .padding()
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Acerca de")
    }
    
    private func techRow(_ title: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(ColorTheme.successHex)
                .font(FontTheme.caption)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                Text(description)
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
