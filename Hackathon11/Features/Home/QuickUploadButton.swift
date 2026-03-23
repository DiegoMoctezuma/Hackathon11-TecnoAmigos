// QuickUploadButton.swift
// EchoStudy
// A11Y: Full-width glass upload button with pulse animation

import SwiftUI

struct QuickUploadButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.shared.medium()
            action()
        }) {
            HStack(spacing: 14) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.pulse, options: .repeating.speed(0.6))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Subir material nuevo")
                        .font(FontTheme.headline)
                    Text("Foto, PDF o documento")
                        .font(FontTheme.subheadline)
                        .opacity(0.85)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(FontTheme.body)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(minHeight: 60) // A11Y: 60pt minimum height
            .background(ColorTheme.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: ColorTheme.accentHex.opacity(0.3), radius: 12, y: 4)
        }
        .padding(.horizontal)
        // A11Y: Full description
        .accessibilityLabel("Subir material nuevo. Foto, PDF o documento")
        .accessibilityHint("Toca dos veces para abrir cámara o seleccionar documento")
        .accessibilityAddTraits(.isButton)
    }
}
