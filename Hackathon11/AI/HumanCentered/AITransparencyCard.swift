// AITransparencyCard.swift
// EchoStudy
// A11Y: Expandable "Why this suggestion?" card

import SwiftUI

struct AITransparencyCard: View {
    let title: String
    let explanation: String
    let confidence: Float
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticService.shared.light()
            } label: {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(ColorTheme.warningHex)
                    
                    Text("¿Por qué esta sugerencia?")
                        .font(FontTheme.subheadline)
                        .foregroundStyle(ColorTheme.accentHex)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
            }
            .accessibilityLabel("¿Por qué esta sugerencia? \(isExpanded ? "Expandido" : "Toca para ver explicación")")
            .accessibilityAddTraits(.isButton)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(explanation)
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    
                    HStack {
                        ConfidenceBadge(confidence: confidence)
                        Spacer()
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .glassEffect(in: .rect(cornerRadius: 12))
    }
}
