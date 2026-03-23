// ConfidenceBadge.swift
// EchoStudy
// A11Y: Visual + auditory confidence indicator for AI results

import SwiftUI

struct ConfidenceBadge: View {
    let confidence: Float
    
    private var level: ConfidenceLevel {
        if confidence >= 0.8 { return .high }
        if confidence >= 0.5 { return .moderate }
        return .low
    }
    
    private var color: Color {
        switch level {
        case .high: return ColorTheme.successHex
        case .moderate: return ColorTheme.warningHex
        case .low: return ColorTheme.errorHex
        }
    }
    
    private var iconName: String {
        switch level {
        case .high: return "checkmark.circle.fill"
        case .moderate: return "exclamationmark.circle.fill"
        case .low: return "xmark.circle.fill"
        }
    }
    
    private var levelText: String {
        switch level {
        case .high: return "Alta"
        case .moderate: return "Moderada"
        case .low: return "Baja"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(FontTheme.caption)
            Text("\(Int(confidence * 100))%")
                .font(FontTheme.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .glassEffect(in: .capsule)
        // A11Y: Full description for VoiceOver
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Confianza del resultado: \(levelText), \(Int(confidence * 100)) por ciento")
        .accessibilityHint("Toca para ver más detalles sobre la confianza")
    }
    
    private enum ConfidenceLevel {
        case high, moderate, low
    }
}
