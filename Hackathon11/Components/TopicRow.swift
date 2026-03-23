// TopicRow.swift
// EchoStudy
// A11Y: Topic row with title, summary, and confidence badge

import SwiftUI

struct TopicRow: View {
    let title: String
    let summary: String
    let confidence: Float
    let isVerified: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityAddTraits(.isHeader)
                
                Text(summary)
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(ColorTheme.successHex)
                    .accessibilityLabel("Verificado por ti")
            }
            
            ConfidenceBadge(confidence: confidence)
        }
        .padding(12)
        .glassEffect(in: .rect(cornerRadius: 16))
        // A11Y: Combined label for VoiceOver
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(summary). Confianza: \(Int(confidence * 100)) por ciento\(isVerified ? ". Verificado" : "")")
    }
}
