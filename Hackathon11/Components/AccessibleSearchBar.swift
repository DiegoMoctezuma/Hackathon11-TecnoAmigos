// AccessibleSearchBar.swift
// EchoStudy
// A11Y: Search bar optimized for VoiceOver

import SwiftUI

struct AccessibleSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
    
    init(text: Binding<String>, placeholder: String = "Buscar...", onSubmit: @escaping () -> Void = {}) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .accessibilityHidden(true)
            
            TextField(placeholder, text: $text)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveText)
                .submitLabel(.search)
                .onSubmit(onSubmit)
                .accessibilityLabel("Campo de búsqueda")
                .accessibilityHint("Escribe para buscar temas o materias")
            
            if !text.isEmpty {
                Button {
                    text = ""
                    HapticService.shared.light()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .accessibilityLabel("Limpiar búsqueda")
            }
        }
        .padding(12)
        .frame(minHeight: 48)
        .glassEffect(in: .rect(cornerRadius: 12))
    }
}
