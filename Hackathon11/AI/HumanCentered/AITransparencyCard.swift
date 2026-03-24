// AITransparencyCard.swift
// EchoStudy
// A11Y: Expandable "Why this suggestion?" card with factors, source, and confidence

import SwiftUI

struct AITransparencyCard: View {
    let explanation: String
    let confidence: Float
    var factors: [String] = []
    var sourceDescription: String? = nil
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Expand/Collapse header button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticService.shared.light()
            } label: {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(ColorTheme.warningHex)
                    
                    Text("¿Cómo se generó esto?")
                        .font(FontTheme.subheadline)
                        .foregroundStyle(ColorTheme.accentHex)
                    
                    Spacer()
                    
                    ConfidenceBadge(confidence: confidence)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
            }
            .accessibilityLabel("¿Cómo se generó este resultado? Confianza \(Int(confidence * 100)) por ciento. \(isExpanded ? "Expandido" : "Toca para ver explicación")")
            .accessibilityAddTraits(.isButton)
            
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .glassEffect(in: .rect(cornerRadius: 12))
    }
    
    // MARK: - Expanded Content
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Explanation in simple language
            Text(explanation)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveText)
            
            // Factors that influenced the result
            if !factors.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Factores considerados:")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    
                    ForEach(factors, id: \.self) { factor in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(ColorTheme.secondaryHex)
                            
                            Text(factor)
                                .font(FontTheme.caption)
                                .foregroundStyle(ColorTheme.adaptiveText)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Factores considerados: \(factors.joined(separator: ". "))")
            }
            
            // Source description
            if let source = sourceDescription {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundStyle(ColorTheme.primaryHex)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fuente:")
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        Text(source)
                            .font(FontTheme.caption)
                            .foregroundStyle(ColorTheme.adaptiveText)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Fuente del resultado: \(source)")
            }
            
            // Disclaimer
            Text("Este resultado fue generado por análisis de texto local. Verifica siempre la información con tus fuentes originales.")
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .italic()
        }
    }
}
