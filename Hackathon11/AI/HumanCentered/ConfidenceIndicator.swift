// ConfidenceIndicator.swift
// EchoStudy
// A11Y: Circular progress confidence indicator with 3 levels, colors, sounds

import SwiftUI

struct ConfidenceIndicator: View {
    let confidence: Float
    var showLabel: Bool = true
    var size: CGFloat = 56
    
    @State private var animatedProgress: CGFloat = 0
    @State private var showExplanation: Bool = false
    
    private var level: ConfidenceLevel {
        if confidence >= 0.8 { return .high }
        if confidence >= 0.5 { return .moderate }
        return .low
    }
    
    var body: some View {
        Button {
            HapticService.shared.light()
            showExplanation = true
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(level.color.opacity(0.2), lineWidth: 4)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            level.color,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    // Center content
                    VStack(spacing: 0) {
                        Image(systemName: level.iconName)
                            .font(.system(size: size * 0.25))
                            .foregroundStyle(level.color)
                        
                        Text("\(Int(confidence * 100))%")
                            .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                            .foregroundStyle(ColorTheme.adaptiveText)
                    }
                }
                .frame(width: size, height: size)
                
                if showLabel {
                    Text(level.label)
                        .font(FontTheme.caption)
                        .foregroundStyle(level.color)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Confianza: \(level.label), \(Int(confidence * 100)) por ciento")
        .accessibilityHint("Toca para ver cómo se calculó la confianza")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = CGFloat(confidence)
            }
            playConfidenceSound()
        }
        .sheet(isPresented: $showExplanation) {
            AIExplanationSheet()
        }
    }
    
    // MARK: - Confidence Sound
    
    private func playConfidenceSound() {
        switch level {
        case .high:
            HapticService.shared.success()
        case .moderate:
            HapticService.shared.warning()
        case .low:
            HapticService.shared.error()
        }
    }
}

// MARK: - Confidence Level

private enum ConfidenceLevel {
    case high, moderate, low
    
    var color: Color {
        switch self {
        case .high: return ColorTheme.successHex
        case .moderate: return ColorTheme.warningHex
        case .low: return ColorTheme.errorHex
        }
    }
    
    var label: String {
        switch self {
        case .high: return "Alta"
        case .moderate: return "Moderada"
        case .low: return "Baja"
        }
    }
    
    var iconName: String {
        switch self {
        case .high: return "checkmark.circle.fill"
        case .moderate: return "exclamationmark.circle.fill"
        case .low: return "xmark.circle.fill"
        }
    }
}
